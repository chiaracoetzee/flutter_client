// Fork: tests the fork adds, kept out of upstream's message_repository_test.dart so that file stays as
// upstream has it.
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/message_repository.dart';
import 'package:fluxer_dart/export.dart';

import '../../../helpers/open_test_database.dart';

class _ReactionAdapter implements HttpClientAdapter {
  String? requestedPath;
  String? requestedMethod;
  dynamic requestedBody;
  Map<String, dynamic>? requestedQueryParams;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPath = options.uri.path;
    requestedMethod = options.method;
    requestedQueryParams = options.uri.queryParameters;
    requestedBody = options.data;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('addReaction sends persona_id in request body when provided', () async {
    final db = openTestDatabase();
    final adapter = _ReactionAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
      ..httpClientAdapter = adapter;
    final client = FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1');
    final repo = MessageRepository(client, dio, db, 'me');

    await repo.addReaction(
      channelId: 'chan-1',
      messageId: 'msg-1',
      emoji: '👍',
      personaId: 'p_bob',
    );

    expect(adapter.requestedMethod, 'PUT');
    expect(adapter.requestedPath, contains('/reactions/'));
    expect(adapter.requestedBody, {'persona_id': 'p_bob'});
  });

  test(
    'addReaction sends an empty body when personaId is null (root user)',
    () async {
      final db = openTestDatabase();
      final adapter = _ReactionAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
        ..httpClientAdapter = adapter;
      final client = FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1');
      final repo = MessageRepository(client, dio, db, 'me');

      await repo.addReaction(
        channelId: 'chan-1',
        messageId: 'msg-1',
        emoji: '👍',
      );

      expect(adapter.requestedMethod, 'PUT');
      expect(adapter.requestedBody, <String, dynamic>{});
    },
  );

  test(
    'removeReaction passes persona_id query parameter when provided',
    () async {
      final db = openTestDatabase();
      final adapter = _ReactionAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
        ..httpClientAdapter = adapter;
      final client = FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1');
      final repo = MessageRepository(client, dio, db, 'me');

      await repo.removeReaction(
        channelId: 'chan-1',
        messageId: 'msg-1',
        emoji: '👍',
        personaId: 'p_bob',
      );

      expect(adapter.requestedMethod, 'DELETE');
      expect(adapter.requestedQueryParams, {'persona_id': 'p_bob'});
    },
  );

  test(
    'removeReaction defaults to persona_id "0" when personaId is null (root user)',
    () async {
      final db = openTestDatabase();
      final adapter = _ReactionAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
        ..httpClientAdapter = adapter;
      final client = FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1');
      final repo = MessageRepository(client, dio, db, 'me');

      await repo.removeReaction(
        channelId: 'chan-1',
        messageId: 'msg-1',
        emoji: '👍',
      );

      expect(adapter.requestedMethod, 'DELETE');
      expect(adapter.requestedQueryParams, {'persona_id': '0'});
    },
  );
}
