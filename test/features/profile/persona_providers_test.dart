import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDioAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('p_error')) {
      return ResponseBody.fromString(
        'error',
        500,
        headers: {
          Headers.contentTypeHeader: [Headers.textPlainContentType],
        },
      );
    }
    if (options.path.contains('/personas/p123')) {
      return ResponseBody.fromString(
        '{"id": "p123", "name": "Public Persona Test", "user_id": "u1"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    final body = options.path.contains('settings') ? '{}' : '[]';
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _createMockDio() {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'));
  dio.httpClientAdapter = _MockDioAdapter();
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PersonaMode', () {
    test('fromString parses valid strings and falls back to manual', () {
      expect(PersonaMode.fromString('manual'), PersonaMode.manual);
      expect(PersonaMode.fromString('last'), PersonaMode.last);
      expect(PersonaMode.fromString('off'), PersonaMode.manual);
      expect(PersonaMode.fromString(null), PersonaMode.manual);
      expect(PersonaMode.fromString('invalid'), PersonaMode.manual);
    });

    test('toPrefString returns name matching enum identifier', () {
      expect(PersonaMode.manual.toPrefString(), 'manual');
      expect(PersonaMode.last.toPrefString(), 'last');
    });
  });

  group('ActivePersonaState', () {
    test('default constructor initializes expected defaults', () {
      const state = ActivePersonaState();
      expect(state.mode, PersonaMode.manual);
      expect(state.activePersonaId, isNull);
      expect(state.isLatched, isFalse);
      expect(state.frecencyUsage, isEmpty);
    });

    test('copyWith modifies specified fields and allows null clearing', () {
      const state = ActivePersonaState(
        mode: PersonaMode.manual,
        activePersonaId: 'p1',
        isLatched: true,
      );

      final updated = state.copyWith(
        mode: PersonaMode.last,
        isLatched: false,
      );
      expect(updated.mode, PersonaMode.last);
      expect(updated.activePersonaId, 'p1');
      expect(updated.isLatched, isFalse);

      final cleared = state.copyWith(activePersonaId: () => null);
      expect(cleared.activePersonaId, isNull);
      expect(cleared.mode, PersonaMode.manual);
    });
  });

  group('SystemDisplayTag', () {
    test('reports empty when text and iconUrl are absent or blank', () {
      const emptyTag = SystemDisplayTag();
      expect(emptyTag.isEmpty, isTrue);
      expect(emptyTag.isNotEmpty, isFalse);

      const blankTag = SystemDisplayTag(text: '', iconUrl: '');
      expect(blankTag.isEmpty, isTrue);
      expect(blankTag.isNotEmpty, isFalse);
    });

    test('reports not empty when text or iconUrl is present', () {
      const tagWithText = SystemDisplayTag(text: 'Wonderland');
      expect(tagWithText.isEmpty, isFalse);
      expect(tagWithText.isNotEmpty, isTrue);

      const tagWithIcon = SystemDisplayTag(iconUrl: 'icon_hash');
      expect(tagWithIcon.isEmpty, isFalse);
      expect(tagWithIcon.isNotEmpty, isTrue);
    });
  });

  group('MyPersonasNotifier', () {
    test('upsertPersona, removePersona, and reset modify state in memory', () {
      final dio = _createMockDio();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(myPersonasProvider.notifier);
      notifier.reset();
      expect(container.read(myPersonasProvider).asData?.value, isEmpty);

      const p1 = Persona(id: 'p1', name: 'Alice');
      notifier.upsertPersona(p1);
      expect(container.read(myPersonasProvider).asData?.value, [p1]);

      const p1Updated = Persona(id: 'p1', name: 'Alice Updated');
      notifier.upsertPersona(p1Updated);
      expect(container.read(myPersonasProvider).asData?.value, [p1Updated]);

      const p2 = Persona(id: 'p2', name: 'Bob');
      notifier.upsertPersona(p2);
      expect(container.read(myPersonasProvider).asData?.value, [p1Updated, p2]);

      notifier.removePersona('p1');
      expect(container.read(myPersonasProvider).asData?.value, [p2]);

      final p2Deleted = p2.copyWith(deletedAt: DateTime.utc(2026, 9, 25));
      notifier.upsertPersona(p2Deleted);
      expect(container.read(myPersonasProvider).asData?.value, isEmpty);

      notifier.reset();
      expect(container.read(myPersonasProvider).asData?.value, isEmpty);
    });
  });

  group('personaSortName', () {
    test('skips leading decoration but keeps accented and styled letters', () {
      expect(personaSortName('✨Alice'), 'Alice');
      expect(personaSortName('  🌙 Luna '), 'Luna');
      expect(personaSortName('[Mika]'), 'Mika]');
      expect(personaSortName('★ 2B'), '2B');
      expect(personaSortName('✨Élodie'), 'Élodie');
      expect(personaSortName('𝓐𝓶𝔂'), '𝓐𝓶𝔂');
      expect(personaSortName('Ⓑⓔⓝ'), 'Ⓑⓔⓝ');
      expect(personaSortName('✨✨'), '✨✨');
    });

    test('plain order files decorated names under their first letter', () {
      final personas = [
        for (final (index, name) in ['Zoe', '✨Bea', 'alice', '🌙 Luna'].indexed)
          Persona(id: 'p$index', name: name),
      ]..sort(comparePersonasByName);
      expect(
        personas.map((p) => p.name),
        ['alice', '✨Bea', '🌙 Luna', 'Zoe'],
      );
    });
  });

  group('sortedPersonasProvider', () {
    Future<ProviderContainer> containerWith(
      PersonaNameCollator collator,
    ) async {
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio()),
          personaNameCollatorProvider.overrideWithValue(collator),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(myPersonasProvider.notifier);
      // Let the initial load against the mock client finish first.
      await pumpEventQueue();
      notifier.reset();
      for (final (id, name) in [
        ('p1', 'mallory'),
        ('p2', 'Zed'),
        ('p3', 'alice'),
        ('p4', 'Bob'),
      ]) {
        notifier.upsertPersona(Persona(id: id, name: name));
      }
      return container;
    }

    List<String> sortedNames(ProviderContainer container) => [
          for (final p in container.read(sortedPersonasProvider)) p.name,
        ];

    test('uses the plain name order when the device cannot sort', () async {
      final container =
          await containerWith((_) async => throw StateError('none'));
      final sub = container.listen(sortedPersonasProvider, (_, _) {});
      addTearDown(sub.close);

      expect(sortedNames(container), ['alice', 'Bob', 'mallory', 'Zed']);
      await pumpEventQueue();
      expect(sortedNames(container), ['alice', 'Bob', 'mallory', 'Zed']);
      expect(
        container.read(myPersonasProvider).asData?.value.map((p) => p.name),
        ['mallory', 'Zed', 'alice', 'Bob'],
      );
    });

    test('adopts the device order once it arrives', () async {
      final container =
          await containerWith((_) async => ['p2', 'p4', 'p1', 'p3']);
      final sub = container.listen(sortedPersonasProvider, (_, _) {});
      addTearDown(sub.close);

      expect(sortedNames(container), ['alice', 'Bob', 'mallory', 'Zed']);
      await pumpEventQueue();
      expect(sortedNames(container), ['Zed', 'Bob', 'mallory', 'alice']);
    });

    test('falls back while a new persona is missing from the device order',
        () async {
      var calls = 0;
      final container = await containerWith((personas) async {
        calls++;
        return calls == 1
            ? ['p2', 'p4', 'p1', 'p3']
            : throw StateError('none');
      });
      final sub = container.listen(sortedPersonasProvider, (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();

      container
          .read(myPersonasProvider.notifier)
          .upsertPersona(const Persona(id: 'p5', name: 'Carol'));
      await pumpEventQueue();

      expect(
        sortedNames(container),
        ['alice', 'Bob', 'Carol', 'mallory', 'Zed'],
      );
    });
  });

  group('ActivePersonaNotifier', () {
    test('syncFromSettings updates active persona and latch state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activePersonaProvider.notifier);
      notifier.syncFromSettings(
        mode: PersonaMode.last,
        activeId: 'p123',
        isLatched: true,
      );

      final state = container.read(activePersonaProvider);
      expect(state.mode, PersonaMode.last);
      expect(state.activePersonaId, 'p123');
      expect(state.isLatched, isTrue);
    });
  });

  group('PersonaSettingsNotifier', () {
    test('updateFromGateway updates PersonaSettings state', () {
      final dio = _createMockDio();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(personaSettingsProvider.notifier);
      notifier.updateFromGateway({
        'user_id': 'u100',
        'active_persona_mode': 'last',
        'active_persona_id': 'p200',
        'is_latched': true,
        'display_tag_text': 'Wonderland',
        'display_tag_icon': 'hash_xyz',
      });

      final settings = container.read(personaSettingsProvider).asData?.value;
      expect(settings, isNotNull);
      expect(settings!.userId, 'u100');
      expect(settings.activePersonaMode, 'last');
      expect(settings.activePersonaId, 'p200');
      expect(settings.isLatched, isTrue);
      expect(settings.displayTagText, 'Wonderland');
      expect(settings.displayTagIcon, 'hash_xyz');

      final tag = container.read(systemDisplayTagProvider);
      expect(tag.text, 'Wonderland');
      expect(tag.iconUrl, 'hash_xyz');

      notifier.reset();
      final resetSettings = container.read(personaSettingsProvider).asData?.value;
      expect(resetSettings, isNotNull);
      expect(resetSettings!.userId, '');
      expect(resetSettings.activePersonaMode, 'manual');
      expect(resetSettings.isLatched, isFalse);
    });
  });

  group('publicPersonaProvider', () {
    test('returns null when userId or personaId is empty', () async {
      final dio = _createMockDio();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final emptyUser = await container.read(
        publicPersonaProvider((userId: '', personaId: 'p1')).future,
      );
      expect(emptyUser, isNull);

      final emptyPersona = await container.read(
        publicPersonaProvider((userId: 'u1', personaId: '')).future,
      );
      expect(emptyPersona, isNull);
    });

    test('resolves PublicPersona on successful response', () async {
      final dio = _createMockDio();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u1', personaId: 'p123')).future,
      );
      expect(result, isNotNull);
      expect(result!.id, 'p123');
      expect(result.name, 'Public Persona Test');
    });

    test('returns null on dio failure without throwing', () async {
      final dio = _createMockDio();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u1', personaId: 'p_error')).future,
      );
      expect(result, isNull);
    });
  });
}
