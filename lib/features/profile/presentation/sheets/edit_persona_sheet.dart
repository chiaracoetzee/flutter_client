// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/dio_error_message.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/image_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditPersonaSheet {
  EditPersonaSheet._();

  static Future<PublicPersona?> show(
    BuildContext context, {
    PublicPersona? persona,
  }) {
    final l10n = FluxerLocalizations.of(context);
    final isEditing = persona != null;
    return FluxerBottomSheet.showScrollable<PublicPersona?>(
      context,
      title: isEditing ? l10n.personaEditTitle : l10n.personaCreateTitle,
      useRootNavigator: true,
      minChildSize: 0.6,
      builder: (sheetContext, scrollController, close) {
        return _EditPersonaBody(
          persona: persona,
          scrollController: scrollController,
          onClose: close,
        );
      },
    );
  }
}

class _EditPersonaBody extends ConsumerStatefulWidget {
  const _EditPersonaBody({
    required this.persona,
    required this.scrollController,
    required this.onClose,
  });

  final PublicPersona? persona;
  final ScrollController scrollController;
  final VoidCallback onClose;

  @override
  ConsumerState<_EditPersonaBody> createState() => _EditPersonaBodyState();
}

class _EditPersonaBodyState extends ConsumerState<_EditPersonaBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  late final TextEditingController _prefixController;
  late final TextEditingController _suffixController;

  String? _avatarUrl;
  bool _autoTagDisabled = false;
  String _visibility = 'unlisted';
  bool _isUploadingAvatar = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.persona;
    _nameController = TextEditingController(text: p?.name ?? '');
    _pronounsController = TextEditingController(text: p?.pronouns ?? '');
    _bioController = TextEditingController(text: p?.bio ?? '');

    final firstTag = p?.personaTags.firstOrNull;
    _prefixController = TextEditingController(text: firstTag?.prefix ?? '');
    _suffixController = TextEditingController(text: firstTag?.suffix ?? '');

    _avatarUrl = p?.avatarUrl;
    _autoTagDisabled = p?.autoTagDisabled ?? false;
    _visibility = p?.visibility ?? 'unlisted';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    _prefixController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
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

    setState(() => _isUploadingAvatar = true);
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
        setState(() {
          _avatarUrl = data['avatar_url'] as String;
        });
      }
    } catch (err, st) {
      talker.error('[EditPersonaSheet] Failed to upload avatar: $err', err, st);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ref.read(toastProvider.notifier).show(
            const FluxerToast(
              message: 'Please enter a persona display name',
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }
    if (name.length > 100) {
      ref.read(toastProvider.notifier).show(
            const FluxerToast(
              message: 'Persona display name must be 100 characters or less',
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    final prefix = _prefixController.text.trim();
    final suffix = _suffixController.text.trim();
    if (prefix.length > 32) {
      ref.read(toastProvider.notifier).show(
            const FluxerToast(
              message: 'Persona tag prefix must be 32 characters or less',
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }
    if (suffix.length > 32) {
      ref.read(toastProvider.notifier).show(
            const FluxerToast(
              message: 'Persona tag suffix must be 32 characters or less',
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    // Client-side duplicate tag collision check against own personas
    if (prefix.isNotEmpty || suffix.isNotEmpty) {
      final existingPersonas =
          ref.read(myPersonasProvider).asData?.value ?? const [];
      final currentId = widget.persona?.id;
      for (final other in existingPersonas) {
        if (currentId != null && other.id == currentId) continue;
        for (final otherTag in other.personaTags) {
          final otherPrefix = (otherTag.prefix ?? '').trim();
          final otherSuffix = (otherTag.suffix ?? '').trim();
          if (otherPrefix.isEmpty && otherSuffix.isEmpty) continue;
          if (otherPrefix == prefix && otherSuffix == suffix) {
            final tagDisplay = otherTag.displayPattern.isNotEmpty
                ? otherTag.displayPattern
                : '$prefix...$suffix';
            ref.read(toastProvider.notifier).show(
                  FluxerToast(
                    message:
                        "The tag '$tagDisplay' is already in use by '${other.name}'.",
                    variant: FluxerToastVariant.danger,
                  ),
                );
            return;
          }
        }
      }
    }

    final l10n = FluxerLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final String? pronouns = _pronounsController.text.trim().isEmpty
          ? null
          : _pronounsController.text.trim();
      final String? bio =
          _bioController.text.trim().isEmpty ? null : _bioController.text.trim();

      final List<Map<String, dynamic>> tags = [];
      if (prefix.isNotEmpty || suffix.isNotEmpty) {
        tags.add(PersonaTag(
          prefix: prefix.isNotEmpty ? prefix : null,
          suffix: suffix.isNotEmpty ? suffix : null,
        ).toJson());
      }

      // Preserve any secondary tags configured on this persona
      if (widget.persona != null && widget.persona!.personaTags.length > 1) {
        for (int i = 1; i < widget.persona!.personaTags.length; i++) {
          final t = widget.persona!.personaTags[i];
          final pfx = t.prefix?.trim();
          final sfx = t.suffix?.trim();
          if ((pfx != null && pfx.isNotEmpty) || (sfx != null && sfx.isNotEmpty)) {
            tags.add(PersonaTag(
              prefix: (pfx != null && pfx.isNotEmpty) ? pfx : null,
              suffix: (sfx != null && sfx.isNotEmpty) ? sfx : null,
            ).toJson());
          }
        }
      }

      final payload = <String, dynamic>{
        'name': name,
        'avatar_url': _avatarUrl,
        'pronouns': pronouns,
        'bio': bio,
        'auto_tag_disabled': _autoTagDisabled,
        'persona_tags': tags,
        'visibility': _visibility,
      };

      final PublicPersona result;
      if (widget.persona != null) {
        final Response<dynamic> response = await dio.patch<dynamic>(
          '/users/@me/personas/${widget.persona!.id}',
          data: payload,
        );
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          result = PublicPersona.fromJson(data);
        } else if (data is Map) {
          result = PublicPersona.fromJson(Map<String, dynamic>.from(data));
        } else {
          result = widget.persona!.copyWith(
            name: name,
            avatarUrl: _avatarUrl,
            pronouns: pronouns,
            bio: bio,
            autoTagDisabled: _autoTagDisabled,
            visibility: _visibility,
          );
        }
        ref.invalidate(
          publicPersonaProvider(
            (userId: '', personaId: widget.persona!.id),
          ),
        );
        if (mounted) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.personaUpdatedToast,
                  variant: FluxerToastVariant.success,
                ),
              );
        }
      } else {
        final Response<dynamic> response = await dio.post<dynamic>(
          '/users/@me/personas',
          data: payload,
        );
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          result = PublicPersona.fromJson(data);
        } else if (data is Map) {
          result = PublicPersona.fromJson(Map<String, dynamic>.from(data));
        } else {
          result = PublicPersona(
            id: '',
            name: name,
            avatarUrl: _avatarUrl,
            pronouns: pronouns,
            bio: bio,
            autoTagDisabled: _autoTagDisabled,
            visibility: _visibility,
          );
        }
        if (mounted) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.personaCreatedToast,
                  variant: FluxerToastVariant.success,
                ),
              );
        }
      }

      unawaited(ref.read(myPersonasProvider.notifier).reloadSilently());

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(result);
      }
    } on Object catch (err, st) {
      talker.error('[EditPersonaSheet] Save failed: $err', err, st);
      final String errorMessage = userFacingErrorMessage(err, err.toString());
      if (mounted) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: widget.persona != null
                    ? l10n.personaUpdateFailedToast(errorMessage)
                    : l10n.personaCreateFailedToast(errorMessage),
                variant: FluxerToastVariant.danger,
              ),
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final l10n = FluxerLocalizations.of(context);
    final isEditing = widget.persona != null;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        layout.s4,
        0,
        layout.s4,
        layout.s4 + FluxerBottomSheet.scrollBottomPaddingOf(context),
      ),
      children: [
        // Avatar Section
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.backgroundSecondary,
                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                      ? Icon(
                          PhosphorIconsFill.user,
                          size: 36,
                          color: colors.textPrimaryMuted,
                        )
                      : null,
                ),
                if (_isUploadingAvatar)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: FluxerLoadingSpinner(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: layout.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FluxerButton.secondary(
                    label: _avatarUrl != null
                        ? l10n.personaChangeAvatar
                        : l10n.personaUploadAvatar,
                    icon: PhosphorIconsFill.uploadSimple,
                    size: FluxerButtonSize.small,
                    fitContent: true,
                    isLoading: _isUploadingAvatar,
                    onPressed: _isSaving || _isUploadingAvatar ? null : _pickAvatar,
                  ),
                  if (_avatarUrl != null) ...[
                    SizedBox(height: layout.s2),
                    FluxerButton.ghost(
                      label: l10n.personaRemoveAvatar,
                      icon: PhosphorIconsFill.trash,
                      size: FluxerButtonSize.small,
                      fitContent: true,
                      onPressed: _isSaving || _isUploadingAvatar
                          ? null
                          : () => setState(() => _avatarUrl = null),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s4),

        // Display Name
        FluxerInput(
          controller: _nameController,
          label: l10n.personaDisplayNameLabel,
          hint: l10n.personaDisplayNameHint,
          maxLength: 100,
          enabled: !_isSaving,
          autofocus: !isEditing,
        ),
        SizedBox(height: layout.s3),

        // Pronouns
        FluxerInput(
          controller: _pronounsController,
          label: l10n.personaPronounsLabel,
          hint: l10n.personaPronounsHint,
          maxLength: 100,
          enabled: !_isSaving,
        ),
        SizedBox(height: layout.s3),

        // Persona Tags
        Text(
          l10n.personaTagsLabel,
          style: textStyles.label.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: layout.s1),
        Row(
          children: [
            Expanded(
              child: FluxerInput(
                controller: _prefixController,
                label: l10n.personaTagPrefixLabel,
                maxLength: 20,
                enabled: !_isSaving,
              ),
            ),
            SizedBox(width: layout.s3),
            Expanded(
              child: FluxerInput(
                controller: _suffixController,
                label: l10n.personaTagSuffixLabel,
                maxLength: 20,
                enabled: !_isSaving,
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s3),

        // Visibility Radio Selector
        Text(
          l10n.personaVisibilityLabel,
          style: textStyles.label.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: layout.s2),
        FluxerRadioGroup<String>(
          value: _visibility,
          items: [
            FluxerRadioItem(
              value: 'unlisted',
              label: l10n.personaVisibilityUnlisted,
            ),
            FluxerRadioItem(
              value: 'public',
              label: l10n.personaVisibilityPublic,
            ),
            FluxerRadioItem(
              value: 'private',
              label: l10n.personaVisibilityPrivate,
            ),
          ],
          onChanged: (val) {
            if (!_isSaving) {
              setState(() => _visibility = val);
            }
          },
        ),
        SizedBox(height: layout.s3),

        // Bio
        FluxerInput.multiline(
          controller: _bioController,
          label: l10n.personaBioLabel,
          hint: l10n.personaBioHint,
          maxLines: 4,
          maxLength: 1024,
          showCounter: true,
          enabled: !_isSaving,
        ),
        SizedBox(height: layout.s4),

        // Save / Create button
        SizedBox(
          width: double.infinity,
          child: FluxerButton.primary(
            label: isEditing ? l10n.personaSaveChanges : l10n.personaCreateTitle,
            icon: isEditing ? PhosphorIconsFill.check : PhosphorIconsBold.plus,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ),
      ],
    );
  }
}
