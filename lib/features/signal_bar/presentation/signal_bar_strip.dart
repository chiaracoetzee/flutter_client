import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/core/permissions/permission.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/providers/channel/channel_message_permissions_provider.dart';
import 'package:fluxer_app/features/guilds/providers/guild_permissions_provider.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_bar_providers.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_persona_affirmation.dart';
import 'package:fluxer_app/features/ui/avatar/fluxer_avatar.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:fluxer_app/shared/widgets/rebuild_safe_layout_builder.dart';
import 'package:fluxer_app/shared/widgets/unicode_emoji_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const double _kSignalSize = 40;
const double _kMinSignalSize = 30;
const double _kMaxSignalSize = 48;
const double _kSignalSpacing = 10;
const double _kBadgeSize = 14;
const int _kMaxBadges = 3;
const int _kSignalEmojiFetchSize = 128;

const List<double> _kGreyscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Whether the strip is collapsed to just its caret. Kept for the session.
class SignalBarCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final NotifierProvider<SignalBarCollapsedNotifier, bool>
signalBarCollapsedProvider = NotifierProvider<SignalBarCollapsedNotifier, bool>(
  SignalBarCollapsedNotifier.new,
);

/// The signal bar attached to the top of the composer: a wrapping row of
/// toggleable signals shared by everyone in the channel.
class SignalBarStrip extends ConsumerStatefulWidget {
  const SignalBarStrip({
    required this.channelId,
    required this.guildId,
    required this.backgroundColor,
    required this.dividerColor,
    super.key,
  });

  final String channelId;
  final String guildId;
  final Color backgroundColor;
  final Color dividerColor;

  @override
  ConsumerState<SignalBarStrip> createState() => _SignalBarStripState();
}

class _SignalBarStripState extends ConsumerState<SignalBarStrip> {
  late final ChannelSignalsNotifier _signals;
  late final SignalBarConfigNotifier _config;
  String? _loadingChannelId;

