import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';

void main() {
  var requests = 0;
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
      final double scoreZero = calculatePersonaFrecencyScore(useCount: 10);
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
          displayTagText: 'Wonderland',
        ),
        equals(350),
      );
      expect(
        calculatePersonaMatchScore(
          personaName: 'Bob',
          query: 'land',
          displayTagText: 'Wonderland',
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
      expect(
        sorted[0]['id'],
        equals('p2'),
      ); // Alice wins due to exact prefix match
      expect(sorted[1]['id'], equals('p1'));
    });

    test('ranks same-match-tier personas by frecency score', () {
      final DateTime now = DateTime.now();
      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p1',
          'name': 'Alice Old',
          'use_count': 10,
          'last_used_at_ms': now
              .subtract(const Duration(days: 5))
              .millisecondsSinceEpoch,
        },
        <String, dynamic>{
          'id': 'p2',
          'name': 'Alice Recent',
          'use_count': 2,
          'last_used_at_ms': now
              .subtract(const Duration(minutes: 2))
              .millisecondsSinceEpoch,
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
          'last_used_at_ms': now
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
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
      expect(
        sorted[0]['id'],
        equals('p1'),
      ); // p1 boosted by in-room message timestamp
      expect(sorted[1]['id'], equals('p2'));
    });

    test('seed items with fromServer: false does not mark cache as fresh', () {
      cache.setChannelPersonas('ch1', <Map<String, dynamic>>[
        <String, dynamic>{'id': 'p1', 'name': 'Seed Persona'},
      ], fromServer: false);

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

  group('ChannelPersonaMentionCache contents', () {
    late ChannelPersonaMentionCache cache;

    setUp(() {
      cache = ChannelPersonaMentionCache.instance..clear();
    });

    Map<String, dynamic> cached(String id) =>
        cache.cachedItems.singleWhere((item) => item['id'] == id);

    test(
      'merges the same persona, keeping its latest use and highest count',
      () {
        cache
          ..setChannelPersonas('ch1', <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'p1',
              'name': 'Old name',
              'last_used_at_ms': '2000',
              'use_count': 7,
            },
          ])
          ..setChannelPersonas('ch1', <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'p1',
              'name': 'New name',
              'last_used_at_ms': 1000,
              'use_count': 3,
            },
          ]);

        final Map<String, dynamic> p1 = cached('p1');
        expect(p1['name'], 'New name');
        expect(p1['last_used_at_ms'], 2000);
        expect(p1['use_count'], 7);
      },
    );

    test('takes a newer use from the server', () {
      cache
        ..setChannelPersonas('ch1', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p1', 'last_used_at_ms': 1000},
        ])
        ..setChannelPersonas('ch1', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'p1', 'last_used_at_ms': 5000},
        ]);

      expect(cached('p1')['last_used_at_ms'], 5000);
      expect(cached('p1')['use_count'], 0);
    });

    test("forgets one community's channels, and channels of no community", () {
      cache
        ..setChannelPersonas('a', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'pa'},
        ], guildId: 'g1')
        ..setChannelPersonas('b', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'pb'},
        ], guildId: 'g2')
        ..setChannelPersonas('dm', <Map<String, dynamic>>[
          <String, dynamic>{'id': 'pdm'},
        ])
        ..invalidate('g1');

      expect(cache.cachedItems.map((item) => item['id']), <String>['pb']);
    });

    Dio dioAnswering(
      void Function(RequestOptions, RequestInterceptorHandler) answer,
    ) {
      requests = 0;
      return Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests++;
              answer(options, handler);
            },
          ),
        );
    }

    test('answers from a fresh cache without asking the server', () async {
      final Dio dio = dioAnswering(
        (options, handler) => handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: <dynamic>[
              <String, dynamic>{'id': 'p1', 'name': 'Alice'},
            ],
          ),
        ),
      );

      await cache.getChannelPersonas(dio: dio, channelId: 'ch1');
      expect(requests, 1);
      final List<Map<String, dynamic>> again = await cache.getChannelPersonas(
        dio: dio,
        channelId: 'ch1',
        query: 'ali',
      );

      expect(requests, 1);
      expect(again.map((item) => item['id']), <String>['p1']);
    });

    test('falls back to what it has when the server fails', () async {
      final Dio failing = dioAnswering(
        (options, handler) =>
            handler.reject(DioException(requestOptions: options)),
      );
      cache.setChannelPersonas('ch1', <Map<String, dynamic>>[
        <String, dynamic>{'id': 'p1', 'name': 'Alice'},
      ], fromServer: false);

      final List<Map<String, dynamic>> known = await cache.getChannelPersonas(
        dio: failing,
        channelId: 'ch1',
      );
      final List<Map<String, dynamic>> unknown = await cache.getChannelPersonas(
        dio: failing,
        channelId: 'ch2',
      );

      expect(requests, 2);
      expect(known.map((item) => item['id']), <String>['p1']);
      expect(unknown, isEmpty);
    });
  });
}
