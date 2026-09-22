import 'dart:async';
import 'dart:convert';

import 'package:fluxer_app/features/quick_switcher/domain/recent_channel_visit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recent_channel_visits_provider.g.dart';

const String _kRecentChannelVisitsKey = 'recent_channel_visits_v1';

@Riverpod(keepAlive: true)
class RecentChannelVisits extends _$RecentChannelVisits {
  @override
  List<RecentChannelVisit> build() {
    unawaited(_init());
    return const <RecentChannelVisit>[];
  }

  Future<void> _init() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_kRecentChannelVisitsKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<RecentChannelVisit> loaded = decoded
          .map(
            (dynamic e) =>
                RecentChannelVisit.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      if (loaded.isNotEmpty) {
        final Set<String> existingIds =
            state.map((RecentChannelVisit v) => v.channelId).toSet();
        final List<RecentChannelVisit> merged = <RecentChannelVisit>[
          ...state,
          ...loaded.where(
            (RecentChannelVisit v) => !existingIds.contains(v.channelId),
          ),
        ];
        state = merged.take(kMaxRecentChannelVisits).toList();
      }
    } on Object {
      // Ignore corrupted cache
    }
  }

  void recordVisit({required String channelId, String? guildId}) {
    final List<RecentChannelVisit> next = <RecentChannelVisit>[
      RecentChannelVisit(
        channelId: channelId,
        guildId: guildId,
        visitedAt: DateTime.now(),
      ),
      ...state.where(
        (RecentChannelVisit visit) => visit.channelId != channelId,
      ),
    ];
    final List<RecentChannelVisit> trimmed =
        next.length > kMaxRecentChannelVisits
            ? next.take(kMaxRecentChannelVisits).toList()
            : next;
    state = trimmed;
    unawaited(_save(trimmed));
  }

  Future<void> _save(List<RecentChannelVisit> visits) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String raw = jsonEncode(
        visits.map((RecentChannelVisit v) => v.toJson()).toList(),
      );
      await prefs.setString(_kRecentChannelVisitsKey, raw);
    } on Object {
      // Ignore storage write errors
    }
  }
}
