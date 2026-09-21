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

class _TagPairControllers {
  _TagPairControllers({
    required String prefix,
    required String suffix,
    required VoidCallback onChanged,
  })  : prefixController = TextEditingController(text: prefix),
        suffixController = TextEditingController(text: suffix) {
    prefixController.addListener(onChanged);
    suffixController.addListener(onChanged);
  }

  final TextEditingController prefixController;
  final TextEditingController suffixController;

  String get prefix => prefixController.text.trim();
  String get suffix => suffixController.text.trim();

  bool get isNotEmpty => prefix.isNotEmpty || suffix.isNotEmpty;

  void dispose() {
    prefixController.dispose();
    suffixController.dispose();
  }
}

class _EditPersonaBodyState extends ConsumerState<_EditPersonaBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  final List<_TagPairControllers> _tagControllers = [];

  late String _initialName;
  late String _initialPronouns;
  late String _initialBio;
  late List<({String prefix, String suffix})> _initialTags;
  String? _initialAvatarUrl;
  String? _initialBannerUrl;
  int? _initialColor;
  late String _initialVisibility;
  late bool _initialAutoTagDisabled;

  String? _avatarUrl;
  String? _bannerUrl;
  int? _color;
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

    final List<PersonaTag> existingTags = p?.personaTags ?? const <PersonaTag>[];
    if (existingTags.isNotEmpty) {
      _initialTags = existingTags
          .map((PersonaTag t) => (
                prefix: (t.prefix ?? '').trim(),
                suffix: (t.suffix ?? '').trim(),
              ))
          .toList();
    } else {
      _initialTags = [(prefix: '', suffix: '')];
    }

    for (final tag in _initialTags) {
      _tagControllers.add(
        _TagPairControllers(
          prefix: tag.prefix,
          suffix: tag.suffix,
          onChanged: _onFieldChanged,
        ),
      );
    }

    _initialAvatarUrl = p?.avatarUrl;
    _initialBannerUrl = p?.bannerUrl;
    _initialColor = p?.color;
    _initialAutoTagDisabled = p?.autoTagDisabled ?? false;
    _initialVisibility = p?.visibility ?? 'unlisted';

    _nameController = TextEditingController(text: _initialName);
    _pronounsController = TextEditingController(text: _initialPronouns);
    _bioController = TextEditingController(text: _initialBio);

    _nameController.addListener(_onFieldChanged);
    _pronounsController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);

    _avatarUrl = _initialAvatarUrl;
    _bannerUrl = _initialBannerUrl;
    _color = _initialColor;
    _autoTagDisabled = _initialAutoTagDisabled;
    _visibility = _initialVisibility;
  }

  bool get _hasChanges {
    if (_nameController.text.trim() != _initialName ||
        _pronounsController.text.trim() != _initialPronouns ||
        _bioController.text.trim() != _initialBio ||
        _avatarUrl != _initialAvatarUrl ||
        _bannerUrl != _initialBannerUrl ||
        _color != _initialColor ||
        _visibility != _initialVisibility ||
        _autoTagDisabled != _initialAutoTagDisabled) {
      return true;
    }

    final currentTags = _tagControllers
        .where((c) => c.isNotEmpty)
        .map((c) => (prefix: c.prefix, suffix: c.suffix))
        .toList();
    final initialTags = _initialTags
        .where((t) => t.prefix.isNotEmpty || t.suffix.isNotEmpty)
        .toList();

    if (currentTags.length != initialTags.length) {
      return true;
    }
    for (int i = 0; i < currentTags.length; i++) {
      if (currentTags[i].prefix != initialTags[i].prefix ||
          currentTags[i].suffix != initialTags[i].suffix) {
        return true;
      }
    }

    return false;
  }

  void _reset() {
    _nameController.text = _initialName;
    _pronounsController.text = _initialPronouns;
    _bioController.text = _initialBio;

    for (final c in _tagControllers) {
      c.dispose();
    }
    _tagControllers.clear();
    for (final tag in _initialTags) {
      _tagControllers.add(
        _TagPairControllers(
          prefix: tag.prefix,
          suffix: tag.suffix,
          onChanged: _onFieldChanged,
        ),
      );
    }

    setState(() {
      _avatarUrl = _initialAvatarUrl;
      _bannerUrl = _initialBannerUrl;
      _color = _initialColor;
      _autoTagDisabled = _initialAutoTagDisabled;
      _visibility = _initialVisibility;
    });
    widget.canDismissNotifier.value = true;
  }

  void _addTagPair() {
    if (_tagControllers.length >= 5) {
      return;
    }
    setState(() {
      _tagControllers.add(
        _TagPairControllers(
          prefix: '',
          suffix: '',
          onChanged: _onFieldChanged,
        ),
      );
    });
    _onFieldChanged();
  }

  void _removeTagPair(int index) {
    if (index < 0 || index >= _tagControllers.length) {
      return;
    }
    setState(() {
      _tagControllers.removeAt(index).dispose();
      if (_tagControllers.isEmpty) {
        _tagControllers.add(
          _TagPairControllers(
            prefix: '',
            suffix: '',
            onChanged: _onFieldChanged,
          ),
        );
      }
    });
    _onFieldChanged();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _pronounsController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    for (final c in _tagControllers) {
      c.dispose();
    }
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

    final validTags = _tagControllers.where((c) => c.isNotEmpty).toList();

    for (final c in validTags) {
      if (c.prefix.length > 32) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: l10n.personaTagPrefixTooLong,
                variant: FluxerToastVariant.danger,
              ),
            );
        return;
      }
      if (c.suffix.length > 32) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: l10n.personaTagSuffixTooLong,
                variant: FluxerToastVariant.danger,
              ),
            );
        return;
      }
    }

    // Intra-persona duplicate tag pair check
    final seenTags = <String>{};
    for (final tag in validTags) {
      final key = '${tag.prefix}:::${tag.suffix}';
      if (seenTags.contains(key)) {
        final pattern = PersonaTag(
          prefix: tag.prefix.isNotEmpty ? tag.prefix : null,
          suffix: tag.suffix.isNotEmpty ? tag.suffix : null,
        ).displayPattern;
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: "Duplicate tag pair '$pattern' on this persona",
                variant: FluxerToastVariant.danger,
              ),
            );
        return;
      }
      seenTags.add(key);
    }

    // Client-side duplicate tag collision check against own personas
    if (validTags.isNotEmpty) {
      final existingPersonas =
          ref.read(myPersonasProvider).asData?.value ?? const [];
      final currentId = widget.persona?.id;
      for (final tag in validTags) {
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
            if (otherPrefix == tag.prefix && otherSuffix == tag.suffix) {
              final tagDisplay = otherTag.displayPattern.isNotEmpty
                  ? otherTag.displayPattern
                  : '${tag.prefix}...${tag.suffix}';
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
    }

    setState(() => _isSaving = true);
    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final String? pronouns = _pronounsController.text.trim().isEmpty
          ? null
          : _pronounsController.text.trim();
      final String? bio =
          _bioController.text.trim().isEmpty ? null : _bioController.text.trim();

      final List<Map<String, dynamic>> tags = validTags
          .map(
            (c) => PersonaTag(
              prefix: c.prefix.isNotEmpty ? c.prefix : null,
              suffix: c.suffix.isNotEmpty ? c.suffix : null,
            ).toJson(),
          )
          .toList();

      final payload = <String, dynamic>{
        'name': name,
        'avatar_url': _avatarUrl,
        'banner_url': _bannerUrl,
        'color': _color,
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
            color: _color,
            pronouns: pronouns,
            bio: bio,
            autoTagDisabled: _autoTagDisabled,
            visibility: _visibility,
            personaTags: validTags
                .map(
                  (c) => PersonaTag(
                    prefix: c.prefix.isNotEmpty ? c.prefix : null,
                    suffix: c.suffix.isNotEmpty ? c.suffix : null,
                  ),
                )
                .toList(),
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
            color: _color,
            pronouns: pronouns,
            bio: bio,
            autoTagDisabled: _autoTagDisabled,
            visibility: _visibility,
            personaTags: validTags
                .map(
                  (c) => PersonaTag(
                    prefix: c.prefix.isNotEmpty ? c.prefix : null,
                    suffix: c.suffix.isNotEmpty ? c.suffix : null,
                  ),
                )
                .toList(),
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
        _initialTags = validTags
            .map((c) => (prefix: c.prefix, suffix: c.suffix))
            .toList();
        if (_initialTags.isEmpty) {
          _initialTags = [(prefix: '', suffix: '')];
        }
        _initialAvatarUrl = _avatarUrl;
        _initialBannerUrl = _bannerUrl;
        _initialColor = _color;
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

  Future<void> _confirmDeletePersona() async {
    final persona = widget.persona;
    if (persona == null) {
      return;
    }
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

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSaving = true);
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
        widget.canDismissNotifier.value = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    } on Object catch (err, st) {
      talker.error('[EditPersonaSheet] Failed to delete persona: $err', err, st);
      final String errorMessage = userFacingErrorMessage(err, err.toString());
      if (mounted) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: errorMessage,
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
                        key: ValueKey('$_bannerUrl-$_color'),
                        bannerUrl: _bannerUrl,
                        bannerColor: _color != null && _color != 0
                            ? Color(_color! | 0xFF000000)
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
              SizedBox(height: layout.s3),

              // Accent Color
              FluxerColorPickerField(
                label: l10n.accentColorLabel,
                description: l10n.accentColorDescription,
                value: _color ?? 0x5865F2,
                defaultValue: 0x5865F2,
                isDefaultValue: _color == null || _color == 0,
                disabled: _isSaving,
                onReset: () {
                  setState(() => _color = null);
                  _onFieldChanged();
                },
                onChanged: (newColor) {
                  setState(() => _color = newColor);
                  _onFieldChanged();
                },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.personaTagsLabel,
                    style: textStyles.label.copyWith(color: colors.textPrimary),
                  ),
                  FluxerButton.secondary(
                    label: 'Add Tag Pair (${_tagControllers.length}/5)',
                    icon: PhosphorIconsBold.plus,
                    size: FluxerButtonSize.small,
                    fitContent: true,
                    onPressed: (_isSaving || _tagControllers.length >= 5)
                        ? null
                        : _addTagPair,
                  ),
                ],
              ),
              SizedBox(height: layout.s2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.personaTagPrefixLabel,
                      style: textStyles.label.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      l10n.personaTagSuffixLabel,
                      style: textStyles.label.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  if (_tagControllers.length > 1)
                    const SizedBox(width: 44),
                ],
              ),
              SizedBox(height: layout.s1),
              for (int i = 0; i < _tagControllers.length; i++) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: layout.s2),
                  child: Row(
                    children: [
                      Expanded(
                        child: FluxerInput(
                          controller: _tagControllers[i].prefixController,
                          hint: '[',
                          maxLength: 32,
                          enabled: !_isSaving,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: layout.s2),
                        child: Text(
                          'text',
                          style: textStyles.bodySmall.copyWith(
                            color: colors.textPrimaryMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FluxerInput(
                          controller: _tagControllers[i].suffixController,
                          hint: ']',
                          maxLength: 32,
                          enabled: !_isSaving,
                        ),
                      ),
                      if (_tagControllers.length > 1) ...[
                        SizedBox(width: layout.s2),
                        FluxerButton.dangerSecondary(
                          size: FluxerButtonSize.small,
                          isSquare: true,
                          icon: PhosphorIconsBold.trash,
                          onPressed: _isSaving ? null : () => _removeTagPair(i),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                maxLength: 4096,
                showCounter: true,
                enabled: !_isSaving,
              ),
              if (isEditing) ...[
                SizedBox(height: layout.s4),
                FluxerButton.dangerPrimary(
                  label: l10n.personaDeleteTitle,
                  icon: PhosphorIconsFill.trash,
                  onPressed: _isSaving ? null : _confirmDeletePersona,
                ),
              ],
              SizedBox(height: layout.s2),
            ],
      ),
    );
  }
}
