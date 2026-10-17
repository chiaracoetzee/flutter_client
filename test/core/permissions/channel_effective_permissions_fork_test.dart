import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/permissions/channel_effective_permissions.dart';
import 'package:fluxer_app/core/permissions/channel_permission_cache_provider.dart';
import 'package:fluxer_app/core/permissions/permission.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';

import '../../helpers/open_test_database.dart';

// Fork: the fork once fetched the user's own guild member over the API, once
// per channel, whenever it was missing from the database. On a fast phone
// that sent 65 identical requests in half a second, the global rate limit
// revoked the session, and the user was signed out again and again
// (tyne-chat/tyne#114). Upstream waits for the member to arrive with READY
// instead; these tests hold the app to that.

const String _guildId = 'guild_1';
const String _userId = 'user_1';
const int _channelCount = 20;

class _RecordingAdapter implements HttpClientAdapter {
  final List<String> requestedPaths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    return ResponseBody.fromString('{}', 500);
  }

  @override
  void close({bool force = false}) {}
}

class _FixedUserSettingsViewModel extends UserSettingsViewModel {
  @override
  UserSettingsViewState build() => const UserSettingsViewState(
    userId: _userId,
    username: 'user',
    displayName: 'user',
    discriminator: '0001',
    avatar: null,
    avatarColor: null,
    memberSince: null,
    status: 'online',
    messageDisplayCompact: false,
    developerMode: false,
    trustedDomains: <String>[],
  );
}

String _channelId(int index) => 'channel_$index';

Future<void> _seedGuildWithoutOwnMember(FluxerDatabase db) async {
  await db.guildDao.upsertServer(
    ServersCompanion.insert(
      id: _guildId,
      name: 'Guild',
      ownerId: const Value('owner'),
    ),
  );
  await db.roleDao.upsertRoles(<RolesCompanion>[
    RolesCompanion.insert(
      id: _guildId,
      guildId: _guildId,
      name: '@everyone',
      permissions: Value(
        (Permission.viewChannel.value | Permission.addReactions.value)
            .toString(),
      ),
    ),
  ]);
  for (var i = 0; i < _channelCount; i++) {
    await db.channelDao.upsertChannel(
      ChannelsCompanion.insert(
        id: _channelId(i),
        guildId: _guildId,
        name: 'channel-$i',
      ),
    );
  }
}

void main() {
  late FluxerDatabase db;
  late _RecordingAdapter adapter;
  late ProviderContainer container;

  setUp(() async {
    db = openTestDatabase();
    await _seedGuildWithoutOwnMember(db);
    adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = adapter;
    container = ProviderContainer(
      overrides: [
        fluxerDatabaseProvider.overrideWithValue(db),
        fluxerDioProvider.overrideWithValue(dio),
        userSettingsViewModelProvider.overrideWith(
          _FixedUserSettingsViewModel.new,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<ChannelPermissionBitsOutcome> compute(String channelId) =>
      container.read(
        FutureProvider<ChannelPermissionBitsOutcome>(
          (Ref ref) => computeEffectiveGuildChannelPermissionBitsOutcome(
            ref: ref,
            channelId: channelId,
          ),
        ).future,
      );

  test(
    'leaves permissions unknown, without asking the server, while the own member is missing',
    () async {
      final ChannelPermissionBitsOutcome outcome = await compute(_channelId(0));

      expect(outcome, (value: 0, shouldCache: false));
      expect(adapter.requestedPaths, isEmpty);
    },
  );

  test(
    'rebuilding every channel at once sends no request while the own member is missing',
    () async {
      final ChannelPermissionCache cache = container.read(
        channelPermissionCacheProvider.notifier,
      );

      await Future.wait(<Future<void>>[
        for (var i = 0; i < _channelCount; i++)
          cache.rebuildChannel(_channelId(i)),
      ]);

      expect(adapter.requestedPaths, isEmpty);
      expect(cache.getChannelBits(_channelId(0)), isNull);
    },
  );

  test(
    'resolves reactions once the own member arrives, as READY writes it',
    () async {
      final ChannelPermissionCache cache = container.read(
        channelPermissionCacheProvider.notifier,
      );
      await cache.rebuildChannel(_channelId(0));
      expect(cache.getChannelBits(_channelId(0)), isNull);

      await db.memberDao.upsertMember(
        MembersCompanion.insert(userId: _userId, guildId: _guildId),
      );
      await cache.rebuildChannel(_channelId(0));

      final int? bits = cache.getChannelBits(_channelId(0));
      expect(bits, isNotNull);
      expect(hasPermission(bits!, Permission.addReactions), isTrue);
      expect(adapter.requestedPaths, isEmpty);
    },
  );
}
