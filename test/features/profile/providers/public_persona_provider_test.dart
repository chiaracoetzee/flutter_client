// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';

FluxerDatabase _memoryDatabase() {
  final FluxerDatabase db = FluxerDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

class _MockDioAdapter implements HttpClientAdapter {
  _MockDioAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio _createMockDio(ResponseBody Function(RequestOptions options) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'))
    ..httpClientAdapter = _MockDioAdapter(handler);
  return dio;
}

void main() {
  group('publicPersonaProvider', () {
    test('returns null when userId or personaId is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result1 = await container.read(
        publicPersonaProvider((userId: '', personaId: 'p1')).future,
      );
      expect(result1, isNull);

      final result2 = await container.read(
        publicPersonaProvider((userId: 'u1', personaId: '')).future,
      );
      expect(result2, isNull);
    });

    test('fetches and deserializes PublicPersona when API succeeds', () async {
      final dio = _createMockDio((options) {
        expect(options.path, '/users/u_123/personas/p_456');
        final responseData = {
          'id': 'p_456',
          'name': 'Public Alter',
          'pronouns': 'they/them',
          'bio': 'A public persona bio',
          'color': 0xFF00FF,
          'persona_tags': [
            {'prefix': 'pub:', 'suffix': ''},
          ],
        };
        return ResponseBody.fromString(
          jsonEncode(responseData),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final FluxerDatabase db = _memoryDatabase();
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
          fluxerDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u_123', personaId: 'p_456')).future,
      );
      // Fork: kept, so it is not asked for again (known_personas.dart).
      final KnownPersona? kept =
          await (db.select(db.knownPersonas)
                ..where((t) => t.id.equals('p_456')))
              .watchSingleOrNull()
              .firstWhere((KnownPersona? row) => row != null)
              .timeout(const Duration(seconds: 10));
      expect(kept?.name, 'Public Alter');

      expect(result, isNotNull);
      expect(result?.id, 'p_456');
      expect(result?.name, 'Public Alter');
      expect(result?.pronouns, 'they/them');
      expect(result?.bio, 'A public persona bio');
      expect(result?.color, 0xFF00FF);
      expect(result?.personaTags.first.prefix, 'pub:');
    });

    test('returns null when API returns an error', () async {
      final dio = _createMockDio((options) {
        return ResponseBody.fromString(
          '{"error": "not found"}',
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = ProviderContainer(
        overrides: [fluxerDioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u_123', personaId: 'p_456')).future,
      );

      expect(result, isNull);
    });
  });

  group('personaProfilePrivateProvider', () {
    ResponseBody jsonBody(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    ProviderContainer containerFor(
      ResponseBody Function(RequestOptions options) handler,
    ) {
      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(_createMockDio(handler)),
          fluxerDatabaseProvider.overrideWithValue(_memoryDatabase()),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('is true when the server refuses the profile as private', () async {
      final container = containerFor(
        (options) => jsonBody({'code': 'PRIVATE_PERSONA'}, 403),
      );
      const key = (userId: 'u_private', personaId: 'p_private');

      expect(await container.read(publicPersonaProvider(key).future), isNull);
      expect(
        await container.read(personaProfilePrivateProvider(key).future),
        isTrue,
      );
    });

    test(
      'is false for a profile that is given, unknown or otherwise refused',
      () async {
        final container = containerFor((options) {
          if (options.path.endsWith('/p_public')) {
            return jsonBody({'id': 'p_public', 'name': 'Fox'}, 200);
          }
          if (options.path.endsWith('/p_unknown')) {
            return jsonBody({'code': 'UNKNOWN_PERSONA'}, 404);
          }
          return jsonBody({'code': 'MISSING_ACCESS'}, 403);
        });

        for (final personaId in ['p_public', 'p_unknown', 'p_refused']) {
          expect(
            await container.read(
              personaProfilePrivateProvider((
                userId: 'u_other',
                personaId: personaId,
              )).future,
            ),
            isFalse,
            reason: personaId,
          );
        }
      },
    );

    test('follows the profile when it is fetched again', () async {
      var isPrivate = true;
      final container = containerFor(
        (options) => isPrivate
            ? jsonBody({'code': 'PRIVATE_PERSONA'}, 403)
            : jsonBody({'id': 'p_1', 'name': 'Fox', 'bio': 'Now shown'}, 200),
      );
      const key = (userId: 'u_changes', personaId: 'p_1');

      expect(
        await container.read(personaProfilePrivateProvider(key).future),
        isTrue,
      );

      isPrivate = false;
      container.invalidate(publicPersonaProvider(key));

      expect(
        await container.read(personaProfilePrivateProvider(key).future),
        isFalse,
      );
      expect(
        (await container.read(publicPersonaProvider(key).future))?.bio,
        'Now shown',
      );
    });
  });
}
