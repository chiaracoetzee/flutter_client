import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/discovery/presentation/widgets/discovery_header.dart';
import 'package:fluxer_app/features/discovery/presentation/widgets/discovery_sidebar.dart';
import 'package:fluxer_app/features/quick_switcher/presentation/widgets/quick_switcher_fab.dart';
import 'package:fluxer_app/features/shell/presentation/responsive_layout.dart';
import 'package:fluxer_app/material_ui.dart';

class DiscoverySidebarColumn extends StatelessWidget {
  const DiscoverySidebarColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = isMobileLayout(context);
    return ColoredBox(
      color: context.colors.channelSidebarBackground,
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DiscoveryHeader(),
                Expanded(child: DiscoverySidebar()),
              ],
            ),
            if (isMobile)
              const Positioned(
                right: 16,
                bottom: 16,
                child: QuickSwitcherFab(),
              ),
          ],
        ),
      ),
    );
  }
}
