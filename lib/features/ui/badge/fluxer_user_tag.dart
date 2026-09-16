import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';

class FluxerUserTag extends StatelessWidget {
  const FluxerUserTag({
    this.isSystem = false,
    this.label,
    super.key,
  });

  final bool isSystem;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final String text =
        label ?? (isSystem ? l10n.userTagSystem : l10n.userTagBot);
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 15),
      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.smallText.copyWith(
          color: colors.brandPrimaryFill,
          fontSize: 10,
          height: 1,
        ),
      ),
    );
  }
}
