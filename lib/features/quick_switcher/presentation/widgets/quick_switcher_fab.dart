import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/quick_switcher/presentation/sheets/quick_switcher_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button_variant.dart';
import 'package:fluxer_app/features/ui/tappable/fluxer_tappable.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Floating action button that opens the mobile quick switcher bottom sheet.
class QuickSwitcherFab extends ConsumerWidget {
  const QuickSwitcherFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    return FluxerTappable(
      key: const ValueKey<String>('quick-switcher-fab'),
      onTap: () => unawaited(QuickSwitcherBottomSheet.show(context, ref)),
      semanticLabel: l10n.quickSwitcherTabSearch,
      builder: (context, states) {
        final colors = context.colors;
        final motion = context.motion;
        final isHovered = states.contains(WidgetState.hovered);

        return AnimatedContainer(
          duration: motion.fast,
          curve: motion.curve,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isHovered ? colors.brandSecondary : colors.brandPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: FluxerButtonVariant.primary.borderColor(
                colors,
                hovered: isHovered,
              )!,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: PhosphorIcon(
            PhosphorIconsFill.lightning,
            size: 24,
            color: colors.textOnBrandPrimary,
          ),
        );
      },
    );
  }
}
