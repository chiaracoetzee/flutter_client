import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/domain/user_settings_section.dart';
import 'package:fluxer_app/features/settings/presentation/user_settings_modal.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/avatar/fluxer_avatar.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/input/fluxer_input.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';
import 'package:fluxer_app/shared/utils/emoji_utils.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:fluxer_app/shared/widgets/unicode_emoji_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PersonaReactAsSheet {
  PersonaReactAsSheet._();

  static Future<void> show(
    BuildContext context, {
    required String channelId,
    required String messageId,
    required String emoji,
    String? emojiId,
    bool animated = false,
    VoidCallback? onReacted,
  }) {
    final l10n = FluxerLocalizations.of(context);
    final Widget leading = emojiId != null && emojiId.isNotEmpty
        ? SizedBox(
            width: 24,
            height: 24,
            child: CachedEmojiImage(
              emojiId: emojiId,
              animated: animated,
              requestSize: kCustomEmojiFetchSize,
              size: 24,
            ),
          )
        : UnicodeEmojiWidget(
            emoji: emoji,
            size: 24,
          );

    return FluxerBottomSheet.showScrollable<void>(
      context,
      title: l10n.fork.chatReactAs,
      leading: leading,
      useRootNavigator: true,
      minChildSize: 0.55,
      builder: (sheetContext, scrollController, close) {
        return _PersonaReactAsBody(
          scrollController: scrollController,
          onClose: close,
          onReacted: onReacted,
          channelId: channelId,
          messageId: messageId,
          emoji: emoji,
          emojiId: emojiId,
          animated: animated,
        );
      },
    );
  }
}

class _PersonaReactAsBody extends ConsumerStatefulWidget {
  const _PersonaReactAsBody({
    required this.scrollController,
    required this.onClose,
    this.onReacted,
    required this.channelId,
    required this.messageId,
    required this.emoji,
    this.emojiId,
    this.animated = false,
  });

  final ScrollController scrollController;
  final VoidCallback onClose;
  final VoidCallback? onReacted;
  final String channelId;
  final String messageId;
  final String emoji;
  final String? emojiId;
  final bool animated;

  @override
  ConsumerState<_PersonaReactAsBody> createState() => _PersonaReactAsBodyState();
}

