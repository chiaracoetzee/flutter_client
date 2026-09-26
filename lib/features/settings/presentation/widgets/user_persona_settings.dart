// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/presentation/sheets/edit_persona_sheet.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/wide_settings_content_layout.dart';
import 'package:fluxer_app/features/shell/providers/current_user_private_provider.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/image_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserPersonaSettings extends ConsumerStatefulWidget {
  const UserPersonaSettings({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<UserPersonaSettings> createState() =>
      _UserPersonaSettingsState();
}

class _UserPersonaSettingsState extends ConsumerState<UserPersonaSettings> {
  late final TextEditingController _tagTextController;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  Timer? _tagTextDebounce;
  bool _isUploadingTagIcon = false;

  @override
  void initState() {
    super.initState();
    final initialTag = ref.read(systemDisplayTagProvider).text ?? '';
    _tagTextController = TextEditingController(text: initialTag);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      final q = _searchController.text.trim().toLowerCase();
      if (q != _searchQuery) {
        setState(() => _searchQuery = q);
      }
    });
  }

  @override
  void dispose() {
    _tagTextDebounce?.cancel();
    _tagTextController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTagTextChanged(String text) {
    _tagTextDebounce?.cancel();
    _tagTextDebounce = Timer(const Duration(milliseconds: 400), () {
      final currentIcon = ref.read(systemDisplayTagProvider).iconUrl;
      ref
          .read(systemDisplayTagProvider.notifier)
          .updateDisplayTag(text.trim(), currentIcon);
    });
  }

  Future<void> _pickTagIcon() async {
    final picked = await ImageUtils.pickImage();
    if (picked == null || !mounted) return;

    if (ImageUtils.isOverSizeLimit(picked.bytes)) {
      final l10n = FluxerLocalizations.of(context);
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.imageFileTooLarge,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    setState(() => _isUploadingTagIcon = true);
    try {
      final base64String = base64Encode(picked.bytes);
      final dataUri = 'data:image/png;base64,$base64String';
      final Dio dio = ref.read(fluxerDioProvider);
      final response = await dio.post<dynamic>(
        '/users/@me/personas/avatar',
        data: <String, dynamic>{'avatar': dataUri},
      );
      final dynamic data = response.data;
      if (data is Map && data['avatar_url'] is String) {
        final newIconUrl = data['avatar_url'] as String;
        await ref
            .read(systemDisplayTagProvider.notifier)
            .updateDisplayTag(_tagTextController.text.trim(), newIconUrl);
        if (mounted) {
          final l10n = FluxerLocalizations.of(context);
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.personaUpdatedToast,
                  variant: FluxerToastVariant.success,
                ),
              );
        }
      }
    } catch (err, st) {
      talker.error(
        '[UserPersonaSettings] Tag icon upload failed: $err',
        err,
        st,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingTagIcon = false);
      }
    }
  }

  Future<void> _removeTagIcon() async {
    await ref
        .read(systemDisplayTagProvider.notifier)
        .updateDisplayTag(_tagTextController.text.trim(), null);
  }

  Future<void> _confirmDeletePersona(
    BuildContext context,
    Persona persona,
  ) async {
    final l10n = FluxerLocalizations.of(context);
    final colors = context.colors;

    final bool? confirmed = await FluxerModal.show<bool>(
      context,
      title: l10n.personaDeleteTitle,
      description: l10n.personaDeleteMessage(persona.name),
      centered: true,
      actionsBuilder: (pop) => [
        TextButton(
          onPressed: () => pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => pop(true),
          child: Text(
            l10n.personaDeleteConfirm,
            style: TextStyle(color: colors.textDanger),
          ),
        ),
      ],
      builder: (_, _) => const SizedBox.shrink(),
    );

    if (confirmed != true) return;

    try {
      final Dio dio = ref.read(fluxerDioProvider);
      await dio.delete<dynamic>('/users/@me/personas/${persona.id}');
      ref.read(myPersonasProvider.notifier).removePersona(persona.id);

      final active = ref.read(activePersonaProvider);
      if (active.activePersonaId == persona.id) {
        await ref.read(activePersonaProvider.notifier).unlatch();
      }

      if (mounted) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: l10n.personaDeletedToast,
                variant: FluxerToastVariant.success,
              ),
            );
      }
    } catch (err, st) {
      talker.error(
        '[UserPersonaSettings] Failed to delete persona: $err',
        err,
        st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = FluxerLocalizations.of(context);
    final colors = context.colors;
    final layout = context.layout;
    final textStyles = context.textStyles;

    final activeState = ref.watch(activePersonaProvider);
    final systemDisplayTag = ref.watch(systemDisplayTagProvider);
    final personasAsync = ref.watch(myPersonasProvider);
    final currentUser = ref.watch(currentUserPrivateReadProvider);

    // Sync tag text controller if state updated externally (e.g. gateway)
    final currentTagText = systemDisplayTag.text ?? '';
    if (!_tagTextController.selection.isValid &&
        _tagTextController.text != currentTagText) {
      _tagTextController.text = currentTagText;
    }

    final List<Persona> personas = personasAsync.asData?.value ?? const [];

    final List<Persona> filteredPersonas = personas.where((p) {
      if (_searchQuery.isEmpty) {
        return true;
      }
      if (p.name.toLowerCase().contains(_searchQuery)) {
        return true;
      }
      if (p.pronouns?.toLowerCase().contains(_searchQuery) ?? false) {
        return true;
      }
      if (p.bio?.toLowerCase().contains(_searchQuery) ?? false) {
        return true;
      }
      return p.personaTags.any((t) =>
          (t.prefix?.toLowerCase().contains(_searchQuery) ?? false) ||
          (t.suffix?.toLowerCase().contains(_searchQuery) ?? false));
    }).toList();

    final Persona? activePersona = activeState.activePersonaId != null
        ? personas
            .where((p) => p.id == activeState.activePersonaId)
            .firstOrNull
        : null;

    final String? userAvatar = currentUser?.avatar != null
        ? FluxerMediaUrl.userAvatar(
            userId: currentUser!.id,
            hash: currentUser.avatar,
          )
        : null;

    final String previewName = activePersona?.name ??
        currentUser?.globalName ??
        currentUser?.username ??
        'User';
    final String? previewAvatar = activePersona?.avatarUrl ?? userAvatar;
    final String tagText = systemDisplayTag.text?.trim() ?? '';
    final String? tagIcon = systemDisplayTag.iconUrl;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: settingsScrollPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Active Persona Mode
          FluxerSettingsSection(
            sectionId: 'persona-settings-mode',
            title: l10n.personaSectionTitle,
            description: l10n.personaSettingsDescription,
            isFirst: true,
            children: [
              FluxerRadioGroup<PersonaMode>(
                value: activeState.mode,
                items: [
                  FluxerRadioItem(
                    value: PersonaMode.off,
                    label: l10n.personaModeOff,
                    description: l10n.personaModeOffDescription,
                  ),
                  FluxerRadioItem(
                    value: PersonaMode.manual,
                    label: l10n.personaModeManual,
                    description: l10n.personaModeManualDescription,
                  ),
                  FluxerRadioItem(
                    value: PersonaMode.last,
                    label: l10n.personaModeLast,
                    description: l10n.personaModeLastDescription,
                  ),
                ],
                onChanged: (mode) {
                  ref.read(activePersonaProvider.notifier).setMode(mode);
                },
              ),
            ],
          ),

          // Section 2: System Display Tag
          FluxerSettingsSection(
            sectionId: 'persona-settings-display-tag',
            title: l10n.personaDisplayTagSection,
            description: l10n.personaDisplayTagDescription,
            children: [
              FluxerInput(
                controller: _tagTextController,
                label: l10n.personaDisplayTagLabel,
                hint: l10n.personaDisplayTagHint,
                maxLength: 32,
                onChanged: _onTagTextChanged,
              ),
              // Display Tag Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.personaDisplayTagIconLabel,
                    style: textStyles.label.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: layout.s1_5),
                  Wrap(
                    spacing: layout.s2,
                    runSpacing: layout.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (tagIcon != null && tagIcon.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(layout.s1),
                          child: Image.network(
                            tagIcon,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, _) => Container(
                              width: 36,
                              height: 36,
                              color: colors.backgroundSecondary,
                              child: Icon(
                                PhosphorIconsBold.imageBroken,
                                size: 18,
                                color: colors.textPrimaryMuted,
                              ),
                            ),
                          ),
                        ),
                        FluxerButton.secondary(
                          size: FluxerButtonSize.small,
                          fitContent: true,
                          label: l10n.personaChangeTagIcon,
                          icon: PhosphorIconsBold.image,
                          isLoading: _isUploadingTagIcon,
                          onPressed: _isUploadingTagIcon ? null : _pickTagIcon,
                        ),
                        FluxerButton.ghost(
                          size: FluxerButtonSize.small,
                          fitContent: true,
                          label: l10n.personaRemoveTagIcon,
                          icon: PhosphorIconsBold.trash,
                          onPressed: _isUploadingTagIcon ? null : _removeTagIcon,
                        ),
                      ] else ...[
                        FluxerButton.primary(
                          size: FluxerButtonSize.small,
                          fitContent: true,
                          label: l10n.personaUploadTagIcon,
                          icon: PhosphorIconsBold.uploadSimple,
                          isLoading: _isUploadingTagIcon,
                          onPressed: _isUploadingTagIcon ? null : _pickTagIcon,
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Chat Preview Card
              Container(
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(layout.s2),
                  border: Border.all(color: colors.borderColor),
                ),
                padding: EdgeInsets.all(layout.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.personaChatPreviewTitle.toUpperCase(),
                      style: textStyles.smallText.copyWith(
                        color: colors.textPrimaryMuted,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: layout.s2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FluxerAvatar(
                          imageUrl: previewAvatar,
                          fallbackText: previewName,
                          size: 38,
                        ),
                        SizedBox(width: layout.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      previewName,
                                      style: textStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (tagText.isNotEmpty ||
                                      (tagIcon != null &&
                                          tagIcon.isNotEmpty)) ...[
                                    SizedBox(width: layout.s1_5),
                                    FluxerUserTag(
                                      isSystem: false,
                                      label:
                                          tagText.isNotEmpty ? tagText : null,
                                      iconUrl: tagIcon,
                                    ),
                                  ],
                                  SizedBox(width: layout.s2),
                                  Text(
                                    '12:00 PM',
                                    style: textStyles.smallText.copyWith(
                                      color: colors.textPrimaryMuted,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: layout.s1),
                              Text(
                                l10n.personaChatPreviewSampleMessage,
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Section 3: Configured Personas List
          FluxerSettingsSection(
            sectionId: 'persona-settings-list',
            density: FluxerSettingsSectionDensity.compact,
            title: _searchQuery.isNotEmpty
                ? '${l10n.personaListTitle} (${filteredPersonas.length})'
                : '${l10n.personaListTitle} (${personas.length})',
            titleTrailing: FluxerButton.primary(
              size: FluxerButtonSize.small,
              fitContent: true,
              label: l10n.personaAddButton,
              icon: PhosphorIconsBold.plus,
              onPressed: () => EditPersonaSheet.show(context),
            ),
            children: [
              if (personas.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: layout.s1_5),
                  child: FluxerInput(
                    controller: _searchController,
                    hint: l10n.personaSearchPlaceholder,
                    prefixIcon:
                        const Icon(PhosphorIconsBold.magnifyingGlass, size: 16),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? const Icon(PhosphorIconsBold.x, size: 16)
                        : null,
                    onSuffixTap: _searchQuery.isNotEmpty
                        ? () => _searchController.clear()
                        : null,
                  ),
                ),
              if (personasAsync.isLoading && personas.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: FluxerLoadingSpinner(),
                  ),
                )
              else if (personas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(layout.s4),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(layout.s2),
                    border: Border.all(color: colors.borderColor),
                  ),
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsFill.usersThree,
                        size: 44,
                        color: colors.textPrimaryMuted,
                      ),
                      SizedBox(height: layout.s2),
                      Text(
                        l10n.personaEmptyState,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textPrimaryMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: layout.s3),
                      FluxerButton.primary(
                        size: FluxerButtonSize.small,
                        fitContent: true,
                        label: l10n.personaAddButton,
                        icon: PhosphorIconsBold.plus,
                        onPressed: () => EditPersonaSheet.show(context),
                      ),
                    ],
                  ),
                )
              else if (filteredPersonas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(layout.s4),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(layout.s2),
                    border: Border.all(color: colors.borderColor),
                  ),
                  child: Column(
                    children: [
                      PhosphorIcon(
                        PhosphorIconsBold.magnifyingGlass,
                        size: 36,
                        color: colors.textPrimaryMuted,
                      ),
                      SizedBox(height: layout.s2),
                      Text(
                        l10n.personaEmptySearch,
                        style: textStyles.bodySmall.copyWith(
                          color: colors.textPrimaryMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...filteredPersonas.map(
                  (persona) => _buildPersonaCard(
                    context,
                    persona,
                    isThisActive: activeState.isLatched &&
                        activeState.activePersonaId == persona.id,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaCard(
    BuildContext context,
    Persona persona, {
    required bool isThisActive,
  }) {
    final colors = context.colors;
    final layout = context.layout;
    final textStyles = context.textStyles;
    final l10n = FluxerLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(layout.s3),
      decoration: BoxDecoration(
        color: isThisActive
            ? colors.brandPrimary.withValues(alpha: 0.08)
            : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(layout.s2),
        border: Border.all(
          color: isThisActive ? colors.brandPrimary : colors.borderColor,
          width: isThisActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FluxerAvatar(
                imageUrl: persona.avatarUrl,
                fallbackText: persona.name,
                size: 40,
              ),
              SizedBox(width: layout.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            persona.name,
                            style: textStyles.heading.copyWith(
                              fontSize: 16,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (persona.pronouns != null &&
                            persona.pronouns!.isNotEmpty) ...[
                          SizedBox(width: layout.s1_5),
                          Text(
                            '(${persona.pronouns})',
                            style: textStyles.bodySmall.copyWith(
                              color: colors.textPrimaryMuted,
                            ),
                          ),
                        ],
                        if (persona.color != null && persona.color != 0) ...[
                          SizedBox(width: layout.s1_5),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(persona.color! | 0xFF000000),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        if (persona.visibility == 'public') ...[
                          SizedBox(width: layout.s1_5),
                          PhosphorIcon(
                            PhosphorIconsBold.globeSimple,
                            size: 14,
                            color: colors.textPrimaryMuted,
                          ),
                        ] else if (persona.visibility == 'private') ...[
                          SizedBox(width: layout.s1_5),
                          PhosphorIcon(
                            PhosphorIconsBold.lockSimple,
                            size: 14,
                            color: colors.textPrimaryMuted,
                          ),
                        ],
                      ],
                    ),
                    if (persona.personaTags.isNotEmpty ||
                        (persona.bio != null && persona.bio!.isNotEmpty)) ...[
                      SizedBox(height: layout.s1),
                      Wrap(
                        spacing: layout.s1_5,
                        runSpacing: layout.s1,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final tag in persona.personaTags)
                            if (tag.displayPattern.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.backgroundModifierSelected,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag.displayPattern,
                                  style: textStyles.smallText.copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          if (persona.bio != null && persona.bio!.isNotEmpty)
                            Text(
                              persona.bio!,
                              style: textStyles.bodySmall.copyWith(
                                color: colors.textPrimaryMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: layout.s2),
          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isThisActive)
                FluxerButton.secondary(
                  size: FluxerButtonSize.small,
                  fitContent: true,
                  label: l10n.personaActiveBadge,
                  icon: PhosphorIconsFill.lockSimple,
                  onPressed: () =>
                      ref.read(activePersonaProvider.notifier).unlatch(),
                )
              else
                FluxerButton.secondary(
                  size: FluxerButtonSize.small,
                  fitContent: true,
                  label: l10n.personaMakeActive,
                  icon: PhosphorIconsBold.lockSimpleOpen,
                  onPressed: () => ref
                      .read(activePersonaProvider.notifier)
                      .setActivePersona(persona.id, latch: true),
                ),
              SizedBox(width: layout.s2),
              FluxerButton.secondary(
                size: FluxerButtonSize.small,
                isSquare: true,
                icon: PhosphorIconsBold.pencilSimple,
                onPressed: () => EditPersonaSheet.show(
                  context,
                  persona: persona.toPublicPersona(),
                ),
              ),
              SizedBox(width: layout.s2),
              FluxerButton.dangerSecondary(
                size: FluxerButtonSize.small,
                isSquare: true,
                icon: PhosphorIconsBold.trash,
                onPressed: () => _confirmDeletePersona(context, persona),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
