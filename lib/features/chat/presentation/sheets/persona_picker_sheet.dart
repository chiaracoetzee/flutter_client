// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/presentation/sheets/edit_persona_sheet.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/presentation/user_settings_modal.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/avatar/fluxer_avatar.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button_size.dart';
import 'package:fluxer_app/features/ui/input/fluxer_input.dart';
import 'package:fluxer_app/features/ui/tabs/fluxer_segmented_tabs.dart';
import 'package:fluxer_app/features/ui/tabs/fluxer_tabs.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PersonaPickerSheet {
  PersonaPickerSheet._();

  static Future<void> show(BuildContext context) {
    return FluxerBottomSheet.showScrollable<void>(
      context,
      title: 'Select Persona',
      useRootNavigator: true,
      minChildSize: 0.55,
      showDragHandle: true,
      builder: (sheetContext, scrollController, close) {
        return _PersonaPickerBody(
          scrollController: scrollController,
          onClose: close,
        );
      },
    );
  }
}

class _PersonaPickerBody extends ConsumerStatefulWidget {
  const _PersonaPickerBody({
    required this.scrollController,
    required this.onClose,
  });

  final ScrollController scrollController;
  final VoidCallback onClose;

  @override
  ConsumerState<_PersonaPickerBody> createState() => _PersonaPickerBodyState();
}

class _PersonaPickerBodyState extends ConsumerState<_PersonaPickerBody> {
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPersona(String personaId) {
    FluxerHaptics.light();
    ref
        .read(activePersonaProvider.notifier)
        .setActivePersona(personaId, latch: true);
    widget.onClose();
  }

  void _resetToRoot() {
    FluxerHaptics.light();
    ref.read(activePersonaProvider.notifier).unlatch();
    widget.onClose();
  }

  void _openManagePersonas() {
    widget.onClose();
    UserSettingsModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;

    final personasAsync = ref.watch(myPersonasProvider);
    final activeState = ref.watch(activePersonaProvider);
    final rankedPersonas = ref.watch(rankedPersonasProvider);
    final userSettings = ref.watch(userSettingsViewModelProvider);

    final personas = personasAsync.asData?.value ?? const [];

    final filteredPersonas = personas.where((p) {
      if (_query.isEmpty) return true;
      if (p.name.toLowerCase().contains(_query)) return true;
      if (p.systemName?.toLowerCase().contains(_query) ?? false) return true;
      if (p.pronouns?.toLowerCase().contains(_query) ?? false) return true;
      return p.personaTags.any((t) =>
          (t.prefix?.toLowerCase().contains(_query) ?? false) ||
          (t.suffix?.toLowerCase().contains(_query) ?? false));
    }).toList();

    final recents = _query.isEmpty
        ? rankedPersonas.take(5).toList()
        : const <Persona>[];

    final isRootActive =
        !activeState.isLatched || activeState.activePersonaId == null;

    final modeIndex = switch (activeState.mode) {
      PersonaMode.off => 0,
      PersonaMode.manual => 1,
      PersonaMode.last => 2,
    };

    final modeDescription = switch (activeState.mode) {
      PersonaMode.off => 'Sends as root account unless proxy tags are typed.',
      PersonaMode.manual => 'Always sends as selected persona until changed.',
      PersonaMode.last =>
        'Auto-switches to the persona used in your last message.',
    };

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
              'Persona Settings',
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
                      'Manage',
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
          hint: 'Search personas, tags, pronouns...',
          prefixIcon: const Icon(PhosphorIconsBold.magnifyingGlass, size: 16),
          suffixIcon: _query.isNotEmpty ? const Icon(PhosphorIconsBold.x, size: 16) : null,
          onSuffixTap: _query.isNotEmpty ? () => _searchController.clear() : null,
        ),
        SizedBox(height: layout.s3),

