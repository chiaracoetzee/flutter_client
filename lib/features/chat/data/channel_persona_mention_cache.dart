import 'dart:math' as math;

import 'package:dio/dio.dart';

double calculatePersonaFrecencyScore({
  int? useCount,
  dynamic lastUsedAtMs,
  DateTime? now,
}) {
  final int count = (useCount ?? 0) < 0 ? 0 : (useCount ?? 0);
  final double countScore = (math.log(count + 1) / math.ln10) * 20.0;

  int? ms;
  if (lastUsedAtMs is int) {
    ms = lastUsedAtMs;
  } else if (lastUsedAtMs is num) {
    ms = lastUsedAtMs.toInt();
  } else if (lastUsedAtMs is String) {
    ms = int.tryParse(lastUsedAtMs);
  } else if (lastUsedAtMs is DateTime) {
    ms = lastUsedAtMs.millisecondsSinceEpoch;
  }

  if (ms == null || ms <= 0) {
    return countScore;
  }

  final int nowMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final int ageMs = math.max(0, nowMs - ms);
  final double ageHours = ageMs / (1000.0 * 60.0 * 60.0);

  double recencyBoost = 0;
  if (ageHours < 0.25) {
    recencyBoost = 120;
  } else if (ageHours < 1.0) {
    recencyBoost = 90;
  } else if (ageHours < 24.0) {
    recencyBoost = 60;
  } else if (ageHours < 72.0) {
    recencyBoost = 35;
  } else if (ageHours < 168.0) {
    recencyBoost = 15;
  } else if (ageHours < 720.0) {
    recencyBoost = 5;
  }

  return countScore + recencyBoost;
}

int calculatePersonaMatchScore({
  required String personaName,
  required String query,
  String? displayTagText,
  String? ownerUsername,
  String? ownerNickname,
  String? ownerGlobalName,
}) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return 0;
  }

  final String name = personaName.toLowerCase();
  if (name.startsWith(q)) {
    return 1000;
  }
  if (name.contains(' $q') || name.contains('-$q') || name.contains('_$q')) {
    return 800;
  }
  if (name.contains(q)) {
    return 500;
  }
  final String sys = (displayTagText ?? '').toLowerCase();
  if (sys.startsWith(q)) {
    return 350;
  }
  if (sys.contains(q)) {
    return 250;
  }
  final String user = (ownerUsername ?? '').toLowerCase();
  final String nick = (ownerNickname ?? '').toLowerCase();
  final String global = (ownerGlobalName ?? '').toLowerCase();
  if (user.startsWith(q) || nick.startsWith(q) || global.startsWith(q)) {
    return 150;
  }
  if (user.contains(q) || nick.contains(q) || global.contains(q)) {
    return 100;
  }
  return -1;
}

class _ChannelPersonaMentionCacheEntry {
  _ChannelPersonaMentionCacheEntry({
    required this.items,
    this.serverFetchedAt,
    this.guildId,
  });

  final List<Map<String, dynamic>> items;
  final DateTime? serverFetchedAt;
  final String? guildId;

  bool get isFresh =>
      serverFetchedAt != null &&
      DateTime.now().difference(serverFetchedAt!) < ChannelPersonaMentionCache.ttl;
}

class ChannelPersonaMentionCache {
  ChannelPersonaMentionCache._();

  static final ChannelPersonaMentionCache instance =
      ChannelPersonaMentionCache._();

  static const Duration ttl = Duration(minutes: 15);

  final Map<String, _ChannelPersonaMentionCacheEntry> _cache =
      <String, _ChannelPersonaMentionCacheEntry>{};

  void invalidate([String? guildId]) {
    if (guildId == null || guildId.isEmpty) {
      _cache.clear();
      return;
    }
    _cache.removeWhere(
      (String _, _ChannelPersonaMentionCacheEntry entry) =>
          entry.guildId == null || entry.guildId == guildId,
    );
  }

  void clear() {
    _cache.clear();
  }

  void setChannelPersonas(
    String channelId,
    List<Map<String, dynamic>> items, {
    String? guildId,
    bool fromServer = true,
  }) {
    final Map<String, Map<String, dynamic>> byId =
        <String, Map<String, dynamic>>{};
    final _ChannelPersonaMentionCacheEntry? existing = _cache[channelId];
    if (existing != null) {
      for (final Map<String, dynamic> item in existing.items) {
        final String? id = item['id'] as String?;
        if (id != null && id.isNotEmpty) {
          byId[id] = Map<String, dynamic>.from(item);
        }
      }
    }
    for (final Map<String, dynamic> item in items) {
      final String? id = item['id'] as String?;
      if (id != null && id.isNotEmpty) {
        final Map<String, dynamic>? prev = byId[id];
        if (prev != null) {
          final Map<String, dynamic> merged =
              Map<String, dynamic>.from(prev)..addAll(item);
          final dynamic prevLastUsed = prev['last_used_at_ms'];
          final dynamic newLastUsed = item['last_used_at_ms'];
          final int? prevMs = prevLastUsed is num
              ? prevLastUsed.toInt()
              : (prevLastUsed is String ? int.tryParse(prevLastUsed) : null);
          final int? newMs = newLastUsed is num
              ? newLastUsed.toInt()
              : (newLastUsed is String ? int.tryParse(newLastUsed) : null);
          if (prevMs != null && (newMs == null || prevMs > newMs)) {
            merged['last_used_at_ms'] = prevMs;
          }
          final dynamic prevCount = prev['use_count'];
          final dynamic newCount = item['use_count'];
          final int pC = (prevCount is num) ? prevCount.toInt() : 0;
          final int nC = (newCount is num) ? newCount.toInt() : 0;
          merged['use_count'] = math.max(pC, nC);
          byId[id] = merged;
        } else {
          byId[id] = Map<String, dynamic>.from(item);
        }
      }
    }
    _cache[channelId] = _ChannelPersonaMentionCacheEntry(
      items: byId.values.toList(),
      serverFetchedAt: fromServer ? DateTime.now() : existing?.serverFetchedAt,
      guildId: guildId ?? existing?.guildId,
    );
  }

