import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/features/signal_bar/data/signal_bar_repository.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';

/// The configured bar. Loaded lazily, refetched when the gateway or a channel
/// snapshot reports a newer version, and after a new gateway session.
class SignalBarConfigNotifier extends Notifier<SignalBarConfig> {
  Future<void>? _request;

  @override
  SignalBarConfig build() => SignalBarConfig.empty;

  Future<void> refresh() {
    return _request ??= _fetch().whenComplete(() => _request = null);
  }

  Future<void> _fetch() async {
    try {
      state = await ref.read(signalBarRepositoryProvider).fetchBar();
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to load the bar: $err');
    }
  }

  void ensureLoaded() {
    if (state.version < 0) {
      unawaited(refresh());
    }
  }

  void ensureVersion(int version) {
    if (version > state.version) {
      unawaited(refresh());
    }
  }
}

final NotifierProvider<SignalBarConfigNotifier, SignalBarConfig>
signalBarConfigProvider =
    NotifierProvider<SignalBarConfigNotifier, SignalBarConfig>(
      SignalBarConfigNotifier.new,
    );

/// Active signal entries for every channel loaded this session.
class ChannelSignalsNotifier extends Notifier<Map<String, List<SignalEntry>>> {
  final Map<String, String?> _ownPersonaByChannel = <String, String?>{};
  final Set<String> _disabledChannels = <String>{};

  @override
  Map<String, List<SignalEntry>> build() => const <String, List<SignalEntry>>{};

  void _setChannel(String channelId, List<SignalEntry> entries) {
    state = <String, List<SignalEntry>>{...state, channelId: entries};
  }

  Future<void> loadChannel(String channelId) async {
    try {
      final result = await ref
          .read(signalBarRepositoryProvider)
          .fetchChannel(channelId);
      if (result.enabled) {
        _disabledChannels.remove(channelId);
      } else {
        _disabledChannels.add(channelId);
      }
      _setChannel(channelId, result.entries);
      ref
          .read(signalBarConfigProvider.notifier)
          .ensureVersion(result.barVersion);
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to load signals for $channelId: $err');
    }
  }

  /// Drops everything after a new gateway session; mounted bars reload.
  void invalidate() {
    _ownPersonaByChannel.clear();
    _disabledChannels.clear();
    state = const <String, List<SignalEntry>>{};
  }

  void handleChannelUpdate(Map<String, dynamic> data) {
    final String? channelId = data['channel_id'] as String?;
    if (channelId == null) {
      return;
    }
    ref
        .read(signalBarConfigProvider.notifier)
        .ensureVersion((data['bar_version'] as num?)?.toInt() ?? 0);
    final List<SignalEntry>? current = state[channelId];
    if (current == null) {
      return;
    }
    _setChannel(
      channelId,
      applySignalUpdate(
        current,
        added: <SignalEntry>[
          for (final Object? item
              in data['added'] as List<dynamic>? ?? const [])
            SignalEntry.fromJson(item! as Map<String, dynamic>),
        ],
        removed: <({String signalId, String userId})>[
          for (final Object? item
              in data['removed'] as List<dynamic>? ?? const [])
            (
              signalId: (item! as Map<String, dynamic>)['signal_id'] as String,
              userId: (item as Map<String, dynamic>)['user_id'] as String,
            ),
        ],
      ),
    );
  }

  Future<void> activate(
    String channelId,
    String signalId, {
    String? personaId,
  }) async {
    try {
      await ref
          .read(signalBarRepositoryProvider)
          .activate(channelId, signalId, personaId: personaId);
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to give signal: $err');
      unawaited(loadChannel(channelId));
    }
  }

  Future<void> deactivate(
    String channelId,
    String signalId, {
    required String userId,
  }) async {
    final List<SignalEntry>? current = state[channelId];
    if (current != null) {
      _setChannel(
        channelId,
        applySignalUpdate(
          current,
          added: const <SignalEntry>[],
          removed: <({String signalId, String userId})>[
            (signalId: signalId, userId: userId),
          ],
        ),
      );
    }
    try {
      await ref
          .read(signalBarRepositoryProvider)
          .deactivate(channelId, signalId);
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to withdraw signal: $err');
      unawaited(loadChannel(channelId));
    }
  }

  /// Whether the bar is switched on in a loaded channel. Channels that are
  /// not loaded yet count as off.
  bool isEnabled(String channelId) => isEnabledIn(state, channelId);

