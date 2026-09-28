// Fork: tests the fork adds, kept out of upstream's gateway_event_handler_test.dart so that file stays as
// upstream has it.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/gateway/gateway_event_handler.dart';
import 'package:fluxer_app/features/chat/domain/message.dart' as domain;
import 'package:fluxer_dart/gateway.dart';

import '../../helpers/open_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reaction with persona', () {
    const currentUserId = '100';
    const messageId = '500';
    const channelId = '200';
    const thumbsUp = ReactionEmoji(name: '👍');

    Future<FluxerDatabase> createDatabaseWithReaction({
      required int count,
      required bool hasReacted,
      bool meRoot = false,
      List<String> personaReactions = const [],
    }) async {
      final database = openTestDatabase();
      await database.messageDao.upsertMessage(
        domain.Message(
          id: messageId,
          channelId: channelId,
          authorId: '300',
          authorName: 'author',
          content: 'hello',
          timestamp: DateTime.utc(2026, 1, 2),
          reactions: [
            domain.Reaction(
              emoji: thumbsUp.name,
              count: count,
              hasReacted: hasReacted,
              meRoot: meRoot,
              personaReactions: personaReactions,
            ),
          ],
        ).toCompanion(),
      );
      return database;
    }

    Future<domain.Reaction?> loadReaction(FluxerDatabase database) async {
      final row = await database.messageDao.getMessage(channelId, messageId);
      expect(row, isNotNull);
      final reactions = (jsonDecode(row!.reactionsJson) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      if (reactions.isEmpty) {
        return null;
      }
      return domain.Reaction.fromJson(reactions.single);
    }

    test('adds persona reaction via MessageReactionAddEvent', () async {
      final database = await createDatabaseWithReaction(
        count: 1,
        hasReacted: true,
        meRoot: true,
      );

      final handler = GatewayEventHandler(
        database: database,
        currentUserId: currentUserId,
      );

      await handler.handle(
        const MessageReactionAddEvent(
          channelId: channelId,
          messageId: messageId,
          userId: currentUserId,
          emoji: thumbsUp,
          personaId: 'persona_1',
        ),
      );

      final reaction = await loadReaction(database);
      expect(reaction, isNotNull);
      expect(reaction!.count, 2);
      expect(reaction.meRoot, isTrue);
      expect(reaction.personaReactions, equals(['persona_1']));
      expect(reaction.hasReacted, isTrue);
    });

    test(
      'removes persona reaction preserving root reaction via MessageReactionRemoveEvent',
      () async {
        final database = await createDatabaseWithReaction(
          count: 2,
          hasReacted: true,
          meRoot: true,
          personaReactions: const ['persona_1'],
        );

        final handler = GatewayEventHandler(
          database: database,
          currentUserId: currentUserId,
        );

        await handler.handle(
          const MessageReactionRemoveEvent(
            channelId: channelId,
            messageId: messageId,
            userId: currentUserId,
            emoji: thumbsUp,
            personaId: 'persona_1',
          ),
        );

        final reaction = await loadReaction(database);
        expect(reaction, isNotNull);
        expect(reaction!.count, 1);
        expect(reaction.meRoot, isTrue);
        expect(reaction.personaReactions, isEmpty);
        expect(reaction.hasReacted, isTrue);
      },
    );

    test(
      'removes root reaction preserving persona reaction via MessageReactionRemoveEvent',
      () async {
        final database = await createDatabaseWithReaction(
          count: 2,
          hasReacted: true,
          meRoot: true,
          personaReactions: const ['persona_1'],
        );

        final handler = GatewayEventHandler(
          database: database,
          currentUserId: currentUserId,
        );

        await handler.handle(
          const MessageReactionRemoveEvent(
            channelId: channelId,
            messageId: messageId,
            userId: currentUserId,
            emoji: thumbsUp,
          ),
        );

        final reaction = await loadReaction(database);
        expect(reaction, isNotNull);
        expect(reaction!.count, 1);
        expect(reaction.meRoot, isFalse);
        expect(reaction.personaReactions, equals(['persona_1']));
        expect(reaction.hasReacted, isTrue);
      },
    );

    test(
      'skips duplicate root removal echo when meRoot is already false',
      () async {
        final database = await createDatabaseWithReaction(
          count: 1,
          hasReacted: true,
          personaReactions: const ['persona_1'],
        );

        final handler = GatewayEventHandler(
          database: database,
          currentUserId: currentUserId,
        );

        await handler.handle(
          const MessageReactionRemoveEvent(
            channelId: channelId,
            messageId: messageId,
            userId: currentUserId,
            emoji: thumbsUp,
          ),
        );

        final reaction = await loadReaction(database);
        expect(reaction, isNotNull);
        expect(reaction!.count, 1);
        expect(reaction.meRoot, isFalse);
        expect(reaction.personaReactions, equals(['persona_1']));
      },
    );
  });
}
