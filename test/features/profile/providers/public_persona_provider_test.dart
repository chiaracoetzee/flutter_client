// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';

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
  final dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'));
  dio.httpClientAdapter = _MockDioAdapter(handler);
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

      final container = ProviderContainer(
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u_123', personaId: 'p_456')).future,
      );

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
        overrides: [
          fluxerDioProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        publicPersonaProvider((userId: 'u_123', personaId: 'p_456')).future,
      );

      expect(result, isNull);
    });
  });
}