  List<Map<String, dynamic>> filterItems(
    List<Map<String, dynamic>> items,
    String query, {
    Map<String, int>? overrideLastUsedAtMs,
  }) {
    final String q = query.trim().toLowerCase();
    final DateTime now = DateTime.now();

    final List<Map<String, dynamic>> filtered = q.isEmpty
        ? List<Map<String, dynamic>>.from(items)
        : items.where((Map<String, dynamic> item) {
            final String name = item['name'] as String? ?? '';
            final String? sys = item['display_tag_text'] as String?;
            final String? user = item['owner_username'] as String?;
            final String? nick = item['owner_nickname'] as String?;
            final String? global = item['owner_global_name'] as String?;
            final int match = calculatePersonaMatchScore(
              personaName: name,
              query: q,
              displayTagText: sys,
              ownerUsername: user,
              ownerNickname: nick,
              ownerGlobalName: global,
            );
            return match >= 0;
          }).toList()
      ..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        if (q.isNotEmpty) {
        final int aMatch = calculatePersonaMatchScore(
          personaName: a['name'] as String? ?? '',
          query: q,
          displayTagText: a['display_tag_text'] as String?,
          ownerUsername: a['owner_username'] as String?,
          ownerNickname: a['owner_nickname'] as String?,
          ownerGlobalName: a['owner_global_name'] as String?,
        );
        final int bMatch = calculatePersonaMatchScore(
          personaName: b['name'] as String? ?? '',
          query: q,
          displayTagText: b['display_tag_text'] as String?,
          ownerUsername: b['owner_username'] as String?,
          ownerNickname: b['owner_nickname'] as String?,
          ownerGlobalName: b['owner_global_name'] as String?,
        );
        if (aMatch != bMatch) {
          return bMatch.compareTo(aMatch);
        }
      }

      final String aId = a['id'] as String? ?? '';
      final String bId = b['id'] as String? ?? '';

      final dynamic aLastUsed =
          overrideLastUsedAtMs?[aId] ?? a['last_used_at_ms'];
      final dynamic bLastUsed =
          overrideLastUsedAtMs?[bId] ?? b['last_used_at_ms'];

      final int aUseCount = (a['use_count'] as num?)?.toInt() ?? 0;
      final int bUseCount = (b['use_count'] as num?)?.toInt() ?? 0;

      final double aFrecency = calculatePersonaFrecencyScore(
        useCount: aUseCount,
        lastUsedAtMs: aLastUsed,
        now: now,
      );
      final double bFrecency = calculatePersonaFrecencyScore(
        useCount: bUseCount,
        lastUsedAtMs: bLastUsed,
        now: now,
      );

      if ((bFrecency - aFrecency).abs() > 0.001) {
        return bFrecency.compareTo(aFrecency);
      }

      final String aName = (a['name'] as String? ?? '').toLowerCase();
      final String bName = (b['name'] as String? ?? '').toLowerCase();
      return aName.compareTo(bName);
    });

    return filtered;
  }

  Future<List<Map<String, dynamic>>> getChannelPersonas({
    required Dio dio,
    required String channelId,
    String query = '',
    int limit = 500,
    String? guildId,
    Map<String, int>? overrideLastUsedAtMs,
    List<Map<String, dynamic>>? seedItems,
  }) async {
    if (seedItems != null && seedItems.isNotEmpty) {
      setChannelPersonas(
        channelId,
        seedItems,
        guildId: guildId,
        fromServer: false,
      );
    }
    final _ChannelPersonaMentionCacheEntry? entry = _cache[channelId];
    final bool isFresh = entry != null && entry.isFresh;

    if (isFresh) {
      final List<Map<String, dynamic>> localMatches = filterItems(
        entry.items,
        query,
        overrideLastUsedAtMs: overrideLastUsedAtMs,
      );
      if (localMatches.isNotEmpty || query.isEmpty) {
        return localMatches;
      }
    }

    try {
      final Response<dynamic> resp = await dio.get<dynamic>(
        '/channels/$channelId/persona-mentions',
        queryParameters: <String, dynamic>{
          'q': query.trim(),
          'limit': limit,
        },
      );
      final dynamic data = resp.data;
      final List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['personas'] is List) {
        rawList = data['personas'] as List<dynamic>;
      } else {
        rawList = const <dynamic>[];
      }

      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
      for (final dynamic item in rawList) {
        if (item is Map) {
          items.add(Map<String, dynamic>.from(item));
        }
      }
      setChannelPersonas(
        channelId,
        items,
        guildId: guildId,
        fromServer: query.trim().isEmpty,
      );
      return filterItems(
        _cache[channelId]?.items ?? items,
        query,
        overrideLastUsedAtMs: overrideLastUsedAtMs,
      );
    } on Object catch (_) {
      if (entry != null) {
        return filterItems(
          entry.items,
          query,
          overrideLastUsedAtMs: overrideLastUsedAtMs,
        );
      }
      return const <Map<String, dynamic>>[];
    }
  }
}
