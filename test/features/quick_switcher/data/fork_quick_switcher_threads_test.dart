// Fork: threads, forum posts and forums in the quick switcher's recent
// channels.

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/dm/domain/dm_conversation.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_channel_resolver.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_default_input.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_result_generators.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_types.dart';
import 'package:fluxer_app/features/quick_switcher/domain/recent_channel_visit.dart';

import '../../../helpers/test_l10n.dart';

const List<Channel> _channels = <Channel>[
  Channel(id: '10', guildId: 'g1', name: 'general'),
  Channel(
    id: '11',
    guildId: 'g1',
    name: 'questions',
    type: ChannelType.guildForum,
  ),
  Channel(
    id: '12',
    guildId: 'g1',
    name: 'cats',
    type: ChannelType.publicThread,
    parentId: '10',
  ),
  Channel(
    id: '13',
    guildId: 'g1',
    name: 'how do I',
    type: ChannelType.publicThread,
    parentId: '11',
  ),
];

List<QuickSwitcherTextChannelResult> _recents(
  List<String> visitedChannelIds, {
  Set<String> excludedChannelIds = const <String>{},
}) {
  final List<QuickSwitcherResult> results = generateQuickSwitcherDefaultResults(
    QuickSwitcherDefaultInput(
      resolver: QuickSwitcherChannelResolver(
        l10n: testL10n,
        guildChannelsById: <String, Channel>{
          for (final Channel channel in _channels) channel.id: channel,
        },
        conversationsById: const <String, DmConversation>{},
        guildsById: const <String, Guild>{
          'g1': Guild(id: 'g1', name: 'Temple'),
        },
      ),
      recentVisits: <RecentChannelVisit>[
        for (final String id in visitedChannelIds)
          RecentChannelVisit(channelId: id, guildId: 'g1'),
      ],
      unreadChannels: const [],
      excludedChannelIds: excludedChannelIds,
    ),
  );
  return results.whereType<QuickSwitcherTextChannelResult>().toList();
}

void main() {
  test('lists recent threads and forum posts with the channel they are in', () {
    final List<QuickSwitcherTextChannelResult> results = _recents(<String>[
      '12',
      '13',
      '10',
    ]);

    expect(results.map((QuickSwitcherTextChannelResult r) => r.title), <String>[
      'cats',
      'how do I',
      'general',
    ]);
    expect(results[0].subtitle, 'general · Temple');
    expect(results[1].subtitle, 'questions · Temple');
    expect(results[0].channelType, ChannelType.publicThread);
  });

  test('lists a recent forum', () {
    final List<QuickSwitcherTextChannelResult> results = _recents(<String>[
      '11',
    ]);

    expect(results.single.title, 'questions');
    expect(results.single.subtitle, 'Temple');
  });

  test('lists the channel of the open thread and leaves the thread out', () {
    final List<QuickSwitcherTextChannelResult> results = _recents(
      <String>['12', '10'],
      excludedChannelIds: <String>{'12'},
    );

    expect(results.map((QuickSwitcherTextChannelResult r) => r.title), <String>[
      'general',
    ]);
  });
}
