// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/dio_error_message.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/pickers/expression_picker.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/presentation/widgets/user_profile_banner.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/image_crop_sheet.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/wide_settings_content_layout.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/emoji_picker/fluxer_emoji_picker_sheet.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';
import 'package:fluxer_app/shared/utils/emoji_utils.dart';
import 'package:fluxer_app/shared/utils/image_utils.dart';
import 'package:fluxer_app/shared/widgets/unicode_emoji_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const int _kDefaultProfileAccentColor = 0x4641D9;

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
      title: isEditing ? l10n.fork.personaEditTitle : l10n.fork.personaCreateTitle,
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
  late List<SignatureEmoji> _initialSignatureEmojis;
  List<SignatureEmoji> _signatureEmojis = [];
  String? _initialAvatarHash;
  String? _initialBannerHash;
  int? _initialColor;
  int? _initialAvatarColor;
  late String _initialVisibility;
  late bool _initialAutoTagDisabled;

  String? _avatarHash;
  String? _bannerHash;
  int? _color;
  int? _avatarColor;
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

    final List<SignatureEmoji> existingSigs =
        p?.signatureEmojis ?? const <SignatureEmoji>[];
    _initialSignatureEmojis = List<SignatureEmoji>.from(existingSigs);
    _signatureEmojis = List<SignatureEmoji>.from(existingSigs);

    for (final tag in _initialTags) {
      _tagControllers.add(
        _TagPairControllers(
          prefix: tag.prefix,
          suffix: tag.suffix,
          onChanged: _onFieldChanged,
        ),
      );
    }

    _initialAvatarHash = p?.avatarHash;
    _initialBannerHash = p?.bannerHash;
    _initialColor = p?.color;
    _initialAvatarColor = p?.avatarColor;
    _initialAutoTagDisabled = p?.autoTagDisabled ?? false;
    _initialVisibility = p?.visibility ?? 'unlisted';

    _nameController = TextEditingController(text: _initialName);
    _pronounsController = TextEditingController(text: _initialPronouns);
    _bioController = TextEditingController(text: _initialBio);

    _nameController.addListener(_onFieldChanged);
    _pronounsController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);

    _avatarHash = _initialAvatarHash;
    _bannerHash = _initialBannerHash;
    _color = _initialColor;
    _avatarColor = _initialAvatarColor;
    _autoTagDisabled = _initialAutoTagDisabled;
    _visibility = _initialVisibility;
  }

  bool get _hasChanges {
    if (_nameController.text.trim() != _initialName ||
        _pronounsController.text.trim() != _initialPronouns ||
        _bioController.text.trim() != _initialBio ||
        _avatarHash != _initialAvatarHash ||
        _bannerHash != _initialBannerHash ||
        _color != _initialColor ||
        _avatarColor != _initialAvatarColor ||
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

    if (_signatureEmojis.length != _initialSignatureEmojis.length) {
      return true;
    }
    for (int i = 0; i < _signatureEmojis.length; i++) {
      if (!_signatureEmojis[i].matches(
        emojiName: _initialSignatureEmojis[i].name,
        emojiId: _initialSignatureEmojis[i].id,
      )) {
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

    _signatureEmojis = List<SignatureEmoji>.from(_initialSignatureEmojis);

    setState(() {
      _avatarHash = _initialAvatarHash;
      _bannerHash = _initialBannerHash;
      _color = _initialColor;
      _avatarColor = _initialAvatarColor;
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

    final l10n = FluxerLocalizations.of(context);
    if (ImageUtils.isOverSizeLimit(picked.bytes)) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.imageFileTooLarge,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    final Uint8List uploadBytes;
    final animCheck = ImageUtils.checkAnimated(picked.bytes);
    if (animCheck.isAnimated) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.croppingAnimatedNotSupported,
            ),
          );
      uploadBytes = picked.bytes;
    } else {
      final croppedBytes = await showImageCropSheet(
        context,
        imageBytes: picked.bytes,
        aspectRatio: 1,
        title: l10n.cropAvatar,
        maskShape: CropMaskShape.circle,
      );
      if (croppedBytes == null || !mounted) {
        return;
      }
      uploadBytes = croppedBytes;
    }

    setState(() => _isUploadingAvatar = true);
    try {
      final dataUri = ImageUtils.toDataUri(uploadBytes);
      final Dio dio = ref.read(fluxerDioProvider);
      final response = await dio.post<dynamic>(
        '/users/@me/personas/avatar',
        data: <String, dynamic>{'avatar': dataUri},
      );
      final dynamic data = response.data;
      final newHash = (data is Map)
          ? (data['avatar_hash'] as String?)
          : null;
      if (newHash != null) {
        final newColor = (data['avatar_color'] as num?)?.toInt();
        if (_avatarHash != null && _avatarHash != newHash) {
          unawaited(CachedNetworkImage.evictFromCache(_avatarHash!));
        }
        setState(() {
          _avatarHash = newHash;
          if (newColor != null) {
            _avatarColor = newColor;
          }
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

    final l10n = FluxerLocalizations.of(context);
    if (ImageUtils.isOverSizeLimit(picked.bytes)) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.imageFileTooLarge,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }

    final Uint8List uploadBytes;
    final animCheck = ImageUtils.checkAnimated(picked.bytes);
    if (animCheck.isAnimated) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.croppingAnimatedNotSupported,
            ),
          );
      uploadBytes = picked.bytes;
    } else {
      final croppedBytes = await showImageCropSheet(
        context,
        imageBytes: picked.bytes,
        aspectRatio: 17.0 / 6.0,
        title: l10n.cropBanner,
      );
      if (croppedBytes == null || !mounted) {
        return;
      }
      uploadBytes = croppedBytes;
    }

    setState(() => _isUploadingBanner = true);
    try {
      final dataUri = ImageUtils.toDataUri(uploadBytes);
      final Dio dio = ref.read(fluxerDioProvider);
      final response = await dio.post<dynamic>(
        '/users/@me/personas/banner',
        data: <String, dynamic>{'banner': dataUri},
      );
      final dynamic data = response.data;
      final newHash = (data is Map)
          ? (data['banner_hash'] as String?)
          : null;
      if (newHash != null) {
        if (_bannerHash != null && _bannerHash != newHash) {
          unawaited(CachedNetworkImage.evictFromCache(_bannerHash!));
        }
        setState(() {
          _bannerHash = newHash;
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

  void _addSignatureEmoji() {
    FluxerEmojiPickerSheet.show(
      context,
      visibleTabs: const [ExpressionPickerTab.emojis],
      trackEmojiUsageOnSelect: false,
      onEmojiSelected: (selectedEmoji) {
        final emojiName = selectedEmoji.isCustom
            ? selectedEmoji.name
            : selectedEmoji.surrogates;
        final emojiId = selectedEmoji.isCustom ? selectedEmoji.emojiId : null;

        // Intra-persona duplicate check
        final alreadyAdded = _signatureEmojis.any(
          (s) => s.matches(emojiName: emojiName, emojiId: emojiId),
        );
        if (alreadyAdded) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: FluxerLocalizations.of(context)
                      .fork.personaSignatureEmojiAlreadyAdded,
                  variant: FluxerToastVariant.danger,
                ),
              );
          return;
        }

        // Cross-persona duplicate collision check
        final existingPersonas =
            ref.read(myPersonasProvider).asData?.value ?? const [];
        final currentId = widget.persona?.id;
        for (final other in existingPersonas) {
          if (currentId != null && other.id == currentId) continue;
          final conflict = other.signatureEmojis.any(
            (s) => s.matches(emojiName: emojiName, emojiId: emojiId),
          );
          if (conflict) {
            ref.read(toastProvider.notifier).show(
                  FluxerToast(
                    message: FluxerLocalizations.of(context)
                        .fork.personaSignatureEmojiAlreadyUsedByOther(other.name),
                    variant: FluxerToastVariant.danger,
                  ),
                );
            return;
          }
        }

        setState(() {
          _signatureEmojis.add(
            SignatureEmoji(
              id: emojiId,
              name: emojiName,
              animated: selectedEmoji.animated,
            ),
          );
        });
        _onFieldChanged();
      },
    );
  }

  void _removeSignatureEmoji(int index) {
    setState(() {
      _signatureEmojis.removeAt(index);
    });
    _onFieldChanged();
  }

  Future<void> _save() async {
    final l10n = FluxerLocalizations.of(context);
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.fork.personaNameRequired,
              variant: FluxerToastVariant.danger,
            ),
          );
      return;
    }
    if (name.length > 100) {
      ref.read(toastProvider.notifier).show(
            FluxerToast(
              message: l10n.fork.personaNameTooLong,
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
                message: l10n.fork.personaTagPrefixTooLong,
                variant: FluxerToastVariant.danger,
              ),
            );
        return;
      }
      if (c.suffix.length > 32) {
        ref.read(toastProvider.notifier).show(
              FluxerToast(
                message: l10n.fork.personaTagSuffixTooLong,
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
    final existingPersonas =
        ref.read(myPersonasProvider).asData?.value ?? const [];
    final currentId = widget.persona?.id;
    if (validTags.isNotEmpty) {
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
                      message: l10n.fork.personaTagCollisionError(tagDisplay, other.name),
                      variant: FluxerToastVariant.danger,
                    ),
                  );
              return;
            }
          }
        }
      }
    }

    // Client-side duplicate signature emoji collision check against own personas
    for (final sig in _signatureEmojis) {
      for (final other in existingPersonas) {
        if (currentId != null && other.id == currentId) continue;
        if (other.signatureEmojis.any((s) => s.matches(emojiName: sig.name, emojiId: sig.id))) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.fork.personaSignatureEmojiAlreadyUsedByOther(other.name),
                  variant: FluxerToastVariant.danger,
                ),
              );
          return;
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
        'avatar_hash': _avatarHash,
        'banner_hash': _bannerHash,
        'color': _color,
        'avatar_color': _avatarColor,
        'pronouns': pronouns,
        'bio': bio,
        'auto_tag_disabled': _autoTagDisabled,
        'persona_tags': tags,
        'signature_emojis': _signatureEmojis.map((e) => e.toJson()).toList(),
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
            avatarHash: _avatarHash,
            bannerHash: _bannerHash,
            color: _color,
            avatarColor: _avatarColor,
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
            signatureEmojis: _signatureEmojis,
          );
        }
        final ownUserId = ref.read(userSettingsViewModelProvider).userId;
        if (ownUserId.isNotEmpty) {
          ref.invalidate(
            publicPersonaProvider(
              (userId: ownUserId, personaId: widget.persona!.id),
            ),
          );
          if (widget.persona?.bannerHash != null &&
              widget.persona!.bannerHash != _bannerHash) {
            final oldBannerUrl = FluxerMediaUrl.userBanner(
              userId: ownUserId,
              hash: widget.persona!.bannerHash,
            );
            if (oldBannerUrl != null) {
              unawaited(CachedNetworkImage.evictFromCache(oldBannerUrl));
            }
          }
          if (widget.persona?.avatarHash != null &&
              widget.persona!.avatarHash != _avatarHash) {
            final oldAvatarUrl = FluxerMediaUrl.userAvatar(
              userId: ownUserId,
              hash: widget.persona!.avatarHash,
            );
            if (oldAvatarUrl != null) {
              unawaited(CachedNetworkImage.evictFromCache(oldAvatarUrl));
            }
          }
        }
        if (mounted) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.fork.personaUpdatedToast,
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
            avatarHash: _avatarHash,
            bannerHash: _bannerHash,
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
            signatureEmojis: _signatureEmojis,
          );
        }
        if (mounted) {
          ref.read(toastProvider.notifier).show(
                FluxerToast(
                  message: l10n.fork.personaCreatedToast,
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
        _initialAvatarHash = _avatarHash;
        _initialBannerHash = _bannerHash;
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
                    ? l10n.fork.personaUpdateFailedToast(errorMessage)
                    : l10n.fork.personaCreateFailedToast(errorMessage),
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
      title: l10n.fork.personaDeleteTitle,
      description: l10n.fork.personaDeleteMessage(persona.name),
      centered: true,
      actionsBuilder: (pop) => [
        TextButton(
          onPressed: () => pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => pop(true),
          child: Text(
            l10n.fork.personaDeleteConfirm,
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
                message: l10n.fork.personaDeletedToast,
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

    final currentUserSettings = ref.watch(userSettingsViewModelProvider);
    final bool hasCustomAvatar =
        _avatarHash != null && _avatarHash!.trim().isNotEmpty;
    final int effectiveDefaultColor;
    if (hasCustomAvatar) {
      effectiveDefaultColor = (_avatarColor != null && _avatarColor != 0)
          ? _avatarColor!
          : _kDefaultProfileAccentColor;
    } else {
      if (currentUserSettings.avatarColor != null &&
          currentUserSettings.avatarColor != 0) {
        effectiveDefaultColor = currentUserSettings.avatarColor!;
      } else if (currentUserSettings.accentColor != null &&
          currentUserSettings.accentColor != 0) {
        effectiveDefaultColor = currentUserSettings.accentColor!;
      } else {
        effectiveDefaultColor = _kDefaultProfileAccentColor;
      }
    }

    final String? rootAvatarUrl = currentUserSettings.avatar != null
        ? FluxerMediaUrl.userAvatar(
            userId: currentUserSettings.userId,
            hash: currentUserSettings.avatar,
            animated: true,
          )
        : null;
    final String? customAvatarUrl = _avatarHash == null
        ? null
        : (_avatarHash!.startsWith('http://') ||
                _avatarHash!.startsWith('https://') ||
                _avatarHash!.startsWith('data:'))
            ? _avatarHash
            : FluxerMediaUrl.userAvatar(
                userId: currentUserSettings.userId,
                hash: _avatarHash,
                animated: true,
              );
    final String? effectiveAvatarUrl =
        hasCustomAvatar ? customAvatarUrl : rootAvatarUrl;
    final String? effectiveBannerUrl = _bannerHash == null
        ? null
        : (_bannerHash!.startsWith('http://') ||
                _bannerHash!.startsWith('https://') ||
                _bannerHash!.startsWith('data:'))
            ? _bannerHash
            : FluxerMediaUrl.userBanner(
                userId: currentUserSettings.userId,
                hash: _bannerHash,
                animated: true,
              );
    final bool isColorDefault = _color == null || _color == 0;

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
          // Live Profile Card Preview
          Container(
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: layout.radiusLg,
              border: Border.all(
                color: _color != null && _color != 0
                    ? Color(_color! | 0xFF000000)
                    : Color(effectiveDefaultColor | 0xFF000000),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                // Aspect ratio 2.1 matches the mobile profile sheet (e.g. ~390 / 184)
                final bannerHeight = cardWidth / 2.1;
                const avatarRadius = 36.0;
                const avatarBorderWidth = 4.0;
                const avatarTotalRadius = avatarRadius + avatarBorderWidth;
                final avatarTop = bannerHeight - avatarTotalRadius;
                final stackHeight = bannerHeight + avatarTotalRadius;

                return SizedBox(
                  height: stackHeight + layout.s3,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner (tappable)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: bannerHeight,
                        child: GestureDetector(
                          onTap: _isSaving || _isUploadingBanner
                              ? null
                              : _pickBanner,
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              UserProfileBanner(
                                key: ValueKey(
                                  '$_bannerHash-$_color-$effectiveDefaultColor',
                                ),
                                bannerUrl: effectiveBannerUrl,
                                bannerColor: _color != null && _color != 0
                                    ? Color(_color! | 0xFF000000)
                                    : Color(effectiveDefaultColor | 0xFF000000),
                                height: bannerHeight,
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
                      // Avatar (tappable)
                      Positioned(
                        left: layout.s4,
                        top: avatarTop,
                        child: GestureDetector(
                          onTap: _isSaving || _isUploadingAvatar
                              ? null
                              : _pickAvatar,
                          behavior: HitTestBehavior.opaque,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.backgroundSecondary,
                                width: avatarBorderWidth,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: colors.backgroundPrimary,
                                  backgroundImage:
                                      effectiveAvatarUrl != null &&
                                              effectiveAvatarUrl.isNotEmpty
                                          ? NetworkImage(effectiveAvatarUrl)
                                          : null,
                                  child: effectiveAvatarUrl == null ||
                                          effectiveAvatarUrl.isEmpty
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
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: layout.s3),

          // Avatar Actions
          Row(
            children: [
              FluxerButton.secondary(
                label: _avatarHash != null
                    ? l10n.fork.personaChangeAvatar
                    : l10n.fork.personaUploadAvatar,
                icon: PhosphorIconsFill.uploadSimple,
                size: FluxerButtonSize.small,
                fitContent: true,
                isLoading: _isUploadingAvatar,
                onPressed: _isSaving || _isUploadingAvatar ? null : _pickAvatar,
              ),
              if (_avatarHash != null) ...[
                SizedBox(width: layout.s2),
                FluxerButton.ghost(
                  label: l10n.fork.personaRemoveAvatar,
                  icon: PhosphorIconsFill.trash,
                  size: FluxerButtonSize.small,
                  fitContent: true,
                  onPressed: _isSaving || _isUploadingAvatar
                      ? null
                      : () {
                          final avatarHash = _avatarHash;
                          if (avatarHash != null) {
                            final ownUserId =
                                ref.read(userSettingsViewModelProvider).userId;
                            if (ownUserId.isNotEmpty) {
                              final oldUrl = FluxerMediaUrl.userAvatar(
                                userId: ownUserId,
                                hash: avatarHash,
                              );
                              if (oldUrl != null) {
                                unawaited(
                                  CachedNetworkImage.evictFromCache(oldUrl),
                                );
                              }
                            }
                          }
                          setState(() {
                            _avatarHash = null;
                            _avatarColor = null;
                          });
                          _onFieldChanged();
                        },
                ),
              ],
            ],
          ),
          SizedBox(height: layout.s2),

          // Banner Actions
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
              if (_bannerHash != null) ...[
                SizedBox(width: layout.s2),
                FluxerButton.ghost(
                  label: l10n.removeBanner,
                  icon: PhosphorIconsFill.trash,
                  size: FluxerButtonSize.small,
                  fitContent: true,
                  onPressed: _isSaving || _isUploadingBanner
                      ? null
                      : () {
                          final bannerHash = _bannerHash;
                          if (bannerHash != null) {
                            final ownUserId =
                                ref.read(userSettingsViewModelProvider).userId;
                            if (ownUserId.isNotEmpty) {
                              final oldUrl = FluxerMediaUrl.userBanner(
                                userId: ownUserId,
                                hash: bannerHash,
                              );
                              if (oldUrl != null) {
                                unawaited(
                                  CachedNetworkImage.evictFromCache(oldUrl),
                                );
                              }
                            }
                          }
                          setState(() => _bannerHash = null);
                          _onFieldChanged();
                        },
                ),
              ],
            ],
          ),
          SizedBox(height: layout.s4),

              // Accent Color
              FluxerColorPickerField(
                label: l10n.accentColorLabel,
                description: l10n.accentColorDescription,
                value: isColorDefault ? effectiveDefaultColor : _color!,
                defaultValue: effectiveDefaultColor,
                isDefaultValue: isColorDefault,
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
                label: l10n.fork.personaDisplayNameLabel,
                hint: l10n.fork.personaDisplayNameHint,
                maxLength: 100,
                enabled: !_isSaving,
                autofocus: !isEditing,
              ),
              SizedBox(height: layout.s3),

              // Pronouns
              FluxerInput(
                controller: _pronounsController,
                label: l10n.fork.personaPronounsLabel,
                hint: l10n.fork.personaPronounsHint,
                maxLength: 100,
                enabled: !_isSaving,
              ),
              SizedBox(height: layout.s3),

              // Persona Tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.fork.personaTagsLabel,
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
                      l10n.fork.personaTagPrefixLabel,
                      style: textStyles.label.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      l10n.fork.personaTagSuffixLabel,
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

              // Signature Emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.fork.personaSignatureEmojisLabel,
                    style: textStyles.label.copyWith(color: colors.textPrimary),
                  ),
                  FluxerButton.secondary(
                    label: _signatureEmojis.isEmpty
                        ? l10n.fork.personaAddSignatureEmoji
                        : '${l10n.fork.personaAddSignatureEmoji} (${_signatureEmojis.length})',
                    icon: PhosphorIconsBold.plus,
                    size: FluxerButtonSize.small,
                    fitContent: true,
                    onPressed: _isSaving ? null : _addSignatureEmoji,
                  ),
                ],
              ),
              SizedBox(height: layout.s1),
              Text(
                l10n.fork.personaSignatureEmojisDescription,
                style: textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (_signatureEmojis.isNotEmpty) ...[
                SizedBox(height: layout.s2),
                Wrap(
                  spacing: layout.s2,
                  runSpacing: layout.s2,
                  children: [
                    for (int i = 0; i < _signatureEmojis.length; i++) ...[
                      Builder(
                        builder: (context) {
                          final sig = _signatureEmojis[i];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.borderColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (sig.isCustom)
                                  CachedEmojiImage(
                                    emojiId: sig.id!,
                                    animated: sig.animated ?? false,
                                    size: 20,
                                    requestSize: kCustomEmojiFetchSize,
                                  )
                                else
                                  UnicodeEmojiWidget(
                                    emoji: sig.name,
                                    size: 20,
                                  ),
                                if (sig.isCustom) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    ':${sig.name}:',
                                    style: textStyles.bodySmall.copyWith(
                                      color: colors.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                Semantics(
                                  label: l10n.fork.personaRemoveSignatureEmoji,
                                  button: true,
                                  child: FluxerGestureDetector(
                                    onTap: _isSaving
                                        ? null
                                        : () => _removeSignatureEmoji(i),
                                    child: PhosphorIcon(
                                      PhosphorIconsBold.x,
                                      size: 14,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
              SizedBox(height: layout.s3),

              // Visibility Radio Selector
              Text(
                l10n.fork.personaVisibilityLabel,
                style: textStyles.label.copyWith(color: colors.textPrimary),
              ),
              SizedBox(height: layout.s2),
              FluxerRadioGroup<String>(
                value: _visibility,
                items: [
                  FluxerRadioItem(
                    value: 'unlisted',
                    label: l10n.fork.personaVisibilityUnlisted,
                  ),
                  FluxerRadioItem(
                    value: 'public',
                    label: l10n.fork.personaVisibilityPublic,
                  ),
                  FluxerRadioItem(
                    value: 'private',
                    label: l10n.fork.personaVisibilityPrivate,
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

              // About Me
              FluxerInput.multiline(
                controller: _bioController,
                textCapitalization: TextCapitalization.sentences,
                label: l10n.aboutMeLabel,
                hint: l10n.fork.personaBioHint,
                maxLines: 8,
                maxLength: 4096,
                showCounter: true,
                enabled: !_isSaving,
              ),
              if (isEditing) ...[
                SizedBox(height: layout.s4),
                FluxerButton.dangerPrimary(
                  label: l10n.fork.personaDeleteTitle,
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
