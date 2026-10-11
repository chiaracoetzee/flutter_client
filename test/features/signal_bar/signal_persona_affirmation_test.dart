import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/signal_bar/data/signal_bar_repository.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_bar_providers.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_persona_affirmation.dart';

class _FakeRepository implements SignalBarRepository {
  List<SignalEntry> entries = <SignalEntry>[];
  final List<String> calls = <String>[];

  @override
  Future<SignalBarConfig> fetchBar() async => SignalBarConfig.empty;

  @override
  Future<({bool enabled, int barVersion, List<SignalEntry> entries})>
  fetchChannel(String channelId) async =>
      (enabled: true, barVersion: 1, entries: entries);

  @override
  Future<void> removeUser(
    String channelId,
    String signalId,
    String userId,
  ) async {}

  @override
  Future<void> activate(
    String channelId,
    String signalId, {
    String? personaId,
  }) async => calls.add('PUT $channelId $signalId ${personaId ?? '-'}');

  @override
  Future<void> deactivate(String channelId, String signalId) async {}

  @override
  Future<void> reset(String channelId, String signalId) async {}
}

SignalEntry _ownEntry({String? personaId}) =>
    SignalEntry.fromJson(<String, dynamic>{
      'signal_id': 'reading',
      'user': const <String, dynamic>{'id': 'me', 'username': 'me'},
      'persona_id': personaId,
      'subprofile': personaId == null
          ? null
          : <String, dynamic>{'id': personaId, 'name': 'Kitsune'},
      'activated_at': 0,
    });

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository();
    container = ProviderContainer(
      overrides: [
        signalBarRepositoryProvider.overrideWithValue(repository),
        currentUserIdProvider.overrideWithValue('me'),
      ],
    );
    addTearDown(container.dispose);
  });

  List<SignalEntry> entries(String channelId) =>
      container.read(channelSignalsProvider)[channelId] ?? const [];

  Future<void> load(String channelId) =>
      container.read(channelSignalsProvider.notifier).loadChannel(channelId);

  test('a persona payload puts that persona on the own signals', () async {
    repository.entries = <SignalEntry>[_ownEntry()];
    await load('c');

    affirmSignalPersonaData(container.read, 'c', const <String, dynamic>{
      'id': '9',
      'name': 'Kitsune',
      'avatar': 'hash',
    });

    expect(repository.calls, ['PUT c reading 9']);
    expect(entries('c').single.personaId, '9');
    expect(entries('c').single.displayName, 'Kitsune');
  });

  test('no payload means the account itself', () async {
    repository.entries = <SignalEntry>[_ownEntry(personaId: '9')];
    await load('c');

    affirmSignalPersonaData(container.read, 'c', null);

    expect(repository.calls, ['PUT c reading -']);
    expect(entries('c').single.personaId, isNull);
  });

  test('a persona object works the same way', () async {
    repository.entries = <SignalEntry>[_ownEntry()];
    await load('c');

    affirmSignalPersona(
      container.read,
      'c',
      const Persona(id: '9', name: 'Kitsune'),
    );

    expect(repository.calls, ['PUT c reading 9']);
  });

  test(
    'a composer with no channel yet, such as a new thread, changes nothing',
    () async {
      repository.entries = <SignalEntry>[_ownEntry()];
      await load('c');

      affirmSignalPersona(
        container.read,
        '',
        const Persona(id: '9', name: 'Kitsune'),
      );

      expect(repository.calls, isEmpty);
      expect(entries('c').single.personaId, isNull);
    },
  );
}
