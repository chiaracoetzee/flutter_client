// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/dio_error_message.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/presentation/widgets/user_profile_banner.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/wide_settings_content_layout.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
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
    final canDismissNotifier = ValueNotifier<bool>(true);

    return FluxerBottomSheet.showScrollable<PublicPersona?>(
      context,
      title: isEditing ? l10n.personaEditTitle : l10n.personaCreateTitle,
      useRootNavigator: true,
      minChildSize: 0.6,
      canDismissNotifier: canDismissNotifier,
      builder: (sheetContext, scrollController, close) {
        return _EditPersonaBody(
          persona: persona,
          scrollController: scrollController,
          canDismissNotifier: canDismissNotifier,
        );
      },
    );
  }
}

class _EditPersonaBody extends ConsumerStatefulWidget {
  const _EditPersonaBody({
    required this.persona,
    required this.scrollController,
    required this.canDismissNotifier,
  });

  final PublicPersona? persona;
  final ScrollController scrollController;
  final ValueNotifier<bool> canDismissNotifier;

  @override
  ConsumerState<_EditPersonaBody> createState() => _EditPersonaBodyState();
}

class _EditPersonaBodyState extends ConsumerState<_EditPersonaBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  late final TextEditingController _prefixController;
  late final TextEditingController _suffixController;

  late String _initialName;
  late String _initialPronouns;
  late String _initialBio;
  late String _initialPrefix;
  late String _initialSuffix;
  String? _initialAvatarUrl;
  String? _initialBannerUrl;
  late String _initialVisibility;
  late bool _initialAutoTagDisabled;

  String? _avatarUrl;
  String? _bannerUrl;
  bool _autoTagDisabled = false;
  String _visibility = 'unlisted';
  bool _isUploadingAvatar = false;
  bool _isUploadingBanner = false;
  bool _isSaving = false;

  void _onFieldChanged() {
    if (!mounted) {
      return;
    }
    final dirty = _hasChanges;
    if (widget.canDismissNotifier.value != !dirty) {
      widget.canDismissNotifier.value = !dirty;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final p = widget.persona;
    _initialName = p?.name ?? '';
    _initialPronouns = p?.pronouns ?? '';
    _initialBio = p?.bio ?? '';

    final firstTag = p?.personaTags.firstOrNull;
    _initialPrefix = firstTag?.prefix ?? '';
    _initialSuffix = firstTag?.suffix ?? '';

    _initialAvatarUrl = p?.avatarUrl;
    _initialBannerUrl = p?.bannerUrl;
    _initialAutoTagDisabled = p?.autoTagDisabled ?? false;
    _initialVisibility = p?.visibility ?? 'unlisted';

    _nameController = TextEditingController(text: _initialName);
    _pronounsController = TextEditingController(text: _initialPronouns);
    _bioController = TextEditingController(text: _initialBio);
    _prefixController = TextEditingController(text: _initialPrefix);
    _suffixController = TextEditingController(text: _initialSuffix);

    _nameController.addListener(_onFieldChanged);
    _pronounsController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _prefixController.addListener(_onFieldChanged);
    _suffixController.addListener(_onFieldChanged);

    _avatarUrl = _initialAvatarUrl;
    _bannerUrl = _initialBannerUrl;
    _autoTagDisabled = _initialAutoTagDisabled;
    _visibility = _initialVisibility;
  }

  bool get _hasChanges {
    return _nameController.text.trim() != _initialName ||
        _pronounsController.text.trim() != _initialPronouns ||
        _bioController.text.trim() != _initialBio ||
        _prefixController.text.trim() != _initialPrefix ||
        _suffixController.text.trim() != _initialSuffix ||
        _avatarUrl != _initialAvatarUrl ||
        _bannerUrl != _initialBannerUrl ||
        _visibility != _initialVisibility ||
        _autoTagDisabled != _initialAutoTagDisabled;
  }

  void _reset() {
    _nameController.text = _initialName;
    _pronounsController.text = _initialPronouns;
    _bioController.text = _initialBio;
    _prefixController.text = _initialPrefix;
    _suffixController.text = _initialSuffix;
    setState(() {
      _avatarUrl = _initialAvatarUrl;
      _bannerUrl = _initialBannerUrl;
      _autoTagDisabled = _initialAutoTagDisabled;
      _visibility = _initialVisibility;
    });
    widget.canDismissNotifier.value = true;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _pronounsController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);
    _prefixController.removeListener(_onFieldChanged);
    _suffixController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    _prefixController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImageUtils.pickImage();
    if (picked == null || !mounted) {
      return;
    }

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
      final dataUri = ImageUtils.toDataUri(picked.bytes);
      final Dio dio = ref.read(fluxerDioProvider);
      final response = await dio.post<dynamic>(
        '/users/@me/personas/avatar',
        data: <String, dynamic>{'avatar': dataUri},
      );
      final dynamic data = response.data;
      if (data is Map && data['avatar_url'] is String) {
        final newUrl = data['avatar_url'] as String;
        if (_avatarUrl != null && _avatarUrl != newUrl) {
          unawaited(CachedNetworkImage.evictFromCache(_avatarUrl!));
        }
        setState(() {
          _avatarUrl = newUrl;
        });
        _onFieldChanged();
      }
    } on Object catch (err, st) {
      talker.error('[EditPersonaSheet] Failed to upload avatar: $err', err, st);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _pickBanner() async {
    final picked = await ImageUtils.pickImage();
    if (picked == null || !mounted) {
      return;
    }

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

    setState(() => _isUploadingBanner = true);
    try {
      final dataUri = ImageUtils.toDataUri(picked.bytes);
      final Dio dio = ref.read(fluxerDioProvider);
      final response = await dio.post<dynamic>(
        '/users/@me/personas/banner',
        data: <String, dynamic>{'banner': dataUri},
      );
      final dynamic data = response.data;
      if (data is Map && data['banner_url'] is String) {
        final newUrl = data['banner_url'] as String;
        if (_bannerUrl != null && _bannerUrl != newUrl) {
          unawaited(CachedNetworkImage.evictFromCache(_bannerUrl!));
        }
        setState(() {
          _bannerUrl = newUrl;
        });
        _onFieldChanged();
      }
    } on Object catch (err, st) {
      talker.error('[EditPersonaSheet] Failed to upload banner: $err', err, st);
    } finally {
      if (mounted) {
        setState(() => _isUploadingBanner = false);
      }
    }
  }

  Future<void> _save() async {
    final l10n = FluxerLocalizations.of(context);
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.personaNameRequired,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }
    if (name.length > 100) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.personaNameTooLong,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    final prefix = _prefixController.text.trim();
    final suffix = _suffixController.text.trim();
    if (prefix.length > 32) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.personaTagPrefixTooLong,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }
    if (suffix.length > 32) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.personaTagSuffixTooLong,
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
        if (currentId != null && other.id == currentId) {
          continue;
        }
        for (final otherTag in other.personaTags) {
          final otherPrefix = (otherTag.prefix ?? '').trim();
          final otherSuffix = (otherTag.suffix ?? '').trim();
          if (otherPrefix.isEmpty && otherSuffix.isEmpty) {
            continue;
          }
          if (otherPrefix == prefix && otherSuffix == suffix) {
            final tagDisplay = otherTag.displayPattern.isNotEmpty
                ? otherTag.displayPattern
                : '$prefix...$suffix';
            ref.read(toastProvider.notifier).show(
                  FluxerToast(
                    message: l10n.personaTagCollisionError(tagDisplay, other.name),
                    variant: FluxerToastVariant.danger,
                  ),
                );
            return;
          }
        }
      }
    }

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
        'banner_url': _bannerUrl,
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
            bannerUrl: _bannerUrl,
            pronouns: pronouns,
            bio: bio,
            autoTagDisabled: _autoTagDisabled,
            visibility: _visibility,
          );
        }
        final ownUserId = ref.read(userSettingsViewModelProvider).userId;
        if (ownUserId.isNotEmpty) {
          ref.invalidate(
            publicPersonaProvider(
              (userId: ownUserId, personaId: widget.persona!.id),
            ),
          );
        }
        if (widget.persona?.bannerUrl != null &&
            widget.persona!.bannerUrl != _bannerUrl) {
          unawaited(CachedNetworkImage.evictFromCache(widget.persona!.bannerUrl!));
        }
        if (widget.persona?.avatarUrl != null &&
            widget.persona!.avatarUrl != _avatarUrl) {
          unawaited(CachedNetworkImage.evictFromCache(widget.persona!.avatarUrl!));
        }
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
            bannerUrl: _bannerUrl,
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

      if (mounted) {
        _initialName = _nameController.text.trim();
        _initialPronouns = _pronounsController.text.trim();
        _initialBio = _bioController.text.trim();
        _initialPrefix = _prefixController.text.trim();
        _initialSuffix = _suffixController.text.trim();
        _initialAvatarUrl = _avatarUrl;
        _initialBannerUrl = _bannerUrl;
        _initialVisibility = _visibility;
        _initialAutoTagDisabled = _autoTagDisabled;

        ref.read(myPersonasProvider.notifier).upsertPersona(result.toPersona());
        unawaited(ref.read(myPersonasProvider.notifier).reloadSilently());
        widget.canDismissNotifier.value = true;
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

    return FluxerSettingsSheet(
      hasUnsavedChanges: _hasChanges,
      isSaving: _isSaving,
      onReset: _reset,
      onSave: _save,
      child: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          layout.s4,
          0,
          layout.s4,
          kSettingsScrollBottomPadding + kSettingsSaveBarScrollExtra,
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
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
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
                                : () {
                                    if (_avatarUrl != null) {
                                      unawaited(CachedNetworkImage.evictFromCache(_avatarUrl!));
                                    }
                                    setState(() => _avatarUrl = null);
                                    _onFieldChanged();
                                  },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: layout.s4),

              // Banner Section
              ClipRRect(
                borderRadius: layout.radiusMd,
                child: SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      UserProfileBanner(
                        key: ValueKey(_bannerUrl),
                        bannerUrl: _bannerUrl,
                        bannerColor: widget.persona?.color != null && widget.persona!.color != 0
                            ? Color(widget.persona!.color! | 0xFF000000)
                            : colors.backgroundSecondary,
                        height: 96,
                      ),
                      if (_isUploadingBanner)
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                            ),
                            child: Center(
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
                ),
              ),
              SizedBox(height: layout.s2),
              Row(
                children: [
                  FluxerButton.secondary(
                    label: l10n.changeBanner,
                    icon: PhosphorIconsFill.image,
                    size: FluxerButtonSize.small,
                    fitContent: true,
                    isLoading: _isUploadingBanner,
                    onPressed: _isSaving || _isUploadingBanner ? null : _pickBanner,
                  ),
                  if (_bannerUrl != null) ...[
                    SizedBox(width: layout.s2),
                    FluxerButton.ghost(
                      label: l10n.removeBanner,
                      icon: PhosphorIconsFill.trash,
                      size: FluxerButtonSize.small,
                      fitContent: true,
                      onPressed: _isSaving || _isUploadingBanner
                          ? null
                          : () {
                              if (_bannerUrl != null) {
                                unawaited(CachedNetworkImage.evictFromCache(_bannerUrl!));
                              }
                              setState(() => _bannerUrl = null);
                              _onFieldChanged();
                            },
                    ),
                  ],
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
                    _onFieldChanged();
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
              SizedBox(height: layout.s2),
            ],
      ),
    );
  }
}
