// Fork: tests the fork adds, kept out of upstream's quick_switcher_result_generators_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/dm/domain/dm_conversation.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_candidate_builder.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_result_generators.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_build_input.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_candidate.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_types.dart';

import '../../../helpers/test_l10n.dart';
import 'quick_switcher_result_generators_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickSwitcherChannelResolver', () {
    test('resolves a recent personal notes visit', () {
      final FluxerLocalizations l10n = testL10n;
      final QuickSwitcherResult? result = forkUpstream
          .resolver(
            l10n: l10n,
            conversations: <DmConversation>[
              DmConversation(
                id: '1',
                type: ChannelType.dmPersonalNotes.wireValue,
                recipientId: '1',
                recipientName: '',
                lastMessage: '',
                lastMessageTime: DateTime(2026),
              ),
            ],
          )
          .resultForChannelId('1');

      expect(result, isA<QuickSwitcherUserResult>());
      final QuickSwitcherUserResult userResult =
          result! as QuickSwitcherUserResult;
      expect(userResult.isPersonalNotes, isTrue);
      expect(userResult.title, l10n.personalNotesTitle);
      expect(userResult.dmChannelId, '1');
    });
  });

  group('buildQuickSwitcherCandidateSets', () {
    test('includes personal notes without a local conversation row', () {
      final FluxerLocalizations l10n = testL10n;
      final QuickSwitcherCandidateSets sets = buildQuickSwitcherCandidateSets(
        QuickSwitcherBuildInput(
          l10n: l10n,
          currentUserId: '1',
          conversations: const [],
          friends: const [],
          guildChannels: const <Channel>[],
          guilds: const <Guild>[],
          guildMembers: const [],
          hasFavorites: false,
        ),
      );

      expect(sets.users, hasLength(1));
      expect(sets.users.single.isPersonalNotes, isTrue);
      expect(sets.users.single.dmChannelId, '1');

      final List<QuickSwitcherResult> results =
          generateQuickSwitcherGeneralResults(
            search: 'notes',
            sets: sets,
            l10n: l10n,
          );

      expect(results, hasLength(2));
      final QuickSwitcherUserResult result =
          results.last as QuickSwitcherUserResult;
      expect(result.title, l10n.personalNotesTitle);
      expect(result.isPersonalNotes, isTrue);
    });

    test('omits personal notes when direct messages are disabled', () {
      final QuickSwitcherCandidateSets sets = buildQuickSwitcherCandidateSets(
        QuickSwitcherBuildInput(
          l10n: testL10n,
          currentUserId: '1',
          conversations: const [],
          friends: const [],
          guildChannels: const <Channel>[],
          guilds: const <Guild>[],
          guildMembers: const [],
          hasFavorites: false,
          directMessagesDisabled: true,
        ),
      );

      expect(sets.users, isEmpty);
    });
  });
}
