import 'package:flutter/foundation.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/widgets/rebuild_safe_layout_builder.dart';
import 'package:fluxer_markdown/fluxer_markdown.dart';

/// Extra bottom padding the composer field gets while the character counter
/// shows (see `ComposerInputField`).
const double kComposerCounterPadding = 18;

/// Fork: lets the mobile composer field show fewer lines when the space above
/// the keyboard is short (an attachment, the signal bar, a reply bar), rather
/// than growing to [maxLines] and pushing itself under the keyboard.
///
/// It needs a bounded height from above; with none it passes [maxLines] on.
class ComposerFittedLines extends StatelessWidget {
  const ComposerFittedLines({
    required this.maxLines,
    required this.decoration,
    required this.counterShown,
    required this.builder,
    super.key,
  });

  final int maxLines;

  /// The field's decoration, for its content padding.
  final InputDecoration decoration;

  /// Whether the character counter adds [kComposerCounterPadding].
  final ValueListenable<bool> counterShown;

  final Widget Function(BuildContext context, int maxLines) builder;

  @override
  Widget build(BuildContext context) {
    return RebuildSafeLayoutBuilder(
      debugLabel: 'ComposerFittedLines',
      builder: (BuildContext context, BoxConstraints constraints) {
        return ValueListenableBuilder<bool>(
          valueListenable: counterShown,
          builder: (BuildContext context, bool counter, Widget? _) {
            return builder(
              context,
              composerFittedMaxLines(
                maxHeight: constraints.maxHeight,
                lineHeight: composerLineHeight(
                  context,
                  context.textStyles.inputText,
                ),
                verticalPadding:
                    (decoration.contentPadding?.vertical ?? 0) +
                    (counter ? kComposerCounterPadding : 0),
                maxLines: maxLines,
              ),
            );
          },
        );
      },
    );
  }
}

/// How many whole lines fit in [maxHeight], from 1 to [maxLines].
int composerFittedMaxLines({
  required double maxHeight,
  required double lineHeight,
  required double verticalPadding,
  required int maxLines,
}) {
  if (!maxHeight.isFinite || lineHeight <= 0) {
    return maxLines;
  }
  // The small tolerance keeps a line that fits exactly from being dropped
  // over rounding.
  final int fit = ((maxHeight - verticalPadding + 0.01) / lineHeight).floor();
  return fit.clamp(1, maxLines);
}

/// The height of one line of [style] as the composer field lays it out.
double composerLineHeight(BuildContext context, TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: 'Hg', style: style),
    strutStyle: boundedStrutFor(style, forceHeight: false),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final double height = painter.height;
  painter.dispose();
  return height;
}
