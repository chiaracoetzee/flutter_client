import 'package:fluxer_app/features/chat/presentation/widgets/composer/composer_inline_timestamp.dart';
import 'package:fluxer_app/features/ui/input/inline_token_text_editing_controller.dart';
import 'package:fluxer_app/material_ui.dart';

/// A timestamp rendered inline as a rich chip in the composer while [wireText]
/// preserves the Discord/Fluxer timestamp markdown (`<t:unix:style>` or combo).
class TimestampInlineToken extends InlineToken {
  TimestampInlineToken({
    required this.epoch,
    required this.style,
    this.onTap,
  });

  int epoch;
  String style;
  final void Function(TimestampInlineToken token)? onTap;

  @override
  String get wireText {
    if (style == 'combo') {
      return '<t:$epoch:f> (<t:$epoch:R>)';
    }
    return '<t:$epoch:$style>';
  }

  @override
  Widget buildInline(BuildContext context, TextStyle? baseStyle) =>
      ComposerInlineTimestamp(
        epoch: epoch,
        style: style,
        baseStyle: baseStyle,
        onTap: onTap != null ? () => onTap!(this) : null,
      );
}
