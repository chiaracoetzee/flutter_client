import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
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

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._personas);

  final List<Persona> _personas;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_personas);
}

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

  group('the name of the persona a thread was started as', () {
    late int lookups;

    Future<String?> name({
      List<Persona> own = const <Persona>[],
      PublicPersona? looked,
    }) async {
      lookups = 0;
      final ProviderContainer names = ProviderContainer(
        overrides: [
          fluxerDatabaseProvider.overrideWithValue(db),
          myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(own)),
          publicPersonaProvider.overrideWith((ref, key) {
            lookups++;
            return looked;
          }),
        ],
      );
      addTearDown(names.dispose);
      const key = (threadId: 't1', ownerId: 'u1');
      final ProviderSubscription<AsyncValue<String?>> subscription = names
          .listen(threadOwnerPersonaNameProvider(key), (_, _) {});
      addTearDown(subscription.close);
      return names.read(threadOwnerPersonaNameProvider(key).future);
    }

    test('is null for a thread started as the account', () async {
      await store(_thread());

      expect(await name(), isNull);
      expect(lookups, 0);
    });

    test("comes from the user's own personas first", () async {
      await store(_thread(ownerPersonaId: 'p9'));

      expect(
        await name(
          own: const [Persona(id: 'p9', name: 'Mine')],
        ),
        'Mine',
      );
      expect(lookups, 0);
    });

    test('comes from a stored message the owner sent as the persona', () async {
      await store(_thread(ownerPersonaId: 'p9'));
      await db.messageDao.upsertMessages([
        MessagesCompanion.insert(
          id: 'm1',
          channelId: 't1',
          authorId: 'u1',
          content: 'hello',
          timestamp: DateTime.utc(2026),
          personaId: const Value('p9'),
          personaName: const Value('Bob'),
        ),
      ]);

      expect(await name(), 'Bob');
      expect(lookups, 0);
    });

    test('is looked up when nothing on the device names it', () async {
      await store(_thread(ownerPersonaId: 'p9'));

      expect(
        await name(
          looked: const PublicPersona(id: 'p9', name: 'Looked up'),
        ),
        'Looked up',
      );
      expect(lookups, 1);
    });

    test('is null when the lookup cannot name it either', () async {
      await store(_thread(ownerPersonaId: 'p9'));

      expect(await name(), isNull);
      expect(
        await name(
          looked: const PublicPersona(id: 'p9', name: ''),
        ),
        isNull,
      );
    });
  });
}
