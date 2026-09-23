import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_candidate.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_matcher.dart';

void main() {
  group('matchQuickSwitcherCandidates', () {
    final List<QuickSwitcherUserCandidate> candidates =
        <QuickSwitcherUserCandidate>[
          const QuickSwitcherUserCandidate(
            id: '1',
            title: 'Alice',
            subtitle: 'alice',
            userId: '1',
            searchValues: <String>['Alice', 'alice'],
            sortWeight: 10,
          ),
          const QuickSwitcherUserCandidate(
            id: '2',
            title: 'Bob Builder',
            subtitle: 'bob',
            userId: '2',
            searchValues: <String>['Bob Builder', 'bob'],
            sortWeight: 5,
          ),
        ];

    test('returns all candidates sorted by weight when search is empty', () {
      final List<QuickSwitcherUserCandidate> actual =
          matchQuickSwitcherCandidates(candidates, '', 10);

      expect(actual.map((QuickSwitcherUserCandidate c) => c.id).toList(), [
        '1',
        '2',
      ]);
    });

    test('filters candidates by title and subtitle', () {
      final List<QuickSwitcherUserCandidate> actual =
          matchQuickSwitcherCandidates(candidates, 'bob', 10);

      expect(actual, hasLength(1));
      expect(actual.first.id, '2');
    });

    test('ranks exact match with leading emoji above newer partial matches', () {
      final List<QuickSwitcherChannelCandidate> channelCandidates =
          <QuickSwitcherChannelCandidate>[
            const QuickSwitcherChannelCandidate(
              id: 'c1',
              title: '💬 Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c1',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['💬 Lounge', 'Temple of Seraphim'],
              sortWeight: 100, // Oldest creation time
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c2',
              title: '😶 Nonverbal Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c2',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['😶 Nonverbal Lounge', 'Temple of Seraphim'],
              sortWeight: 600, // Newest creation time
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c3',
              title: '🎀 Little Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c3',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['🎀 Little Lounge', 'Temple of Seraphim'],
              sortWeight: 500,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c4',
              title: '🎭 Plural Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c4',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['🎭 Plural Lounge', 'Temple of Seraphim'],
              sortWeight: 400,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c5',
              title: '🪽 Angel Lounge',
              subtitle: 'Seraphim (Personal)',
              channelId: 'c5',
              guildId: 'g2',
              isVoice: false,
              searchValues: <String>['🪽 Angel Lounge', 'Seraphim (Personal)'],
              sortWeight: 300,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c6',
              title: '✨ Seraphist Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c6',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['✨ Seraphist Lounge', 'Temple of Seraphim'],
              sortWeight: 200,
            ),
          ];

      final List<QuickSwitcherChannelCandidate> results =
          matchQuickSwitcherCandidates(channelCandidates, 'lounge', 100);

      // All 6 lounge channels should be returned without being cut off.
      expect(results, hasLength(6));
      // Exact match "💬 Lounge" must rank #1 despite having the lowest sortWeight.
      expect(results.first.id, 'c1');
      expect(results.first.title, '💬 Lounge');
    });

    test('strips leading symbols and hashtags for exact matching', () {
      final List<QuickSwitcherChannelCandidate> channelCandidates =
          <QuickSwitcherChannelCandidate>[
            const QuickSwitcherChannelCandidate(
              id: 'c1',
              title: '#general',
              subtitle: 'Guild',
              channelId: 'c1',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['#general'],
              sortWeight: 10,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c2',
              title: 'general-chat',
              subtitle: 'Guild',
              channelId: 'c2',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['general-chat'],
              sortWeight: 20,
            ),
          ];

      final List<QuickSwitcherChannelCandidate> results =
          matchQuickSwitcherCandidates(channelCandidates, 'general', 10);

      expect(results.first.id, 'c1');
      expect(results.first.title, '#general');
    });

    test('matches candidates by guild name in subtitle', () {
      final List<QuickSwitcherChannelCandidate> channelCandidates =
          <QuickSwitcherChannelCandidate>[
            const QuickSwitcherChannelCandidate(
              id: 'c1',
              title: 'announcements',
              subtitle: 'Temple of Seraphim',
              channelId: 'c1',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['announcements', 'Temple of Seraphim'],
              sortWeight: 10,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c2',
              title: 'other-channel',
              subtitle: 'Another Guild',
              channelId: 'c2',
              guildId: 'g2',
              isVoice: false,
              searchValues: <String>['other-channel', 'Another Guild'],
              sortWeight: 10,
            ),
          ];

      final List<QuickSwitcherChannelCandidate> results =
          matchQuickSwitcherCandidates(channelCandidates, 'temple', 10);

      expect(results, hasLength(1));
      expect(results.first.id, 'c1');
    });

    test('multi-term query matches across guild name and channel title', () {
      final List<QuickSwitcherChannelCandidate> channelCandidates =
          <QuickSwitcherChannelCandidate>[
            const QuickSwitcherChannelCandidate(
              id: 'c1',
              title: '💬 Lounge',
              subtitle: 'Temple of Seraphim',
              channelId: 'c1',
              guildId: 'g1',
              isVoice: false,
              searchValues: <String>['💬 Lounge', 'Temple of Seraphim'],
              sortWeight: 10,
            ),
            const QuickSwitcherChannelCandidate(
              id: 'c2',
              title: '🪽 Angel Lounge',
              subtitle: 'Seraphim (Personal)',
              channelId: 'c2',
              guildId: 'g2',
              isVoice: false,
              searchValues: <String>['🪽 Angel Lounge', 'Seraphim (Personal)'],
              sortWeight: 50,
            ),
          ];

      final List<QuickSwitcherChannelCandidate> results =
          matchQuickSwitcherCandidates(channelCandidates, 'temple lounge', 10);

      // Only c1 matches both 'temple' (in subtitle) and 'lounge' (in title).
      expect(results, hasLength(1));
      expect(results.first.id, 'c1');
    });
  });
}
