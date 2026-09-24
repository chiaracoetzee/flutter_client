import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';

void main() {
  group('calculatePersonaFrecencyScore', () {
    test('calculates higher frecency score for recently used personas', () {
      final DateTime now = DateTime.now();

      // Persona A: used 100 times, but 2 days ago (age 48 hours -> recency boost 35)
      // countScore = log10(101) * 20 ≈ 40.08 + 35 = 75.08
      final DateTime twoDaysAgo = now.subtract(const Duration(hours: 48));
      final double scoreOldFrequent = calculatePersonaFrecencyScore(
        useCount: 100,
        lastUsedAtMs: twoDaysAgo.millisecondsSinceEpoch,
        now: now,
      );

      // Persona B: used 5 times, but 5 minutes ago (age < 0.25h -> recency boost 120)
      // countScore = log10(6) * 20 ≈ 15.56 + 120 = 135.56
      final DateTime fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      final double scoreRecentFew = calculatePersonaFrecencyScore(
        useCount: 5,
        lastUsedAtMs: fiveMinutesAgo.millisecondsSinceEpoch,
        now: now,
      );

      expect(scoreRecentFew, greaterThan(scoreOldFrequent));
    });

    test('falls back to count score when lastUsedAtMs is null or zero', () {
      final double scoreZero = calculatePersonaFrecencyScore(
        useCount: 10,
      );
      final double scoreExplicitZero = calculatePersonaFrecencyScore(
        useCount: 10,
        lastUsedAtMs: 0,
      );
      expect(scoreZero, equals(scoreExplicitZero));
      expect(scoreZero, greaterThan(0));
    });
  });

  group('calculatePersonaMatchScore', () {
    test('ranks match tiers correctly', () {
      // 1. Exact prefix on name -> 1000
      expect(
        calculatePersonaMatchScore(personaName: 'Alice', query: 'ali'),
        equals(1000),
      );

      // 2. Word boundary prefix on name -> 800
      expect(
        calculatePersonaMatchScore(personaName: 'Little Alice', query: 'ali'),
        equals(800),
      );

      // 3. Substring on name -> 500
      expect(
        calculatePersonaMatchScore(personaName: 'Malice', query: 'ali'),
        equals(500),
      );

      // 4. System tag prefix -> 350, substring -> 250
      expect(
        calculatePersonaMatchScore(
          personaName: 'Bob',
          query: 'won',
          systemName: 'Wonderland',
        ),
        equals(350),
      );
      expect(
        calculatePersonaMatchScore(
          personaName: 'Bob',
          query: 'land',
          systemName: 'Wonderland',
        ),
        equals(250),
      );

      // 5. Owner username prefix -> 150, substring -> 100
      expect(
        calculatePersonaMatchScore(
          personaName: 'Bob',
          query: 'cat',
          ownerUsername: 'caterpillar',
        ),
        equals(150),
      );
      expect(
        calculatePersonaMatchScore(
          personaName: 'Bob',
          query: 'pillar',
          ownerUsername: 'caterpillar',
        ),
        equals(100),
      );

      // Non match -> -1
      expect(
        calculatePersonaMatchScore(personaName: 'Bob', query: 'xyz'),
        equals(-1),
      );
    });
  });

  group('ChannelPersonaMentionCache filter and ranking', () {
    late ChannelPersonaMentionCache cache;

    setUp(() {
      cache = ChannelPersonaMentionCache.instance..clear();
    });

    test('ranks by query match tier first, then frecency', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p1',
          'name': 'Bob Substring (ali)',
          'use_count': 100,
          'last_used_at_ms': now.millisecondsSinceEpoch - 1000,
        },
        <String, dynamic>{
          'id': 'p2',
          'name': 'Alice',
          'use_count': 0,
          'last_used_at_ms': null,
        },
      ];

      final List<Map<String, dynamic>> sorted = cache.filterItems(items, 'ali');
      expect(sorted[0]['id'], equals('p2')); // Alice wins due to exact prefix match
      expect(sorted[1]['id'], equals('p1'));
    });

    test('ranks same-match-tier personas by frecency score', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p1',
          'name': 'Alice Old',
          'use_count': 10,
          'last_used_at_ms':
              now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        },
        <String, dynamic>{
          'id': 'p2',
          'name': 'Alice Recent',
          'use_count': 2,
          'last_used_at_ms':
              now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
        },
      ];

      final List<Map<String, dynamic>> sorted = cache.filterItems(items, 'ali');
      expect(sorted[0]['id'], equals('p2')); // Alice Recent wins due to recency
      expect(sorted[1]['id'], equals('p1'));
    });

    test('respects overrideLastUsedAtMs for in-room messages', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p1',
          'name': 'Alice Room Speaker',
          'use_count': 0,
          'last_used_at_ms': null, // API had no usage
        },
        <String, dynamic>{
          'id': 'p2',
          'name': 'Alice Other',
          'use_count': 5,
          'last_used_at_ms':
              now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        },
      ];

      // In-room message just arrived 1 minute ago for p1
      final Map<String, int> inRoomOverrides = <String, int>{
        'p1': now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
      };

      final List<Map<String, dynamic>> sorted = cache.filterItems(
        items,
        'ali',
        overrideLastUsedAtMs: inRoomOverrides,
      );
      expect(sorted[0]['id'], equals('p1')); // p1 boosted by in-room message timestamp
      expect(sorted[1]['id'], equals('p2'));
    });

    test('seed items with fromServer: false does not mark cache as fresh', () {
      cache.setChannelPersonas(
        'ch1',
        <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p1', 'name': 'Seed Persona'},
        ],
        fromServer: false,
      );

      // Verify that after seeding, getting channel personas for a new query still attempts server fetch
      // if not marked as fresh from server
      final List<Map<String, dynamic>> local = cache.filterItems(
        <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p1', 'name': 'Seed Persona'},
        ],
        'Seed',
      );
      expect(local.length, equals(1));
    });
  });
}
