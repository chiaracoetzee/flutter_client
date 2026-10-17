// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show FluxerDatabase, KnownPersona;
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:fluxer_app/features/profile/providers/persona_gateway_events.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fork: the persona gateway events, handled apart from upstream's gateway
// provider.

typedef _PersonaUpdate = ({
  String personaId,
  String? name,
  String? avatar,
  String? tag,
  String? tagIcon,
});

class _RecordingChatViewModel extends ChatViewModel {
  final List<_PersonaUpdate> personaUpdates = [];
  final List<({String authorId, String? tag, String? tagIcon})> tagUpdates = [];

  @override
  ChatViewState build() => const ChatViewState(
    channelId: 'c1',
    messages: <Message>[],
    replyingTo: null,
    replyMentioning: false,
    editingMessage: null,
    messageText: '',
    scrollToBottomSignal: 0,
    isLoading: false,
    isSyncingMessages: false,
    isLoadingMore: false,
    isLoadingNewer: false,
    hasMoreMessages: false,
    hasMoreNewerMessages: false,
    errorMessage: null,
  );

  @override
  void onPersonaUpdated({
    required String personaId,
    required String? name,
    required String? avatar,
    required String? tag,
    required String? tagIcon,
  }) {
    personaUpdates.add((
      personaId: personaId,
      name: name,
      avatar: avatar,
      tag: tag,
      tagIcon: tagIcon,
    ));
  }

  @override
  void onAuthorDisplayTagUpdated({
    required String authorId,
    required String? tag,
    required String? tagIcon,
  }) {
    tagUpdates.add((authorId: authorId, tag: tag, tagIcon: tagIcon));
  }
}

class _RecordingMyPersonas extends MyPersonasNotifier {
  int reloads = 0;
  final List<String> removed = [];
  final List<Persona> upserted = [];

  @override
  AsyncValue<List<Persona>> build() => const AsyncData(<Persona>[]);

  @override
  Future<void> reloadSilently() async {
    reloads++;
  }

  @override
  void removePersona(String id) => removed.add(id);

  @override
  void upsertPersona(Persona persona) => upserted.add(persona);
}

class _RecordingPersonaSettings extends PersonaSettingsNotifier {
  final List<Map<String, dynamic>> fromGateway = [];

  @override
  AsyncValue<PersonaSettings> build() => const AsyncData(
    PersonaSettings(displayTagText: 'SYS', displayTagIcon: 'icon'),
  );

  @override
  void updateFromGateway(Map<String, dynamic> data) => fromGateway.add(data);
}

