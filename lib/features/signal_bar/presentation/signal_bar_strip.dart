import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/core/permissions/permission.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/domain/cloud_composer_attachments.dart';
import 'package:fluxer_app/features/chat/providers/channel/channel_message_permissions_provider.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/chat/providers/upload/cloud_upload_controller.dart';
import 'package:fluxer_app/features/guilds/providers/guild_permissions_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_bar_providers.dart';
import 'package:fluxer_app/features/ui/avatar/fluxer_avatar.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:fluxer_app/shared/widgets/unicode_emoji_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const double _kSignalSize = 40;
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
  bool _personaReportScheduled = false;
  SignalPersona? _pendingPersona;

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
      _signals.forgetOwnPersona(oldWidget.channelId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadChannelIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _signals.forgetOwnPersona(widget.channelId);
    super.dispose();
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

  /// Provider writes must not happen during build, so the composer's current
  /// persona is reported after the frame.
  void _schedulePersonaReport(SignalPersona? persona) {
    _pendingPersona = persona;
    if (_personaReportScheduled) {
      return;
    }
    _personaReportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _personaReportScheduled = false;
      if (!mounted) {
        return;
      }
      final String? userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        return;
      }
      _signals.reportOwnPersona(
        widget.channelId,
        userId: userId,
        persona: _pendingPersona,
      );
    });
  }

  SignalPersona? _resolveComposerPersona() {
    final List<Persona> personas =
        ref.watch(myPersonasProvider).asData?.value ?? const <Persona>[];
    if (personas.isEmpty) {
      return null;
    }
    final activeState = ref.watch(activePersonaProvider);
    final String text = ref.watch(
      chatViewModelProvider.select((state) => state.messageText),
    );
    final bool hasAttachments = ref.watch(
      cloudUploadControllerProvider(widget.channelId).select(
        (CloudComposerAttachments attachments) => attachments.items.isNotEmpty,
      ),
    );
    final Persona? persona = previewPersona(
      text,
      personas,
      activeState.isLatched ? activeState.activePersonaId : null,
      hasAttachments,
    ).persona;
    if (persona == null) {
      return null;
    }
    return SignalPersona(
      id: persona.id,
      name: persona.name,
      avatar: persona.avatarHash,
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
      unawaited(
        _signals.activate(
          widget.channelId,
          signal.id,
          personaId: _pendingPersona?.id,
        ),
      );
    }
  }

  /// Managers only: turn off one person's signal, or reset it for everyone.
  void _showDetails(SignalBarSignal signal, List<SignalEntry> entries) {
    FluxerHaptics.light();
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final String? currentUserId = ref.read(currentUserIdProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  signal.displayLabel,
                  style: sheetContext.textStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (entries.isEmpty)
                ListTile(title: Text(l10n.fork.signalBarNobody))
              else
                for (final SignalEntry entry in entries)
                  ListTile(
                    leading: _SignalBadge(entry: entry, size: 28),
                    title: Text(l10n.fork.signalBarTurnOff(entry.displayName)),
                    onTap: () {
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
                    },
                  ),
              if (entries.isNotEmpty)
                ListTile(
                  leading: PhosphorIcon(
                    PhosphorIconsRegular.trash,
                    color: sheetContext.colors.statusDanger,
                  ),
                  title: Text(
                    l10n.fork.signalBarReset,
                    style: TextStyle(color: sheetContext.colors.statusDanger),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_signals.reset(widget.channelId, signal.id));
                  },
                ),
            ],
          ),
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
    _schedulePersonaReport(_resolveComposerPersona());
    final bool enabled = ref.watch(
      channelSignalsProvider.select(
        (_) => _signals.isEnabled(widget.channelId),
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
      onDetails: canReset ? _showDetails : null,
      onToggleCollapsed: ref.read(signalBarCollapsedProvider.notifier).toggle,
    );
  }
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

  /// Null for people who may not manage signals; long-press then does nothing.
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
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          for (final SignalBarSignal signal in signals)
                            _SignalButton(
                              key: ValueKey<String>('signal-${signal.id}'),
                              signal: signal,
                              entries: <SignalEntry>[
                                for (final SignalEntry entry in entries)
                                  if (entry.signalId == signal.id) entry,
                              ],
                              currentUserId: currentUserId,
                              surface: surface,
                              onToggle: onToggle,
                              onDetails: onDetails,
                            ),
                        ],
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
    required this.onToggle,
    required this.onDetails,
    super.key,
  });

  final SignalBarSignal signal;
  final List<SignalEntry> entries;
  final String? currentUserId;
  final Color surface;
  final void Function(SignalBarSignal signal, {required bool mine})? onToggle;

  /// Null for people who may not manage signals; long-press then does nothing.
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
            size: _kSignalSize,
          )
        : UnicodeEmojiWidget(
            emoji: signal.emojiName,
            size: _kSignalSize * 0.85,
          );
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
          width: _kSignalSize,
          height: _kSignalSize,
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
