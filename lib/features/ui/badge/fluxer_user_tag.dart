import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';

class FluxerUserTag extends StatelessWidget {
  const FluxerUserTag({
    this.isSystem = false,
    this.label,
    this.iconUrl,
    this.forceIconOnly = false,
    super.key,
  });

  final bool isSystem;
  final String? label;
  final String? iconUrl;
  final bool forceIconOnly;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final String text =
        label ?? (isSystem ? l10n.userTagSystem : l10n.userTagBot);
    final colors = context.colors;
    final hasIcon = iconUrl != null && iconUrl!.trim().isNotEmpty;
    final bool iconOnly = forceIconOnly && hasIcon;

    return Container(
      constraints: const BoxConstraints(minHeight: 15),
      padding: EdgeInsets.symmetric(
        horizontal: iconOnly ? 3.5 : (hasIcon ? 4.5 : 5.5),
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.brandPrimary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasIcon) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: CachedNetworkImage(
                imageUrl: iconUrl!.trim(),
                width: 11,
                height: 11,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            if (!iconOnly) const SizedBox(width: 3.5),
          ],
          if (!iconOnly)
            Flexible(
              child: Text(
                text.toUpperCase(),
                style: context.textStyles.smallText.copyWith(
                  color: colors.brandPrimaryFill,
                  fontSize: 10,
                  height: 1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}
