import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/quick_switcher/domain/recent_channel_visit.dart';
import 'package:fluxer_app/features/quick_switcher/providers/recent_channel_visits_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fork_support/wait_until.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads saved visits from SharedPreferences', () async {
    final existing = [
      RecentChannelVisit(
        channelId: 'ch-1',
        guildId: 'g-1',
      ),
      RecentChannelVisit(
        channelId: 'ch-2',
        guildId: 'g-1',
      ),
    ];
    SharedPreferences.setMockInitialValues({
      'recent_channel_visits_v1': jsonEncode(
        existing.map((e) => e.toJson()).toList(),
      ),
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial read
    container.read(recentChannelVisitsProvider);

    // The saved visits are read in the background.
    await waitUntil(
      () => container.read(recentChannelVisitsProvider).length == 2,
      'the saved visits to load',
    );

    final state = container.read(recentChannelVisitsProvider);
    expect(state.length, 2);
    expect(state[0].channelId, 'ch-1');
    expect(state[1].channelId, 'ch-2');
  });

  test(
    'recordVisit on cold boot merges with disk data without overwriting it',
    () async {
      final diskVisits = [
        RecentChannelVisit(
          channelId: 'older-ch',
          guildId: 'g-1',
        ),
      ];
      SharedPreferences.setMockInitialValues({
        'recent_channel_visits_v1': jsonEncode(
          diskVisits.map((e) => e.toJson()).toList(),
        ),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Simulate cold boot: recordVisit is called synchronously on frame 1
      // before _init() has completed reading from SharedPreferences
      container.read(recentChannelVisitsProvider.notifier).recordVisit(
        channelId: 'new-ch',
        guildId: 'g-1',
      );

      // Verify immediate state has the new channel
      expect(
        container.read(recentChannelVisitsProvider).first.channelId,
        'new-ch',
      );

      // The saved visits are read in the background and the merged list is
      // then written back; the write is the last thing to happen.
      final SharedPreferences saved = await SharedPreferences.getInstance();
      await waitUntil(
        () => (saved.getString('recent_channel_visits_v1') ?? '').contains(
          'new-ch',
        ),
        'the merged visits to be saved',
      );

      final state = container.read(recentChannelVisitsProvider);
      expect(state.length, 2);
      expect(state[0].channelId, 'new-ch');
      expect(state[1].channelId, 'older-ch');

      // Verify persisted state in SharedPreferences contains both channels
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('recent_channel_visits_v1');
      expect(raw, isNotNull);
      final List<dynamic> decoded = jsonDecode(raw!) as List<dynamic>;
      expect(decoded.length, 2);
      expect(decoded[0]['channelId'], 'new-ch');
      expect(decoded[1]['channelId'], 'older-ch');
    },
  );

  test('caps at kMaxRecentChannelVisits = 20', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (int i = 0; i < 25; i++) {
      container
          .read(recentChannelVisitsProvider.notifier)
          .recordVisit(channelId: 'ch-$i');
    }

    final state = container.read(recentChannelVisitsProvider);
    expect(state.length, kMaxRecentChannelVisits);
    expect(state.first.channelId, 'ch-24');
    expect(state.last.channelId, 'ch-5');
  });
}
