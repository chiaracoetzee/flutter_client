import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/limits/instance_limit_provider.dart';
import 'package:fluxer_app/core/limits/limit_key.dart';
import 'package:fluxer_app/features/chat/utils/attachments/attachment_display_utils.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';

/// Fork: the largest avatar, banner or icon the instance accepts.
///
/// The server checks every profile, guild, group DM, application and webhook
/// image against `avatar_max_size`, which admins can change. Upstream's
/// `ImageUtils.isOverSizeLimit` checks a fixed 10 MB instead.
int imageUploadMaxBytes(WidgetRef ref) =>
    ref.read(instanceLimitProvider(LimitKeys.avatarMaxSize));

/// Fork: whether [bytes] is larger than [imageUploadMaxBytes].
bool isImageOverUploadLimit(WidgetRef ref, Uint8List bytes) =>
    bytes.length > imageUploadMaxBytes(ref);

/// Fork: the size limit for display, e.g. "10 MB".
String imageUploadMaxSizeLabel(WidgetRef ref) =>
    formatAttachmentByteSize(imageUploadMaxBytes(ref)) ?? '';

/// Fork: upstream's `imageFileTooLarge` with the instance's limit in place of
/// its fixed "10 MB".
String imageFileTooLargeMessage(FluxerLocalizations l10n, WidgetRef ref) =>
    l10n.fork.imageFileTooLargeMaxSize(imageUploadMaxSizeLabel(ref));
