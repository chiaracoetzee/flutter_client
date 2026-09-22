import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button_size.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AttachmentPanelSourceBar extends StatelessWidget {
  const AttachmentPanelSourceBar({
    required this.onPhotosPressed,
    required this.onFilesPressed,
    this.onVoicePressed,
    super.key,
  });

  final VoidCallback onPhotosPressed;
  final VoidCallback onFilesPressed;
  final VoidCallback? onVoicePressed;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final layout = context.layout;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.backgroundFloating,
        borderRadius: layout.radiusFull,
        border: Border.all(color: const Color(0x14FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.18),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.s1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FluxerButton.ghost(
              icon: PhosphorIconsFill.image,
              label: l10n.chatAttachmentPanelPhotos,
              size: FluxerButtonSize.compact,
              fitContent: true,
              onPressed: onPhotosPressed,
            ),
            FluxerButton.ghost(
              icon: PhosphorIconsBold.paperclip,
              label: l10n.chatAttachmentPanelFiles,
              size: FluxerButtonSize.compact,
              fitContent: true,
              onPressed: onFilesPressed,
            ),
            if (onVoicePressed != null)
              FluxerButton.ghost(
                icon: PhosphorIconsFill.microphone,
                label: l10n.voiceMessageTitle,
                size: FluxerButtonSize.compact,
                fitContent: true,
                onPressed: onVoicePressed,
              ),
          ],
        ),
      ),
    );
  }
}
