import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum ComposerAttachSource { gallery, files, voice, timestamp }

Future<ComposerAttachSource?> showComposerAttachSourceMenu(
  BuildContext context, {
  bool showVoice = false,
}) async {
  final RenderBox? box = context.findRenderObject() as RenderBox?;
  final Offset position = box != null && box.hasSize
      ? box.localToGlobal(Offset(0, box.size.height))
      : Offset.zero;
  ComposerAttachSource? selected;
  await FluxerActionMenu.show(
    context,
    position: position,
    builder: (BuildContext menuContext, VoidCallback close) {
      final FluxerLocalizations l10n = FluxerLocalizations.of(menuContext);
      return <Widget>[
        FluxerMenuItem(
          label: l10n.chatAttachmentSourceGallery,
          icon: PhosphorIconsFill.image,
          onPressed: () {
            selected = ComposerAttachSource.gallery;
            close();
          },
        ),
        FluxerMenuItem(
          label: l10n.chatAttachmentSourceBrowse,
          icon: PhosphorIconsBold.paperclip,
          onPressed: () {
            selected = ComposerAttachSource.files;
            close();
          },
        ),
        FluxerMenuItem(
          label: l10n.chatInsertTimestamp,
          icon: PhosphorIconsBold.clock,
          onPressed: () {
            selected = ComposerAttachSource.timestamp;
            close();
          },
        ),
        if (showVoice)
          FluxerMenuItem(
            label: l10n.chatAttachmentSendVoiceMessage,
            icon: PhosphorIconsFill.microphone,
            onPressed: () {
              selected = ComposerAttachSource.voice;
              close();
            },
          ),
      ];
    },
  );
  return selected;
}