  @override
  void initState() {
    super.initState();
    _signals = ref.read(channelSignalsProvider.notifier);
    _config = ref.read(signalBarConfigProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _config.ensureLoaded();
      _loadChannelIfNeeded();
    });
  }

  @override
  void didUpdateWidget(SignalBarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channelId != widget.channelId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadChannelIfNeeded();
        }
      });
    }
  }

  void _loadChannelIfNeeded() {
    final String channelId = widget.channelId;
    if (channelId.isEmpty || _loadingChannelId == channelId) {
      return;
    }
    if (ref.read(signalBarConfigProvider).signals.isEmpty ||
        ref.read(channelSignalsProvider).containsKey(channelId)) {
      return;
    }
    _loadingChannelId = channelId;
    unawaited(
      _signals.loadChannel(channelId).whenComplete(() {
        if (_loadingChannelId == channelId) {
          _loadingChannelId = null;
        }
      }),
    );
  }

  void _toggle(SignalBarSignal signal, {required bool mine}) {
    final String? userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return;
    }
    FluxerHaptics.light();
    if (mine) {
      unawaited(
        _signals.deactivate(widget.channelId, signal.id, userId: userId),
      );
    } else {
      // Lighting a signal is done in this channel, so it names whoever the
      // composer here is writing as. Afterwards only typing, a pick or a
      // message in this channel changes that.
      unawaited(
        _signals.activate(
          widget.channelId,
          signal.id,
          personaId: composerSignalPersona(
            ref.read,
            widget.channelId,
            latchedPersonaId: latchedSignalPersonaId(
              ref.read,
              widget.channelId,
            ),
          )?.id,
        ),
      );
    }
  }

  /// Everyone sees who has the signal on, since the small badges do not always
  /// identify people. Managers can also turn one person's signal off or reset
  /// it for everyone.
  void _showDetails(
    SignalBarSignal signal,
    List<SignalEntry> entries, {
    required bool canManage,
  }) {
    FluxerHaptics.light();
    final String? currentUserId = ref.read(currentUserIdProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SignalDetailsSheet(
          signal: signal,
          entries: entries,
          onTurnOff: canManage
              ? (SignalEntry entry) {
                  Navigator.of(sheetContext).pop();
                  if (entry.userId == currentUserId) {
                    unawaited(
                      _signals.deactivate(
                        widget.channelId,
                        signal.id,
                        userId: entry.userId,
                      ),
                    );
                  } else {
                    unawaited(
                      _signals.removeUser(
                        widget.channelId,
                        signal.id,
                        userId: entry.userId,
                      ),
                    );
                  }
                }
              : null,
          onReset: canManage
              ? () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_signals.reset(widget.channelId, signal.id));
                }
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<SignalBarConfig>(signalBarConfigProvider, (_, _) {
        _loadChannelIfNeeded();
      })
      ..listen<bool>(
        channelSignalsProvider.select(
          (Map<String, List<SignalEntry>> map) =>
              map.containsKey(widget.channelId),
        ),
        (_, bool loaded) {
          if (!loaded) {
            _loadChannelIfNeeded();
          }
        },
      );
    final SignalBarConfig config = ref.watch(signalBarConfigProvider);
    final bool enabled = ref.watch(
      channelSignalsProvider.select(
        (Map<String, List<SignalEntry>> channels) =>
            _signals.isEnabledIn(channels, widget.channelId),
      ),
    );
    if (config.signals.isEmpty || !enabled) {
      return const SizedBox.shrink();
    }
    final List<SignalEntry> entries = ref.watch(
      channelSignalsProvider.select(
        (Map<String, List<SignalEntry>> map) =>
            map[widget.channelId] ?? const <SignalEntry>[],
      ),
    );
    final bool canToggle =
        ref
            .watch(channelMessagePermissionsProvider(widget.channelId))
            .value
            ?.canSendMessages ??
        true;
    final bool canReset =
        widget.guildId.isEmpty ||
        ((ref.watch(guildPermissionsProvider)[widget.guildId] ?? 0) &
                Permission.manageGuild.value) !=
            0;
    return SignalBarView(
      signals: config.signals,
      entries: entries,
      currentUserId: ref.watch(currentUserIdProvider),
      collapsed: ref.watch(signalBarCollapsedProvider),
      backgroundColor: widget.backgroundColor,
      dividerColor: widget.dividerColor,
      onToggle: canToggle ? _toggle : null,
      onDetails: (SignalBarSignal signal, List<SignalEntry> entries) =>
          _showDetails(signal, entries, canManage: canReset),
      onToggleCollapsed: ref.read(signalBarCollapsedProvider.notifier).toggle,
    );
  }
}

/// How many signals of [size] fit on one row of [width].
int _signalsPerRow(double size, double width) {
  final int perRow =
      ((width + _kSignalSpacing + 0.001) / (size + _kSignalSpacing)).floor();
  return perRow < 1 ? 1 : perRow;
}

/// How full the last row is, from just above 0 to 1. A single row counts as
/// full: growing the signals to fill it would only make them oversized.
double _lastRowFill(int count, int perRow) {
  if (count <= perRow) {
    return 1;
  }
  final int last = count - (count - 1) ~/ perRow * perRow;
  return last / perRow;
}

