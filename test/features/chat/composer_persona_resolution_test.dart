// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_persona_resolution.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDioAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
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

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._initial);
  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncValue.data(_initial);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bob = Persona(
    id: 'persona_bob',
    name: 'Bob the Fox',
    personaTags: [
      PersonaTag(prefix: 'B:'),
    ],
  );

  const alice = Persona(
    id: 'persona_alice',
    name: 'Alice',
    personaTags: [
      PersonaTag(prefix: 'A:'),
    ],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sends as latched persona for normal text', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio()),
          myPersonasProvider.overrideWith(
            () => _FakeMyPersonasNotifier([bob, alice]),
          ),
          activePersonaProvider.overrideWith(
            ActivePersonaNotifier.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Latch Bob in manual mode
    await capturedRef.read(activePersonaProvider.notifier).setActivePersona(
          bob.id,
          latch: true,
          mode: PersonaMode.manual,
        );

    final res = await resolveOutgoingPersona(
      ref: capturedRef,
      rawText: 'bao',
      channelId: 'test_channel',
    );

    expect(res.text, 'bao');
    expect(res.personaData, isNotNull);
    expect(res.personaData!['id'], bob.id);
    expect(res.wasEscaped, isFalse);
    expect(capturedRef.read(activePersonaProvider).isLatched, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('escapes to root account with single backslash while preserving latch in manual mode', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio()),
          myPersonasProvider.overrideWith(
            () => _FakeMyPersonasNotifier([bob, alice]),
          ),
          activePersonaProvider.overrideWith(
            ActivePersonaNotifier.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Latch Bob in manual mode
    await capturedRef.read(activePersonaProvider.notifier).setActivePersona(
          bob.id,
          latch: true,
          mode: PersonaMode.manual,
        );

    final res = await resolveOutgoingPersona(
      ref: capturedRef,
      rawText: r'\test',
      channelId: 'test_channel',
    );

    expect(res.text, 'test');
    expect(res.personaData, isNull);
    expect(res.wasEscaped, isTrue);
    expect(res.clearedLatch, isFalse);
    // Bob should still be latched for subsequent messages
    expect(capturedRef.read(activePersonaProvider).isLatched, isTrue);
    expect(capturedRef.read(activePersonaProvider).activePersonaId, bob.id);
    await tester.pumpAndSettle();
  });

  testWidgets('escapes to root account with double backslash and unlatches', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio()),
          myPersonasProvider.overrideWith(
            () => _FakeMyPersonasNotifier([bob, alice]),
          ),
          activePersonaProvider.overrideWith(
            ActivePersonaNotifier.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Latch Bob in manual mode
    await capturedRef.read(activePersonaProvider.notifier).setActivePersona(
          bob.id,
          latch: true,
          mode: PersonaMode.manual,
        );

    final res = await resolveOutgoingPersona(
      ref: capturedRef,
      rawText: r'\\test',
      channelId: 'test_channel',
    );

    expect(res.text, 'test');
    expect(res.personaData, isNull);
    expect(res.wasEscaped, isTrue);
    expect(res.clearedLatch, isTrue);
    // Bob should now be unlatched
    expect(capturedRef.read(activePersonaProvider).isLatched, isFalse);
    expect(capturedRef.read(activePersonaProvider).activePersonaId, isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('matches persona tag over latched persona', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio()),
          myPersonasProvider.overrideWith(
            () => _FakeMyPersonasNotifier([bob, alice]),
          ),
          activePersonaProvider.overrideWith(
            ActivePersonaNotifier.new,
          ),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            capturedRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Latch Bob
    await capturedRef.read(activePersonaProvider.notifier).setActivePersona(
          bob.id,
          latch: true,
          mode: PersonaMode.manual,
        );

    final res = await resolveOutgoingPersona(
      ref: capturedRef,
      rawText: 'A: hello from Alice',
      channelId: 'test_channel',
    );

    expect(res.text, 'hello from Alice');
    expect(res.personaData, isNotNull);
    expect(res.personaData!['id'], alice.id);
    await tester.pumpAndSettle();
  });
}
