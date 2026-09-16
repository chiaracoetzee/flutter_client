// Fork: tests the fork adds, kept out of upstream's message_grouping_utils_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/utils/messages/message_grouping_utils.dart';

Message _message({
  required String id,
  required String authorId,
  required String authorName,
  String? authorAvatar,
  bool authorIsBot = false,
  String? webhookId,
  DateTime? timestamp,
  int flags = 0,
  int type = messageTypeDefault,
  String? replyToId,
  bool mentionEveryone = false,
  List<String> mentionRoles = const <String>[],
  List<String> mentionedUserIds = const <String>[],
  List<MessageSnapshot> messageSnapshots = const <MessageSnapshot>[],
  MessageReference? messageReference,
  String? personaId,
  String? personaName,
  String? personaAvatar,
  String? personaTag,
}) {
  return Message(
    id: id,
    channelId: 'channel',
    authorId: authorId,
    authorName: authorName,
    authorAvatar: authorAvatar,
    authorIsBot: authorIsBot,
    webhookId: webhookId,
    content: 'hello',
    timestamp: timestamp ?? DateTime.utc(2026, 1, 1, 12),
    flags: flags,
    type: type,
    replyToId: replyToId,
    mentionEveryone: mentionEveryone,
    mentionRoles: mentionRoles,
    mentionedUserIds: mentionedUserIds,
    messageSnapshots: messageSnapshots,
    messageReference: messageReference,
    personaId: personaId,
    personaName: personaName,
    personaAvatar: personaAvatar,
    personaTag: personaTag,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shouldGroupMessages', () {
    test('does not group when transitioning from root account to persona', () {
      final Message first = _message(
        id: '1',
        authorId: 'user',
        authorName: 'Alice',
      );
      final Message second = _message(
        id: '2',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaTag: 'SYS',
        timestamp: DateTime.utc(2026, 1, 1, 12, 1),
      );
      expect(shouldGroupMessages(second, first), isFalse);
    });

    test(
      'does not group when transitioning from persona back to root account',
      () {
        final Message first = _message(
          id: '1',
          authorId: 'user',
          authorName: 'Alice',
          personaId: 'p1',
          personaName: 'Persona 1',
          personaTag: 'SYS',
        );
        final Message second = _message(
          id: '2',
          authorId: 'user',
          authorName: 'Alice',
          timestamp: DateTime.utc(2026, 1, 1, 12, 1),
        );
        expect(shouldGroupMessages(second, first), isFalse);
      },
    );

    test(
      'does not group consecutive messages from different personas of same user',
      () {
        final Message first = _message(
          id: '1',
          authorId: 'user',
          authorName: 'Alice',
          personaId: 'p1',
          personaName: 'Persona 1',
          personaTag: 'SYS',
        );
        final Message second = _message(
          id: '2',
          authorId: 'user',
          authorName: 'Alice',
          personaId: 'p2',
          personaName: 'Persona 2',
          personaTag: 'SYS',
          timestamp: DateTime.utc(2026, 1, 1, 12, 1),
        );
        expect(shouldGroupMessages(second, first), isFalse);
      },
    );

    test('groups consecutive messages from the same persona', () {
      final Message first = _message(
        id: '1',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaAvatar: 'avatar_1',
        personaTag: 'SYS',
      );
      final Message second = _message(
        id: '2',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaAvatar: 'avatar_1',
        personaTag: 'SYS',
        timestamp: DateTime.utc(2026, 1, 1, 12, 1),
      );
      expect(shouldGroupMessages(second, first), isTrue);
    });

    test('does not group if persona avatar differs', () {
      final Message first = _message(
        id: '1',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaAvatar: 'avatar_a',
      );
      final Message second = _message(
        id: '2',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaAvatar: 'avatar_b',
        timestamp: DateTime.utc(2026, 1, 1, 12, 1),
      );
      expect(shouldGroupMessages(second, first), isFalse);
    });

    test('does not group if persona tag differs', () {
      final Message first = _message(
        id: '1',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaTag: 'TAG_A',
      );
      final Message second = _message(
        id: '2',
        authorId: 'user',
        authorName: 'Alice',
        personaId: 'p1',
        personaName: 'Persona 1',
        personaTag: 'TAG_B',
        timestamp: DateTime.utc(2026, 1, 1, 12, 1),
      );
      expect(shouldGroupMessages(second, first), isFalse);
    });
  });
}