/// The signal size for [count] signals in a bar [width] wide. Signals that
/// fit on one row keep the default 40. Past that, a size within 30 to 48 that
/// leaves no row less than half full: of those, the one with the fewest rows,
/// then the one nearest 40, so fifteen signals on a phone make two rows of 35
/// rather than rows of 7, 7 and 1. When no size manages it, the one whose
/// last row is fullest.
double signalBarSignalSize({required int count, required double width}) {
  if (count <= 0 || !width.isFinite || width <= 0) {
    return _kSignalSize;
  }
  double best = _kSignalSize;
  (double, int, double)? bestKey;
  for (double size = _kMinSignalSize; size <= _kMaxSignalSize; size++) {
    final int perRow = _signalsPerRow(size, width);
    final double fill = _lastRowFill(count, perRow);
    // Higher is better in every field: fill (capped at half full, so any
    // size that meets the rule ties), then fewer rows, then nearer 40.
    final (double, int, double) key = (
      fill >= 0.5 ? 0.5 : fill,
      -((count + perRow - 1) ~/ perRow),
      -(size - _kSignalSize).abs(),
    );
    if (bestKey == null || _isBetter(key, bestKey)) {
      best = size;
      bestKey = key;
    }
  }
  return best;
}

bool _isBetter((double, int, double) a, (double, int, double) b) {
  if (a.$1 != b.$1) {
    return a.$1 > b.$1;
  }
  if (a.$2 != b.$2) {
    return a.$2 > b.$2;
  }
  return a.$3 > b.$3;
}

/// The strip itself, free of providers so it can be laid out and tested alone.
class SignalBarView extends StatelessWidget {
  const SignalBarView({
    required this.signals,
    required this.entries,
    required this.currentUserId,
    required this.collapsed,
    required this.backgroundColor,
    required this.dividerColor,
    required this.onToggle,
    required this.onDetails,
    required this.onToggleCollapsed,
    super.key,
  });

  final List<SignalBarSignal> signals;
  final List<SignalEntry> entries;
  final String? currentUserId;
  final bool collapsed;
  final Color backgroundColor;
  final Color dividerColor;

  /// Null when the user may not give signals in this channel.
  final void Function(SignalBarSignal signal, {required bool mine})? onToggle;

