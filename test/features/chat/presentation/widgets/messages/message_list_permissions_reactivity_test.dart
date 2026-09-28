import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart' show FluxerDatabase;
import 'package:fluxer_app/core/permissions/channel_permission_cache_provider.dart';
import 'package:fluxer_app/core/permissions/permission.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_item.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list.dart';

import '../../../../../helpers/open_test_database.dart';

int _bits(List<Permission> permissions) =>
    permissions.fold<int>(0, (acc, p) => acc | p.value);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FluxerDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('MessageListSettingsLayer permission reactivity', () {
    testWidgets(
      'reactively updates canAddReactions and canPinMessage when cache populates',
      (WidgetTester tester) async {
        const String testChannelId = 'test-guild-channel-1';
        bool? currentCanAddReactions;
        bool? currentCanPinMessage;

        final container = ProviderContainer(
          overrides: [
            fluxerDatabaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: MessageListSettingsLayer(
                channelId: testChannelId,
                isDmChannel: false,
                channelPermissionBits: null,
                builder: (
                  BuildContext context,
                  MessageRenderSettings settings,
                  String? guildId, {
                  required bool isGuildSendDisabled,
                  required ({
                    bool canSendMessages,
                    bool canAddReactions,
                    bool canPinMessage,
                    bool canManageMessages,
                  })
                  channelActions,
                }) {
                  currentCanAddReactions = channelActions.canAddReactions;
                  currentCanPinMessage = channelActions.canPinMessage;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // On initial build without cached bits, reactions and pin are false
        expect(currentCanAddReactions, isFalse);
        expect(currentCanPinMessage, isFalse);

        // Now populate the permission cache with addReactions and pinMessages
        final int resolvedBits = _bits([
          Permission.viewChannel,
          Permission.sendMessages,
          Permission.addReactions,
          Permission.pinMessages,
        ]);

        container
            .read(channelPermissionCacheProvider.notifier)
            .cacheEffectiveBits(
              channelId: testChannelId,
              outcome: (value: resolvedBits, shouldCache: true),
            );

        // Pump a frame to allow Riverpod reactive notification to settle
        await tester.pump();

        // The settings layer must have reactively updated!
        expect(currentCanAddReactions, isTrue);
        expect(currentCanPinMessage, isTrue);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });

  group('ChannelPermissionCache in-flight deduplication', () {
    test('deduplicates concurrent rebuildChannel calls', () async {
      final container = ProviderContainer(
        overrides: [
          fluxerDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(channelPermissionCacheProvider.notifier);
      final future1 = notifier.rebuildChannel('c-concurrent-1');
      final future2 = notifier.rebuildChannel('c-concurrent-1');

      expect(identical(future1, future2), isTrue);
      await future1;
    });
  });
}
