// Fork: tests the fork adds, kept out of upstream's forum_repository_test.dart so that file stays as
// upstream has it.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show FluxerDatabase;
import 'package:fluxer_app/features/forum/data/forum_repository.dart';
import 'package:fluxer_dart/export.dart';

import '../../helpers/open_test_database.dart';
import 'forum_repository_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ForkAdapter adapter;
  late FluxerDatabase db;
  late ForumRepository repository;

  setUp(() {
    adapter = ForkAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    db = openTestDatabase();
    repository = ForumRepository(FluxerClient(dio), dio, db);
  });

  // Fork: personas.
  test('a post made as a persona carries it on the first message', () async {
    adapter
      ..status = 201
      ..body = forkUpstream.thread('p9');
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
      <String, Object?>{'content': 'bao', 'subprofile': fox},
    );
  });
}
