import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/threads/providers/thread_owner_persona_provider.dart';
import 'package:fluxer_app/shared/utils/sdk_converters.dart';
import 'package:fluxer_dart/export.dart' hide ChannelType;

// Fork: a thread says which persona it was started as once, when it is created
// or loaded. Later updates to the thread leave the field out and must not
// clear what is stored.

Map<String, Object?> _thread({String? ownerPersonaId, String name = 'fox'}) =>
    <String, Object?>{
      'id': 't1',
      'type': 11,
      'guild_id': 'g1',
      'parent_id': 'c1',
      'owner_id': 'u1',
      'name': name,
      'owner_persona_id': ?ownerPersonaId,
    };

void main() {
  late FluxerDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = FluxerDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [fluxerDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> store(Map<String, Object?> json) => db.channelDao.upsertChannel(
    channelFromSdk(ChannelResponse.fromJson(json), 'g1'),
  );

  Future<String?> stored() async {
    // Listen so the auto-disposing provider stays alive until it has a value.
    final ProviderSubscription<AsyncValue<String?>> subscription = container
        .listen(threadOwnerPersonaIdProvider('t1'), (_, _) {});
    try {
      return await container.read(threadOwnerPersonaIdProvider('t1').future);
    } finally {
      subscription.close();
    }
  }

  test('a thread started as the account has no persona', () async {
    await store(_thread());
    expect(await stored(), isNull);
  });

  test('a thread started as a persona keeps it across later updates', () async {
    await store(_thread(ownerPersonaId: 'p9'));
    expect(await stored(), 'p9');

    await store(_thread(name: 'renamed'));
    container.invalidate(threadOwnerPersonaIdProvider('t1'));
    expect(await stored(), 'p9');
    expect((await db.channelDao.getChannelById('t1'))?.name, 'renamed');
  });
}
