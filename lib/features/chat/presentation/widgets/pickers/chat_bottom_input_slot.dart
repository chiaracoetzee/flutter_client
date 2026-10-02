import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/providers/pickers/attachment_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/bottom_input_slot_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/expression_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/mobile_keyboard_metrics_provider.dart';
import 'package:fluxer_app/features/chat/utils/composer/bottom_input_slot_layout.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_panel.dart';
import 'package:fluxer_app/features/shell/presentation/responsive_layout.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/gestures/expandable_sheet_gestures.dart';

class BottomInputSpacer extends ConsumerWidget {
  const BottomInputSpacer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isMobileLayout(context)) {
      return const SizedBox.shrink();
    }

    final bool isPanelOpen = isComposerPanelOpen(
      expressionPanelOpen: ref.watch(expressionPanelProvider),
      attachmentPanelOpen: ref.watch(attachmentPanelProvider),
    );
    final BottomInputSlotState slotState = ref.watch(bottomInputSlotProvider);
    final double slotHeight = slotState.slotHeight;

    if (isPanelOpen) {
      final ({double? anchoredKeyboardHeight, double fallbackKeyboardHeight})
      panelMetrics = ref.watch(
        mobileKeyboardMetricsProvider.select(
          (MobileKeyboardMetricsState metrics) => (
            anchoredKeyboardHeight: metrics.anchoredKeyboardHeight,
            fallbackKeyboardHeight: metrics.fallbackKeyboardHeight,
          ),
        ),
      );
      final double anchorHeight = inlineExpressionPanelAnchorHeight(
        anchoredKeyboardHeight: panelMetrics.anchoredKeyboardHeight,
        fallbackHeight: panelMetrics.fallbackKeyboardHeight,
      );
      final double reservedHeight = resolvePanelReservedLayoutHeight(
        slotHeight: slotHeight,
        netAnchorHeight: anchorHeight,
        grossAnchorHeight: anchorHeight,
        useExactSlotHeight: slotState.slotHeightHeld,
      );
      if (reservedHeight <= 0) {
        return const SizedBox.shrink();
      }
      return _animatedSpacer(context, reservedHeight);
    }

    final double liveKeyboardHeight = ref.watch(
      mobileKeyboardMetricsProvider.select(
        (MobileKeyboardMetricsState metrics) =>
            metrics.isKeyboardVisible ? metrics.liveKeyboardHeight : 0,
      ),
    );
    final double spacerHeight = _keyboardSpacerHeight(
      context,
      slotHeight,
      liveKeyboardHeight,
    );
    if (spacerHeight <= 0) {
      return const SizedBox.shrink();
    }
    return _coloredSpacer(context, spacerHeight);
  }

  double _keyboardSpacerHeight(
    BuildContext context,
    double slotHeight,
    double liveKeyboardHeight,
  ) {
    final double measured = math.max(
      resolvedKeyboardInsetBottom(context),
      liveKeyboardHeight,
    );
    final double resolved = measured > 0 ? measured : slotHeight;
    if (resolved <= 0) {
      return 0;
    }
    return bottomInputKeyboardSpacerHeight(
      slotHeight: resolved,
      homeIndicatorInset: MediaQuery.viewPaddingOf(context).bottom,
    );
  }

  Widget _animatedSpacer(BuildContext context, double height) {
    return expandableSheetAnimatedSize(
      context: context,
      isDragging: false,
      height: height,
      decoration: BoxDecoration(color: context.colors.chatInputBackground),
      child: const SizedBox.shrink(),
    );
  }

  Widget _coloredSpacer(BuildContext context, double height) {
    return ColoredBox(
      color: context.colors.chatInputBackground,
      child: SizedBox(height: height),
    );
  }
}
