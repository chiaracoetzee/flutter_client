// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/message_repository.dart';
import 'package:fluxer_dart/export.dart';

import '../../../helpers/open_test_database.dart';

// Fork: what a message request says about its persona.

Map<String, dynamic> _messageJson(String id) => MessageResponseSchema(
  id: id,
  channelId: 'channel-1',
  author: const UserPartialResponse(
    id: 'me',
    username: 'me',
    discriminator: '0001',
    globalName: null,
    avatar: null,
    avatarColor: null,
    flags: 0,
  ),
  type: MessageType.valueDefault,
  flags: 0,
  content: 'edited',
  timestamp: DateTime.utc(2026, 5, 6, 12),
  pinned: false,
  mentionEveryone: false,
  tts: false,
  mentions: const [],
  mentionRoles: const [],
).toJson();

/// Records each request's body as it was sent and answers with a message.
class _RecordingAdapter implements HttpClientAdapter {
  final List<String> rawBodies = <String>[];

  List<Map<String, Object?>> get bodies => <Map<String, Object?>>[
    for (final String raw in rawBodies) jsonDecode(raw) as Map<String, Object?>,
  ];

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
    rawBodies.add(utf8.decode(bytes));
    return ResponseBody.fromString(
      jsonEncode(_messageJson('m1')),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const Map<String, dynamic> _fox = <String, dynamic>{
  'id': '1546500000000000003',
  'name': 'Fox',
  'avatar': 'fox_avatar_hash',
  'bio': 'stays on the device',
};

void main() {
  late _RecordingAdapter adapter;
  late MessageRepository repo;

  setUp(() {
    adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
      ..httpClientAdapter = adapter;
    repo = MessageRepository(
      FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1'),
      dio,
      openTestDatabase(),
      'me',
    );
  });

  test(
    'a new message names its persona by id and carries nothing else of it',
    () {
      expect(
        buildMessageCreateBody(content: 'hello', personaData: _fox),
        <String, Object?>{'content': 'hello', 'persona_id': _fox['id']},
      );
      expect(buildMessageCreateBody(content: 'hello'), <String, Object?>{
        'content': 'hello',
      });
    },
  );

  test(
    'changing a message’s persona sends the id, and null for the account',
    () async {
      await repo.editMessagePersona(
        channelId: 'channel-1',
        messageId: 'm1',
        personaData: _fox,
      );
      await repo.editMessagePersona(
        channelId: 'channel-1',
        messageId: 'm1',
        personaData: null,
      );

      expect(adapter.bodies, <Map<String, Object?>>[
        <String, Object?>{'persona_id': _fox['id']},
        <String, Object?>{'persona_id': null},
      ]);
    },
  );

  test('an edit that changes the persona sends the id with the text', () async {
    await repo.editMessage(
      channelId: 'channel-1',
      messageId: 'm1',
      content: 'edited',
      personaData: _fox,
      updatePersona: true,
    );

    expect(adapter.bodies.single, <String, Object?>{
      'content': 'edited',
      'persona_id': _fox['id'],
    });
  });

  test('an edit that leaves the persona alone says nothing about it', () async {
    await repo.editMessage(
      channelId: 'channel-1',
      messageId: 'm1',
      content: 'edited',
    );

    // This path goes through the SDK, which sends a form and not JSON. The
    // form has a part for every field the SDK knows, empty when unset; the
    // server reads only the text from it, so the persona is left alone.
    expect(adapter.rawBodies.single, contains('edited'));
    expect(adapter.rawBodies.single, isNot(contains('persona_id')));
  });
}