        // Mode Segmented Tabs
        FluxerSegmentedTabs(
          expanded: true,
          tabs: const [
            FluxerTab(label: 'Off'),
            FluxerTab(label: 'Manual'),
            FluxerTab(label: 'Last Used'),
          ],
          selectedIndex: modeIndex,
          onChanged: (index) {
            final newMode = switch (index) {
              1 => PersonaMode.manual,
              2 => PersonaMode.last,
              _ => PersonaMode.off,
            };
            ref.read(activePersonaProvider.notifier).setMode(newMode);
          },
        ),
        SizedBox(height: layout.s1),

        // Dynamic Microcopy
        Padding(
          padding: EdgeInsets.symmetric(horizontal: layout.s1),
          child: Text(
            modeDescription,
            style: textStyles.bodySmall.copyWith(
              color: colors.textTertiaryMuted,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: layout.s3),

        // Recent Shelf (if available & no active search)
        if (recents.isNotEmpty) ...[
          Text(
            'RECENT PERSONAS',
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
                      onTap: () => _selectPersona(p.id),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.s2,
                          vertical: layout.s1,
                        ),
                        decoration: BoxDecoration(
                          color: activeState.isLatched &&
                                  activeState.activePersonaId == p.id
                              ? colors.backgroundModifierSelected
                              : colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: activeState.isLatched &&
                                    activeState.activePersonaId == p.id
                                ? colors.brandPrimary
                                : colors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FluxerAvatar(
                              imageUrl: p.avatarUrl,
                              fallbackText: p.name,
                              size: 20,
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

        // Root Account Reset Option
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _resetToRoot,
          child: Container(
            padding: EdgeInsets.all(layout.s2),
            decoration: BoxDecoration(
              color: isRootActive
                  ? colors.backgroundSecondary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isRootActive
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
                        'Root Account (Default)',
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRootActive)
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
              ? 'SEARCH RESULTS (${filteredPersonas.length})'
              : 'ALL PERSONAS (${filteredPersonas.length})',
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
                    ? 'No personas configured yet. Create one via Manage Personas.'
                    : 'No matching personas found.',
                style: textStyles.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          )
        else
          for (final persona in filteredPersonas) ...[
            _PersonaListTile(
              persona: persona,
              isActive: activeState.isLatched &&
                  activeState.activePersonaId == persona.id,
              onSelect: () => _selectPersona(persona.id),
              onLongPress: () async {
                final updated = await EditPersonaSheet.show(
                  context,
                  persona: PublicPersona.fromJson(persona.toJson()),
                );
                if (updated != null && mounted) {
                  ref
                      .read(myPersonasProvider.notifier)
                      .upsertPersona(Persona.fromJson(updated.toJson()));
                }
              },
            ),
            SizedBox(height: layout.s1),
          ],
      ],
    );
  }
}

class _PersonaListTile extends StatelessWidget {
  const _PersonaListTile({
    required this.persona,
    required this.isActive,
    required this.onSelect,
    required this.onLongPress,
  });

  final Persona persona;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;

    final primaryTag = persona.personaTags.isNotEmpty
        ? persona.personaTags.first.displayPattern
        : null;

    final Color? nameColor =
        persona.color != null ? Color(persona.color!) : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: layout.s2,
          vertical: layout.s2,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? colors.backgroundSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: colors.brandPrimary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            FluxerAvatar(
              imageUrl: persona.avatarUrl,
              fallbackText: persona.name,
              size: 38,
            ),
            SizedBox(width: layout.s2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name + System Name badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          persona.name,
                          style: textStyles.username.copyWith(
                            color: nameColor ?? colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (persona.systemName != null &&
                          persona.systemName!.isNotEmpty) ...[
                        SizedBox(width: layout.s1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.backgroundSecondaryLighter,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '[${persona.systemName}]',
                            style: textStyles.label.copyWith(
                              color: colors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Row 2: Pronouns + Tag Syntax
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
            if (isActive)
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