class _PersonaReactAsBodyState extends ConsumerState<_PersonaReactAsBody> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      final q = _searchController.text.trim().toLowerCase();
      if (q != _query) {
        setState(() => _query = q);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(myPersonasProvider.notifier).reloadSilently());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reactAsPersona(String personaId) {
    FluxerHaptics.light();
    ref.read(chatViewModelProvider.notifier).toggleReaction(
          widget.messageId,
          widget.emoji,
          emojiId: widget.emojiId,
          animated: widget.animated,
          personaId: personaId,
        );
    widget.onClose();
    widget.onReacted?.call();
  }

  void _reactAsRoot() {
    FluxerHaptics.light();
    ref.read(chatViewModelProvider.notifier).toggleReaction(
          widget.messageId,
          widget.emoji,
          emojiId: widget.emojiId,
          animated: widget.animated,
          explicitRoot: true,
        );
    widget.onClose();
    widget.onReacted?.call();
  }

  void _openManagePersonas() {
    widget.onClose();
    unawaited(
      UserSettingsModal.show(
        context,
        initialSection: UserSettingsSection.personas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;
    final l10n = FluxerLocalizations.of(context);

    final rankedPersonas = ref.watch(rankedPersonasProvider);
    final userSettings = ref.watch(userSettingsViewModelProvider);
    final chatState = ref.watch(chatViewModelProvider);

    final Message? message = chatState.messages
        .where((m) => m.id == widget.messageId)
        .firstOrNull;
    final Reaction? reaction = message?.reactions
        .where((r) => r.emoji == widget.emoji && r.emojiId == widget.emojiId)
        .firstOrNull;

    final bool isRootReacted = reaction?.hasPersonaReacted(null) ?? false;

    final personas = ref.watch(sortedPersonasProvider);

    final filteredPersonas = personas.where((p) {
      if (_query.isEmpty) {
        return true;
      }
      if (p.name.toLowerCase().contains(_query)) {
        return true;
      }
      if (p.pronouns?.toLowerCase().contains(_query) ?? false) {
        return true;
      }
      return p.personaTags.any((t) =>
          (t.prefix?.toLowerCase().contains(_query) ?? false) ||
          (t.suffix?.toLowerCase().contains(_query) ?? false));
    }).toList();

    final recents = _query.isEmpty
        ? rankedPersonas.take(5).toList()
        : const <Persona>[];

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        layout.s3,
        0,
        layout.s3,
        FluxerBottomSheet.scrollBottomPaddingOf(context) + layout.s4,
      ),
      children: [
        // Manage Shortcut Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.fork.personaSettingsHeader,
              style: textStyles.label.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openManagePersonas,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.s2,
                  vertical: layout.s1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.gearSix,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    SizedBox(width: layout.s1),
                    Text(
                      l10n.fork.personaManageAction,
                      style: textStyles.label.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s2),

        // Search Input
        FluxerInput(
          controller: _searchController,
          hint: l10n.fork.personaSearchPlaceholder,
          prefixIcon: const Icon(PhosphorIconsBold.magnifyingGlass, size: 16),
          suffixIcon: _query.isNotEmpty ? const Icon(PhosphorIconsBold.x, size: 16) : null,
          onSuffixTap: _query.isNotEmpty ? () => _searchController.clear() : null,
        ),
        SizedBox(height: layout.s3),

        // Recent Shelf (if available & no active search)
        if (recents.isNotEmpty) ...[
          Text(
            l10n.fork.personaRecentHeader,
            style: textStyles.label.copyWith(
              color: colors.textTertiary,
              fontSize: 11,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: layout.s2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final p in recents)
                  Padding(
                    padding: EdgeInsets.only(right: layout.s2),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _reactAsPersona(p.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.s2,
                          vertical: layout.s1,
                        ),
                        decoration: BoxDecoration(
                          color: (reaction?.hasPersonaReacted(p.id) ?? false)
                              ? colors.backgroundModifierSelected
                              : colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (reaction?.hasPersonaReacted(p.id) ?? false)
                                ? colors.brandPrimary
                                : colors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FluxerAvatar.user(
                              userId: userSettings.userId,
                              imageUrl: p.avatarHash,
                              fallbackText: p.name,
                              size: 20,
                              showStatus: false,
                            ),
                            SizedBox(width: layout.s1),
                            Text(
                              p.name,
                              style: textStyles.bodySmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: layout.s3),
        ],

        // Root Account Option
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _reactAsRoot,
          child: Container(
            padding: EdgeInsets.all(layout.s2),
            decoration: BoxDecoration(
              color: isRootReacted
                  ? colors.backgroundSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isRootReacted
                  ? Border.all(color: colors.brandPrimary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              children: [
                FluxerAvatar.user(
                  userId: userSettings.userId,
                  imageUrl: userSettings.avatarUrl,
                  avatarColor: userSettings.avatarColor,
                  fallbackText: userSettings.displayName.isNotEmpty
                      ? userSettings.displayName
                      : userSettings.username,
                  size: 36,
                  showStatus: false,
                ),
                SizedBox(width: layout.s2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userSettings.displayName.isNotEmpty
                            ? userSettings.displayName
                            : userSettings.username,
                        style: textStyles.username.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.fork.personaRootAccountLabel,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRootReacted)
                  Icon(
                    PhosphorIconsBold.check,
                    color: colors.brandPrimary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: layout.s2),

        Divider(color: colors.borderColor, height: 1),
        SizedBox(height: layout.s2),

        // Section Title: All Personas / Search Results
        Text(
          _query.isNotEmpty
              ? l10n.fork.personaSearchResultsHeader(filteredPersonas.length)
              : l10n.fork.personaAllHeader(filteredPersonas.length),
          style: textStyles.label.copyWith(
            color: colors.textTertiary,
            fontSize: 11,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: layout.s2),

        if (filteredPersonas.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: layout.s4),
            child: Center(
              child: Text(
                personas.isEmpty
                    ? l10n.fork.personaEmptyState
                    : l10n.fork.personaEmptySearch,
                style: textStyles.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          )
        else
          for (final persona in filteredPersonas) ...[
            _PersonaReactAsListTile(
              persona: persona,
              userId: userSettings.userId,
              isReacted: reaction?.hasPersonaReacted(persona.id) ?? false,
              onSelect: () => _reactAsPersona(persona.id),
            ),
            SizedBox(height: layout.s1),
          ],
      ],
    );
  }
}

class _PersonaReactAsListTile extends StatelessWidget {
  const _PersonaReactAsListTile({
    required this.persona,
    required this.isReacted,
    required this.onSelect,
    this.userId,
  });

  final Persona persona;
  final bool isReacted;
  final VoidCallback onSelect;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;

    final primaryTag = persona.personaTags.isNotEmpty
        ? persona.personaTags.first.displayPattern
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: layout.s2,
          vertical: layout.s2,
        ),
        decoration: BoxDecoration(
          color: isReacted
              ? colors.backgroundSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isReacted
              ? Border.all(color: colors.brandPrimary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            FluxerAvatar.user(
              userId: userId,
              imageUrl: persona.avatarHash,
              fallbackText: persona.name,
              size: 38,
              showStatus: false,
            ),
            SizedBox(width: layout.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona.name,
                    style: textStyles.username.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((persona.pronouns != null &&
                          persona.pronouns!.isNotEmpty) ||
                      (primaryTag != null && primaryTag.isNotEmpty)) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (persona.pronouns != null &&
                            persona.pronouns!.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              persona.pronouns!,
                              style: textStyles.bodySmall.copyWith(
                                color: colors.textTertiary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (primaryTag != null && primaryTag.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '•',
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textTertiaryMuted,
                                ),
                              ),
                            ),
                        ],
                        if (primaryTag != null && primaryTag.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              primaryTag,
                              style: textStyles.label.copyWith(
                                color: colors.textSecondary,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isReacted)
              Icon(
                PhosphorIconsBold.check,
                color: colors.brandPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
