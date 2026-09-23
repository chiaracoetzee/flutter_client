import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/utils/messages/markdown_timestamp_format.dart';
import 'package:fluxer_app/features/settings/providers/use_12_hour_time_format_provider.dart';
import 'package:fluxer_app/features/ui/tappable/fluxer_gesture_detector.dart';
import 'package:fluxer_app/features/ui/tooltip/fluxer_tooltip.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/clipboard_utils.dart';
import 'package:fluxer_markdown/fluxer_markdown.dart';

double _timestampPillBorderRadius(TextStyle? style) =>
    ((style?.fontSize ?? 14) * (4 / 14)).clamp(3, 6);

double _timestampPillHorizontalPadding(TextStyle? style) =>
    ((style?.fontSize ?? 14) * (3.5 / 14)).clamp(3, 6);

class FluxerTimestampPill extends ConsumerStatefulWidget {
  const FluxerTimestampPill({
    required this.dateTime,
    required this.flag,
    this.baseStyle,
    super.key,
  });

  final DateTime dateTime;
  final String flag;
  final TextStyle? baseStyle;

  @override
  ConsumerState<FluxerTimestampPill> createState() => _FluxerTimestampPillState();
}

class _FluxerTimestampPillState extends ConsumerState<FluxerTimestampPill> {
  bool get _isRelative => widget.flag == 'R';

  @override
  void initState() {
    super.initState();
    if (_isRelative) {
      FluxerRelativeTimeTick.instance
        ..retain()
        ..addListener(_onTick);
    }
  }

  @override
  void didUpdateWidget(covariant FluxerTimestampPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flag != widget.flag) {
      if (oldWidget.flag == 'R') {
        FluxerRelativeTimeTick.instance
          ..removeListener(_onTick)
          ..release();
      }
      if (widget.flag == 'R') {
        FluxerRelativeTimeTick.instance
          ..retain()
          ..addListener(_onTick);
      }
    }
  }

  @override
  void dispose() {
    if (_isRelative) {
      FluxerRelativeTimeTick.instance
        ..removeListener(_onTick)
        ..release();
    }
    super.dispose();
  }

  void _onTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final bool use12Hour = ref.watch(use12HourTimeFormatProvider);

    final String displayText = formatMarkdownTimestamp(
      widget.dateTime,
      widget.flag,
      l10n,
      use12Hour: use12Hour,
    );

    final String tooltipText = widget.flag == 'R'
        ? formatMarkdownTimestamp(
            widget.dateTime,
            'F',
            l10n,
            use12Hour: use12Hour,
          )
        : formatMarkdownTimestamp(
            widget.dateTime,
            'R',
            l10n,
            use12Hour: use12Hour,
          );

    return FluxerTooltip(
      message: tooltipText,
      child: FluxerGestureDetector(
        onTap: () async {
          await copyToClipboard(
            context: context,
            value: displayText,
            message: l10n.timestampCopied,
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                (MediaQuery.sizeOf(context).width * 0.75).clamp(160.0, 360.0),
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colors.textPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(
                _timestampPillBorderRadius(widget.baseStyle),
              ),
              border: Border.all(
                color: context.colors.textPrimary.withValues(alpha: 0.12),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: _timestampPillHorizontalPadding(widget.baseStyle),
              vertical: 1,
            ),
            child: Text(
              displayText,
              style: (widget.baseStyle ?? context.textStyles.messageText).copyWith(
                color: context.colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
