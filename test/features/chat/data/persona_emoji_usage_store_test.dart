// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/persona_emoji_usage_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PersonaEmojiUsageStore', () {
    test('ignores empty or root persona IDs', () async {
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', '');
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', '0');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fluxer_persona_emoji_usage'), isNull);

      final ranked = await PersonaEmojiUsageStore.getRankedKeys('');
      expect(ranked, isEmpty);

      final rankedRoot = await PersonaEmojiUsageStore.getRankedKeys('0');
      expect(rankedRoot, isEmpty);
    });

    test('tracks emoji usage and increments count for a persona', () async {
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', 'persona_1');
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', 'persona_1');
      await PersonaEmojiUsageStore.trackUsage('unicode:heart', 'persona_1');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('fluxer_persona_emoji_usage');
      expect(raw, isNotNull);

      final map = jsonDecode(raw!) as Map<String, dynamic>;
      final persona1 = map['persona_1'] as Map<String, dynamic>?;
      expect(persona1, isNotNull);
      final thumbsup = persona1!['unicode:thumbsup'] as Map<String, dynamic>;
      final heart = persona1['unicode:heart'] as Map<String, dynamic>;
      expect(thumbsup['count'], 2);
      expect(heart['count'], 1);

      final ranked = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      expect(ranked.length, 2);
      expect(ranked.first, 'unicode:thumbsup');
      expect(ranked[1], 'unicode:heart');
    });

    test('isolates emoji usage between different personas', () async {
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', 'persona_a');
      await PersonaEmojiUsageStore.trackUsage('unicode:heart', 'persona_b');

      final rankedA = await PersonaEmojiUsageStore.getRankedKeys('persona_a');
      expect(rankedA, ['unicode:thumbsup']);

      final rankedB = await PersonaEmojiUsageStore.getRankedKeys('persona_b');
      expect(rankedB, ['unicode:heart']);
    });

    test('computes recency decay score correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      // 10 days ago (past the 7-day decay window, decay = 0 -> score = count * 1.0 = 5.0)
      final oldTime = now - (10 * 24 * 3600 * 1000);

      final initialData = {
        'persona_1': {
          'unicode:old': {
            'count': 5,
            'last_used': oldTime,
          },
          'unicode:recent': {
            'count': 3,
            'last_used': now, // recent -> decay ~= 1.0 -> score ~= 3 * 2.0 = 6.0
          },
        },
      };

      SharedPreferences.setMockInitialValues({
        'fluxer_persona_emoji_usage': jsonEncode(initialData),
      });

      final ranked = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      // unicode:recent (score ~6.0) should rank higher than unicode:old (score ~5.0)
      expect(ranked, ['unicode:recent', 'unicode:old']);
    });

    test('clearAll removes all stored persona usage', () async {
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', 'persona_1');
      final rankedBefore = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      expect(rankedBefore, isNotEmpty);

      await PersonaEmojiUsageStore.clearAll();

      final rankedAfter = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      expect(rankedAfter, isEmpty);
    });

    test('handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'fluxer_persona_emoji_usage': 'NOT_VALID_JSON{',
      });

      final ranked = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      expect(ranked, isEmpty);

      // Should also not crash when tracking into corrupted data
      await PersonaEmojiUsageStore.trackUsage('unicode:thumbsup', 'persona_1');
      final rankedAfter = await PersonaEmojiUsageStore.getRankedKeys('persona_1');
      expect(rankedAfter, ['unicode:thumbsup']);
    });
  });
}
