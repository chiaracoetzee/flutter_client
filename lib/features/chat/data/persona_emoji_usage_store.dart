import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class PersonaEmojiUsageStore {
  PersonaEmojiUsageStore._();

  static const String _kPrefPersonaUsage = 'fluxer_persona_emoji_usage';
  static const int _kDecayHours = 24 * 7; // 168 hours

  /// Tracks usage of an emoji key for a specific persona.
  static Future<void> trackUsage(String key, String personaId) async {
    if (personaId.isEmpty || personaId == '0') {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefPersonaUsage);
      Map<String, dynamic> rootMap = <String, dynamic>{};
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            rootMap = decoded;
          }
        } catch (_) {}
      }

      final Map<String, dynamic> pMap =
          (rootMap[personaId] as Map<String, dynamic>?) ?? <String, dynamic>{};

      final existing = pMap[key] as Map<String, dynamic>?;
      final int count = (existing?['count'] as num?)?.toInt() ?? 0;

      pMap[key] = {
        'count': count + 1,
        'last_used': DateTime.now().millisecondsSinceEpoch,
      };

      rootMap[personaId] = pMap;
      await prefs.setString(_kPrefPersonaUsage, jsonEncode(rootMap));
    } catch (_) {}
  }

  /// Returns the top ranked emoji keys for a persona sorted by frecency score.
  static Future<List<String>> getRankedKeys(
    String personaId, {
    int limit = 42,
  }) async {
    if (personaId.isEmpty || personaId == '0') {
      return const [];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefPersonaUsage);
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      Map<String, dynamic> rootMap = <String, dynamic>{};
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          rootMap = decoded;
        }
      } catch (_) {
        return const [];
      }
      final Map<String, dynamic>? pMap =
          rootMap[personaId] as Map<String, dynamic>?;
      if (pMap == null || pMap.isEmpty) {
        return const [];
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final entries = <MapEntry<String, double>>[];

      for (final entry in pMap.entries) {
        final val = entry.value as Map<String, dynamic>?;
        if (val == null) continue;
        final count = (val['count'] as num?)?.toInt() ?? 0;
        final lastUsed = (val['last_used'] as num?)?.toInt() ?? now;

        final hours = (now - lastUsed) / (1000 * 3600);
        final decay = max<double>(0, 1.0 - hours / _kDecayHours);
        final score = count * (1.0 + decay);

        entries.add(MapEntry(entry.key, score));
      }

      entries.sort((a, b) => b.value.compareTo(a.value));
      return entries.map((e) => e.key).take(limit).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Clears persona emoji usage (for testing or reset).
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefPersonaUsage);
    } catch (_) {}
  }
}
