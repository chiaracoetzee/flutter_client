import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_dart/export.dart';

Map<String, Object?> _result({Map<String, Object?>? subprofile}) =>
    <String, Object?>{
      'id': '1550000000000000001',
      'channel_id': '1550000000000000002',
      'author': <String, Object?>{
        'id': '1550000000000000003',
        'username': 'seraphim',
        'discriminator': '0',
      },
      'content': 'pizza first',
      'timestamp': '2026-10-12T20:01:00.000Z',
      'type': 0,
      'flags': 0,
      'pinned': false,
      'mention_everyone': false,
      'mentions': <Object?>[],
      'mention_roles': <Object?>[],
      'subprofile': ?subprofile,
    };

void main() {
  test('a search result keeps the persona its message was sent as', () {
    final Message message = Message.fromSearchResult(
      MessageSearchResultsResponseMessages.fromJson(
        _result(
          subprofile: <String, Object?>{
            'id': '501',
            'name': 'Kenoma',
            'avatar': 'abc123',
            'display_tag_text': 'HS',
            'display_tag_icon': 'icon1',
          },
        ),
      ),
    );

    expect(message.personaId, '501');
    expect(message.personaName, 'Kenoma');
    expect(message.personaAvatar, 'abc123');
    expect(message.personaTag, 'HS');
    expect(message.personaTagIcon, 'icon1');
  });

  test('a search result sent as the account has no persona', () {
    final Message message = Message.fromSearchResult(
      MessageSearchResultsResponseMessages.fromJson(_result()),
    );

    expect(message.personaId, isNull);
    expect(message.personaName, isNull);
  });
}