void main() {
  late ProviderContainer container;
  late _RecordingChatViewModel chat;
  late _RecordingMyPersonas mine;
  late _RecordingPersonaSettings settings;
  late Map<String, int> lookups;
  late Ref ref;
  late FluxerDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    chat = _RecordingChatViewModel();
    mine = _RecordingMyPersonas();
    settings = _RecordingPersonaSettings();
    lookups = <String, int>{};
    db = FluxerDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    container = ProviderContainer(
      overrides: [
        fluxerDatabaseProvider.overrideWithValue(db),
        currentUserIdProvider.overrideWithValue('me'),
        chatViewModelProvider.overrideWith(() => chat),
        myPersonasProvider.overrideWith(() => mine),
        personaSettingsProvider.overrideWith(() => settings),
        publicPersonaProvider.overrideWith((ref, key) {
          final String id = '${key.userId}:${key.personaId}';
          lookups[id] = (lookups[id] ?? 0) + 1;
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);
    final Provider<Ref> probe = Provider<Ref>((ref) => ref);
    container.listen(probe, (_, _) {});
    ref = container.read(probe);
    container
      ..read(chatViewModelProvider)
      ..read(myPersonasProvider)
      ..read(personaSettingsProvider);
    ChannelPersonaMentionCache.instance.clear();
    addTearDown(ChannelPersonaMentionCache.instance.clear);
  });

  Future<void> lookUp(String userId, String personaId) async {
    final key = (userId: userId, personaId: personaId);
    container.listen(publicPersonaProvider(key), (_, _) {});
    await container.read(publicPersonaProvider(key).future);
  }

  // The handler keeps the persona without waiting; wait for it here.
  Future<String> keptName(String personaId) async =>
      (await (db.select(db.knownPersonas)..where((t) => t.id.equals(personaId)))
              .watchSingleOrNull()
              .firstWhere((KnownPersona? row) => row != null)
              .timeout(const Duration(seconds: 10)))!
          .name;

  void handle(String eventType, Object? data) =>
      handlePersonaGatewayEvent(ref, eventType, data, sessionUserId: 'me');

  group("a community member's personas changing", () {
    test('renames their messages and looks the persona up again', () async {
      await lookUp('u2', 'p9');
      ChannelPersonaMentionCache.instance
        ..setChannelPersonas('in-g1', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p9'},
        ], guildId: 'g1')
        ..setChannelPersonas('in-g2', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p8'},
        ], guildId: 'g2');

      handle('GUILD_PERSONAS_DIRTY', <String, dynamic>{
        'guild_id': 'g1',
        'user_id': 'u2',
        'action': 'update',
        'persona': <String, dynamic>{
          'id': 'p9',
          'name': 'Bob',
          'avatar_hash': 'b0b',
          'display_tag_text': 'TAG',
        },
      });
      await lookUp('u2', 'p9');

      expect(chat.personaUpdates, [
        (
          personaId: 'p9',
          name: 'Bob',
          avatar: 'b0b',
          tag: 'TAG',
          tagIcon: null,
        ),
      ]);
      expect(lookups['u2:p9'], 2);
      expect(
        ChannelPersonaMentionCache.instance.cachedItems.map((p) => p['id']),
        <String>['p8'],
      );
      expect(await keptName('p9'), 'Bob');
    });

    test('leaves the messages of a deleted persona as they were', () async {
      await lookUp('u2', 'p9');

      handle('GUILD_PERSONAS_DIRTY', <String, dynamic>{
        'guild_id': 'g1',
        'user_id': 'u2',
        'action': 'delete',
        'persona_id': 'p9',
      });
      await lookUp('u2', 'p9');

      expect(chat.personaUpdates, isEmpty);
      expect(lookups['u2:p9'], 2);
    });
  });

  test('takes the persona another session selected in a channel', () {
    handle('USER_PERSONA_CHANNEL_STATE_UPDATE', <String, dynamic>{
      'channel_id': 'c1',
      'persona_id': 'p1',
    });
    expect(container.read(activePersonaProvider).channelPersonaIds, {
      'c1': 'p1',
    });

    handle('USER_PERSONA_CHANNEL_STATE_UPDATE', <String, dynamic>{
      'channel_id': 'c1',
      'persona_id': null,
    });
    expect(container.read(activePersonaProvider).channelPersonaIds, isEmpty);
  });

  test('applies new persona settings and their display tag', () {
    handle('USER_PERSONA_SETTINGS_UPDATE', <String, dynamic>{
      'display_tag_text': 'NEW',
      'display_tag_icon': 'new-icon',
    });

    expect(settings.fromGateway.single['display_tag_text'], 'NEW');
    expect(chat.tagUpdates, [
      (authorId: 'me', tag: 'NEW', tagIcon: 'new-icon'),
    ]);
  });

  test('drops a deleted persona from the account but leaves its messages', () {
    handle('USER_PERSONA_DELETE', <String, dynamic>{'persona_id': 'p1'});

    expect(mine.reloads, 1);
    expect(mine.removed, ['p1']);
    expect(chat.personaUpdates, isEmpty);
  });

  test(
    'keeps an edited persona of the account and renames its messages',
    () async {
      handle('USER_PERSONA_UPDATE', <String, dynamic>{
        'persona': <String, dynamic>{
          'id': 'p1',
          'user_id': 'me',
          'name': 'Ada',
          'avatar_hash': 'a1',
        },
      });

      expect(mine.upserted.single.name, 'Ada');
      expect(chat.personaUpdates, [
        (
          personaId: 'p1',
          name: 'Ada',
          avatar: 'a1',
          tag: 'SYS',
          tagIcon: 'icon',
        ),
      ]);
      expect(await keptName('p1'), 'Ada');
    },
  );
}