  /// [isEnabled] against a given snapshot of the state. Selectors must use
  /// this one: reading `state` inside a selector trips a Riverpod assertion.
  bool isEnabledIn(Map<String, List<SignalEntry>> channels, String channelId) =>
      channels.containsKey(channelId) && !_disabledChannels.contains(channelId);

  /// CHANNEL_SIGNAL_BAR_UPDATE: a manager switched the bar on or off.
  void handleEnabledUpdate(Map<String, dynamic> data) {
    final String? channelId = data['channel_id'] as String?;
    if (channelId == null) {
      return;
    }
    final bool enabled = data['enabled'] as bool? ?? false;
    if (enabled) {
      _disabledChannels.remove(channelId);
      _setChannel(channelId, state[channelId] ?? const <SignalEntry>[]);
    } else {
      _disabledChannels.add(channelId);
      _setChannel(channelId, const <SignalEntry>[]);
    }
  }

  /// A manager turns one account's signal off.
  Future<void> removeUser(
    String channelId,
    String signalId, {
    required String userId,
  }) async {
    final List<SignalEntry>? current = state[channelId];
    if (current != null) {
      _setChannel(
        channelId,
        applySignalUpdate(
          current,
          added: const <SignalEntry>[],
          removed: <({String signalId, String userId})>[
            (signalId: signalId, userId: userId),
          ],
        ),
      );
    }
    try {
      await ref
          .read(signalBarRepositoryProvider)
          .removeUser(channelId, signalId, userId);
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to turn off a signal: $err');
      unawaited(loadChannel(channelId));
    }
  }

  Future<void> reset(String channelId, String signalId) async {
    try {
      await ref.read(signalBarRepositoryProvider).reset(channelId, signalId);
    } on Exception catch (err) {
      debugPrint('[SignalBar] Failed to reset signal: $err');
      unawaited(loadChannel(channelId));
    }
  }

  /// Called whenever the composer resolves who the account is acting as in
  /// [channelId]. The first report for a channel is only remembered; a later
  /// change re-sends the account's own signals as the new persona and updates
  /// its badge locally straight away. Reacting to changes rather than to a
  /// mismatch keeps two devices with different drafts from fighting.
  void reportOwnPersona(
    String channelId, {
    required String userId,
    required SignalPersona? persona,
  }) {
    final bool known = _ownPersonaByChannel.containsKey(channelId);
    final String? previous = _ownPersonaByChannel[channelId];
    _ownPersonaByChannel[channelId] = persona?.id;
    if (!known || previous == persona?.id) {
      return;
    }
    final List<SignalEntry>? current = state[channelId];
    if (current == null) {
      return;
    }
    final List<SignalEntry> stale = <SignalEntry>[
      for (final SignalEntry entry in current)
        if (entry.userId == userId && entry.personaId != persona?.id) entry,
    ];
    if (stale.isEmpty) {
      return;
    }
    _setChannel(channelId, <SignalEntry>[
      for (final SignalEntry entry in current)
        if (stale.contains(entry))
          entry.withPersona(
            personaId: persona?.id,
            personaName: persona?.name,
            personaAvatar: persona?.avatar,
          )
        else
          entry,
    ]);
    for (final SignalEntry entry in stale) {
      unawaited(activate(channelId, entry.signalId, personaId: persona?.id));
    }
  }

  /// The persona last reported by the composer for [channelId], if any.
  String? ownPersonaId(String channelId) => _ownPersonaByChannel[channelId];

  void forgetOwnPersona(String channelId) {
    _ownPersonaByChannel.remove(channelId);
  }
}

final NotifierProvider<ChannelSignalsNotifier, Map<String, List<SignalEntry>>>
channelSignalsProvider =
    NotifierProvider<ChannelSignalsNotifier, Map<String, List<SignalEntry>>>(
      ChannelSignalsNotifier.new,
    );

/// Routes the two signal bar gateway events to their notifiers.
void handleSignalBarGatewayEvent(
  Ref ref,
  String eventType,
  Map<String, dynamic> data,
) {
  if (eventType == 'CHANNEL_SIGNAL_UPDATE') {
    ref.read(channelSignalsProvider.notifier).handleChannelUpdate(data);
  } else if (eventType == 'CHANNEL_SIGNAL_BAR_UPDATE') {
    ref.read(channelSignalsProvider.notifier).handleEnabledUpdate(data);
  } else if (eventType == 'SIGNAL_BAR_UPDATE') {
    ref
        .read(signalBarConfigProvider.notifier)
        .ensureVersion((data['version'] as num?)?.toInt() ?? 0);
  }
}
