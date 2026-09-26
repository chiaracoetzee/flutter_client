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
    test('fromString parses valid strings and falls back to off', () {
      expect(PersonaMode.fromString('manual'), PersonaMode.manual);
      expect(PersonaMode.fromString('last'), PersonaMode.last);
      expect(PersonaMode.fromString('off'), PersonaMode.off);
      expect(PersonaMode.fromString(null), PersonaMode.off);
      expect(PersonaMode.fromString('invalid'), PersonaMode.off);
    });

    test('toPrefString returns name matching enum identifier', () {
      expect(PersonaMode.off.toPrefString(), 'off');
      expect(PersonaMode.manual.toPrefString(), 'manual');
      expect(PersonaMode.last.toPrefString(), 'last');
    });
  });

  group('ActivePersonaState', () {
    test('default constructor initializes expected defaults', () {
      const state = ActivePersonaState();
      expect(state.mode, PersonaMode.off);
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
      expect(resetSettings.activePersonaMode, 'off');
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
