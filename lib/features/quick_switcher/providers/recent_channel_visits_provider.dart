import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/channels/providers/channel_frecency_provider.dart';
import 'package:fluxer_app/features/quick_switcher/domain/recent_channel_visit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Fork imports.
// Fork: the fork's imports stay in this group, after upstream's, instead of sorted in among them.
// ignore_for_file: directives_ordering
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

part 'recent_channel_visits_provider.g.dart';

const String _kRecentChannelVisitsKey = 'recent_channel_visits_v1';

@Riverpod(keepAlive: true)
class RecentChannelVisits extends _$RecentChannelVisits {
  final Completer<void> _loaded = Completer<void>();

  @override
  List<RecentChannelVisit> build() {
    final String? userId = ref.watch(currentUserIdProvider);
    _storageKey = userId == null ? null : '${_kRecentChannelVisitsKey}_$userId';
    final String? storageKey = _storageKey;
    if (storageKey != null) {
      unawaited(_init(storageKey));
    }
    return const <RecentChannelVisit>[];
  }

  // Fork: recents persist per account. currentUserIdProvider rebuilds this
  // provider on an account switch, and each account reads its own key.
  String? _storageKey;

  Future<void> _init(String storageKey) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(storageKey);
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
      if (_storageKey != storageKey) {
        return;
      }
      if (loaded.isNotEmpty) {
        final Set<String> existingIds = state
            .map((RecentChannelVisit v) => v.channelId)
            .toSet();
        final List<RecentChannelVisit> merged = <RecentChannelVisit>[
          ...state,
          ...loaded.where(
            (RecentChannelVisit v) => !existingIds.contains(v.channelId),
          ),
        ];
        state = merged.take(kMaxRecentChannelVisits).toList();
        // If visits were recorded before disk read finished, persist the merged state.
        if (existingIds.isNotEmpty) {
          unawaited(_save(state));
        }
      }
    } on Object {
      // Ignore corrupted cache
    } finally {
      if (!_loaded.isCompleted) {
        _loaded.complete();
      }
    }
  }

  void recordVisit({
    required String channelId,
    String? guildId,
    bool isThread = false,
  }) {
    ref
        .read(channelFrecencyProvider.notifier)
        .recordSelection(
          guildId: guildId,
          channelId: channelId,
          isThread: isThread,
        );
    final List<RecentChannelVisit> next = <RecentChannelVisit>[
      RecentChannelVisit(channelId: channelId, guildId: guildId),
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
    await _loaded.future;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Read latest state so merges from _init() are not overwritten by a stale argument.
      final List<RecentChannelVisit> toPersist = state;
      final String raw = jsonEncode(
        toPersist.map((RecentChannelVisit v) => v.toJson()).toList(),
      );
      final String? storageKey = _storageKey;
      if (storageKey == null) {
        return;
      }
      await prefs.setString(storageKey, raw);
    } on Object {
      // Ignore storage write errors
    }
  }
}
