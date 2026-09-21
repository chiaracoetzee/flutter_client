import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'requirements.dart';
import 'scroll_utils.dart';
import 'test_config.dart';

Future<void> openGuildChannel(WidgetTester tester) async {
  requireGuildChannelConfig();

  const String guildId = IntegrationTestConfig.guildId;
  const String channelId = IntegrationTestConfig.channelId;

  await tester.tap(
    find.byKey(const ValueKey<String>('guild-$guildId')).hitTestable().first,
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));

  // The drawer and the shell beneath it can both host a tile for the same
  // channel, and scrollUntilVisible resolves its target with `single`.
  final Finder channelTile = find
      .byKey(const ValueKey<String>(channelId))
      .hitTestable()
      .first;
  final Finder channelList = find
      .descendant(
        of: find.byKey(const ValueKey<String>(guildId)),
        matching: find.byType(Scrollable),
      )
      .first;
  await pumpUntil(tester, channelList);
  await tester.scrollUntilVisible(channelTile, 200, scrollable: channelList);
  await tester.tap(channelTile);
  await tester.pump();
  await pumpUntil(
    tester,
    find.bySemanticsLabel('Loading messages'),
    found: false,
  );
}

Future<void> openPersonalNotes(WidgetTester tester) async {
  await tapBottomNav(tester, 'Home');
  await pumpUntil(tester, find.text(IntegrationTestConfig.personalNotesTitle));

  await tester.tap(find.text(IntegrationTestConfig.personalNotesTitle));
  await tester.pump();
  await pumpUntil(
    tester,
    find.bySemanticsLabel('Loading messages'),
    found: false,
  );
}
