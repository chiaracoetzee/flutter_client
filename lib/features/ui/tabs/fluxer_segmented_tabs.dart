import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/ui/preview/fluxer_widget_preview.dart';
import 'package:fluxer_app/features/ui/tabs/fluxer_tabs.dart';
import 'package:fluxer_app/features/ui/tappable/fluxer_tappable.dart';
import 'package:fluxer_app/material_ui.dart';

class FluxerSegmentedTabs extends StatelessWidget {
  const FluxerSegmentedTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.expanded = false,
    super.key,
  });

  final List<FluxerTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final layout = context.layout;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundTertiary,
        borderRadius: layout.radiusLg,
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.s1 / 2),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < tabs.length; i++)
              if (expanded)
                Expanded(
                  child: _FluxerSegmentedTabItem(
                    tab: tabs[i],
                    isSelected: i == selectedIndex,
                    onTap: () => onChanged(i),
                    expanded: true,
                  ),
                )
              else
                _FluxerSegmentedTabItem(
                  tab: tabs[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onChanged(i),
                ),
          ],
        ),
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: content,
      );
    }
    return content;
  }
}

class _FluxerSegmentedTabItem extends StatelessWidget {
  const _FluxerSegmentedTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.expanded = false,
  });

  final FluxerTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final layout = context.layout;
    final motion = context.motion;

    return FluxerTappable(
      onTap: onTap,
      selected: isSelected,
      semanticLabel: tab.label,
      excludeChildSemantics: true,
      builder: (context, states) {
        return AnimatedContainer(
          duration: motion.normal,
          curve: motion.curve,
          alignment: expanded ? Alignment.center : null,
          decoration: BoxDecoration(
            color: isSelected ? colors.brandPrimary : Colors.transparent,
            borderRadius: layout.radiusMd,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: layout.s2,
            vertical: expanded ? layout.s1_5 : layout.s1,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (tab.icon != null) ...[
                Icon(
                  tab.icon,
                  size: 16,
                  color: isSelected
                      ? colors.textOnBrandPrimary
                      : colors.textSecondary,
                ),
                SizedBox(width: layout.s1),
              ],
              AnimatedDefaultTextStyle(
                duration: motion.normal,
                curve: motion.curve,
                style: textStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colors.textOnBrandPrimary
                      : colors.textSecondary,
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

@FluxerWidgetPreview(name: 'Default', group: 'FluxerSegmentedTabs')
Widget fluxerSegmentedTabsPreview() {
  return FluxerSegmentedTabs(
    tabs: const [
      FluxerTab(label: 'Day'),
      FluxerTab(label: 'Week'),
      FluxerTab(label: 'Month'),
    ],
    selectedIndex: 0,
    onChanged: (_) {},
  );
}
