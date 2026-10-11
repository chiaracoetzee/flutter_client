// Fork: tests the fork adds, kept out of upstream's forum_repository_test.dart so that file stays as
// upstream has it.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show FluxerDatabase;
import 'package:fluxer_app/features/forum/data/forum_repository.dart';
import 'package:fluxer_dart/export.dart';

import '../../helpers/open_test_database.dart';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = <RequestOptions>[];
  final List<String> bodies = <String>[];
  int status = 200;
  Object body = <String, Object?>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final List<int> sent = <int>[];
    if (requestStream != null) {
      await for (final Uint8List chunk in requestStream) {
        sent.addAll(chunk);
      }
    }
    bodies.add(utf8.decode(sent, allowMalformed: true));
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> _thread(String id, {bool archived = false}) =>
    <String, Object?>{
      'id': id,
      'guild_id': 'g1',
      'parent_id': 'f1',
      'type': 11,
      'name': 'post $id',
      'flags': 0,
      'owner_id': 'u1',
      'message_count': 2,
      'member_count': 1,
      'applied_tags': <String>['t1'],
      'thread_metadata': <String, Object?>{
        'archived': archived,
        'auto_archive_duration': 4320,
        'archive_timestamp': '2026-09-27T00:00:00.000Z',
        'locked': false,
        'create_timestamp': '2026-09-27T00:00:00.000Z',
      },
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Adapter adapter;
  late FluxerDatabase db;
  late ForumRepository repository;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    db = openTestDatabase();
    repository = ForumRepository(FluxerClient(dio), dio, db);
  });

  // Fork: personas.
  test('a post made as a persona carries it on the first message', () async {
    adapter
      ..status = 201
      ..body = _thread('p9');
    const Map<String, dynamic> fox = <String, dynamic>{
      'id': '9',
      'name': 'Fox',
    };
    await repository.createPost(
      guildId: 'g1',
      forumId: 'f1',
      draft: const ForumPostDraft(
        name: 'Title',
        content: 'bao',
        personaData: fox,
      ),
    );
    expect(
      (jsonDecode(adapter.bodies.single) as Map<String, Object?>)['message'],
      <String, Object?>{'content': 'bao', 'persona_id': '9'},
    );
  });
}