  /// Opens the list of people who have the signal on.
  final void Function(SignalBarSignal signal, List<SignalEntry> entries)?
  onDetails;
  final VoidCallback onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final Color surface =
        Color.lerp(backgroundColor, context.colors.textPrimary, 0.05) ??
        backgroundColor;
    return Semantics(
      container: true,
      label: l10n.fork.signalBarLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12,
            collapsed ? 0 : 10,
            4,
            collapsed ? 0 : 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: collapsed
                    ? const SizedBox.shrink()
                    : RebuildSafeLayoutBuilder(
                        debugLabel: 'SignalBarView',
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final double size = signalBarSignalSize(
                                count: signals.length,
                                width: constraints.maxWidth,
                              );
                              return Wrap(
                                spacing: _kSignalSpacing,
                                runSpacing: _kSignalSpacing,
                                children: <Widget>[
                                  for (final SignalBarSignal signal in signals)
                                    _SignalButton(
                                      key: ValueKey<String>(
                                        'signal-${signal.id}',
                                      ),
                                      signal: signal,
                                      entries: <SignalEntry>[
                                        for (final SignalEntry entry in entries)
                                          if (entry.signalId == signal.id)
                                            entry,
                                      ],
                                      currentUserId: currentUserId,
                                      surface: surface,
                                      size: size,
                                      onToggle: onToggle,
                                      onDetails: onDetails,
                                    ),
                                ],
                              );
                            },
                      ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                tooltip: collapsed
                    ? l10n.fork.signalBarShow
                    : l10n.fork.signalBarHide,
                onPressed: onToggleCollapsed,
                icon: PhosphorIcon(
                  collapsed
                      ? PhosphorIconsBold.caretUp
                      : PhosphorIconsBold.caretDown,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignalButton extends StatelessWidget {
  const _SignalButton({
    required this.signal,
    required this.entries,
    required this.currentUserId,
    required this.surface,
    required this.size,
    required this.onToggle,
    required this.onDetails,
    super.key,
  });

  final SignalBarSignal signal;
  final List<SignalEntry> entries;
  final String? currentUserId;
  final Color surface;
  final double size;
  final void Function(SignalBarSignal signal, {required bool mine})? onToggle;

  /// Opens the list of people who have the signal on.
  final void Function(SignalBarSignal signal, List<SignalEntry> entries)?
  onDetails;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final bool lit = entries.isNotEmpty;
    final bool mine = entries.any(
      (SignalEntry entry) => entry.userId == currentUserId,
    );
    final String label = lit
        ? l10n.fork.signalBarSignalWithNames(
            signal.displayLabel,
            entries.map((SignalEntry entry) => entry.displayName).join(', '),
          )
        : signal.displayLabel;
    Widget emoji = signal.emojiId != null
        ? CachedEmojiImage(
            emojiId: signal.emojiId!,
            animated: lit && signal.animated,
            requestSize: _kSignalEmojiFetchSize,
            size: size,
          )
        : UnicodeEmojiWidget(emoji: signal.emojiName, size: size * 0.85);
    if (!lit) {
      emoji = Opacity(
        opacity: 0.4,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_kGreyscaleMatrix),
          child: emoji,
        ),
      );
    }
    final void Function(SignalBarSignal signal, {required bool mine})? toggle =
        onToggle;
    final void Function(SignalBarSignal signal, List<SignalEntry> entries)?
    details = onDetails;
    return Semantics(
      button: true,
      toggled: mine,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle == null ? null : () => toggle(signal, mine: mine),
        onLongPress: details == null ? null : () => details(signal, entries),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              ExcludeSemantics(child: emoji),
              if (lit)
                Positioned(
                  top: -6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final SignalEntry entry in entries.take(_kMaxBadges))
                        DecoratedBox(
                          key: ValueKey<String>('signal-badge-${entry.userId}'),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: surface, width: 1.5),
                          ),
                          child: _SignalBadge(entry: entry, size: _kBadgeSize),
                        ),
                      if (entries.length > _kMaxBadges)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: context.colors.backgroundTertiary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: surface, width: 1.5),
                          ),
                          child: Text(
                            '+${entries.length - _kMaxBadges}',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Long-press sheet for one signal: its name and the people who have it on.
///
/// With [onTurnOff] and [onReset] null it is a plain list of names; managers
/// get both and can act on the entries.
class SignalDetailsSheet extends StatelessWidget {
  const SignalDetailsSheet({
    required this.signal,
    required this.entries,
    required this.onTurnOff,
    required this.onReset,
    super.key,
  });

  final SignalBarSignal signal;
  final List<SignalEntry> entries;
  final void Function(SignalEntry entry)? onTurnOff;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final void Function(SignalEntry entry)? turnOff = onTurnOff;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                signal.displayLabel,
                style: context.textStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (entries.isEmpty)
              ListTile(title: Text(l10n.fork.signalBarNobody))
            else
              for (final SignalEntry entry in entries)
                ListTile(
                  key: ValueKey<String>('signal-details-${entry.userId}'),
                  leading: _SignalBadge(entry: entry, size: 28),
                  title: Text(
                    turnOff == null
                        ? entry.displayName
                        : l10n.fork.signalBarTurnOff(entry.displayName),
                  ),
                  onTap: turnOff == null ? null : () => turnOff(entry),
                ),
            if (entries.isNotEmpty && onReset != null)
              ListTile(
                key: const ValueKey<String>('signal-details-reset'),
                leading: PhosphorIcon(
                  PhosphorIconsRegular.trash,
                  color: context.colors.statusDanger,
                ),
                title: Text(
                  l10n.fork.signalBarReset,
                  style: TextStyle(color: context.colors.statusDanger),
                ),
                onTap: onReset,
              ),
          ],
        ),
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({required this.entry, required this.size});

  final SignalEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FluxerAvatar.user(
      userId: entry.userId,
      imageUrl: entry.personaId != null
          ? entry.personaAvatar
          : FluxerMediaUrl.userAvatar(
              userId: entry.userId,
              hash: entry.userAvatar,
            ),
      fallbackText: entry.displayName,
      size: size,
      showStatus: false,
    );
  }
}
