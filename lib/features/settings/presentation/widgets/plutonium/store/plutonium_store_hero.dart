import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/plutonium/store/plutonium_store_style.dart';
import 'package:fluxer_app/features/ui/spinner/fluxer_loading_spinner.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';

class PlutoniumStoreHero extends StatelessWidget {
  const PlutoniumStoreHero({
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.priceLoading,
    super.key,
  });

  final String? monthlyPrice;
  final String? yearlyPrice;
  final bool priceLoading;

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 560;
        final double crownWidth = wide ? 220 : 152;
        final textStyles = context.textStyles;
        return Column(
          children: [
            Image.asset(
              'assets/images/promo-plutonium-crown.png',
              width: crownWidth,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            SizedBox(height: wide ? 20 : 12),
            Text(
              l10n.userSettingsNavFluxerPlutonium,
              textAlign: TextAlign.center,
              style: textStyles.heading.copyWith(
                color: PlutoniumStoreStyle.ink,
              ),
            ),
            const SizedBox(height: 14),
            if (priceLoading)
              const FluxerLoadingSpinner()
            else if (monthlyPrice != null && yearlyPrice != null)
              Semantics(
                label: l10n.storePlutoniumPriceLine(
                  monthlyPrice!,
                  yearlyPrice!,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      monthlyPrice!,
                      style: textStyles.channelName.copyWith(
                        color: PlutoniumStoreStyle.ink,
                      ),
                    ),
                    Text(
                      l10n.storePlutoniumPriceOr,
                      style: textStyles.bodySmall.copyWith(
                        color: PlutoniumStoreStyle.inkMuted,
                      ),
                    ),
                    Text(
                      yearlyPrice!,
                      style: textStyles.channelName.copyWith(
                        color: PlutoniumStoreStyle.ink,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
