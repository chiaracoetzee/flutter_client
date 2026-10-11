// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/chat/providers/messages/typing_sender.dart';
import 'package:fluxer_dart/fluxer_client.dart';

/// Records what the typing request carried and answers 204.
class _RecordingAdapter implements HttpClientAdapter {
  final List<({String path, String body})> requests =
      <({String path, String body})>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final List<int> bytes = <int>[];
    if (requestStream != null) {
      await for (final Uint8List chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    requests.add((path: options.path, body: utf8.decode(bytes)));
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RecordingAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'))
      ..httpClientAdapter = adapter;
    container = ProviderContainer(
      overrides: [fluxerClientProvider.overrideWithValue(FluxerClient(dio))],
    );
    addTearDown(container.dispose);
  });

  test('typing as a persona names it by id and sends nothing else', () async {
    await container
        .read(typingSenderProvider.notifier)
        .notifyUserTyping(
          'c1',
          personaData: <String, dynamic>{
            'id': '1546500000000000003',
            'name': 'Fox',
            'avatar': 'fox_avatar_hash',
            'bio': 'stays on the device',
          },
        );

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.path, endsWith('/channels/c1/typing'));
    expect(jsonDecode(adapter.requests.single.body), <String, Object?>{
      'persona_id': '1546500000000000003',
    });
  });

  test('typing as the account sends no persona', () async {
    await container.read(typingSenderProvider.notifier).notifyUserTyping('c2');

    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.body, isNot(contains('persona_id')));
    expect(adapter.requests.single.body, isNot(contains('subprofile')));
  });

  test(
    'a change of persona is sent at once, the same persona is throttled',
    () async {
      final sender = container.read(typingSenderProvider.notifier);
      await sender.notifyUserTyping(
        'c3',
        personaData: <String, dynamic>{'id': '1'},
      );
      await sender.notifyUserTyping(
        'c3',
        personaData: <String, dynamic>{'id': '1'},
      );
      await sender.notifyUserTyping(
        'c3',
        personaData: <String, dynamic>{'id': '2'},
      );

      expect(
        adapter.requests.map((request) => jsonDecode(request.body)).toList(),
        <Object?>[
          <String, Object?>{'persona_id': '1'},
          <String, Object?>{'persona_id': '2'},
        ],
      );
    },
  );
}
