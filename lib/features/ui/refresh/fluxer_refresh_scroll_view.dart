import 'dart:ui' show clampDouble;

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoSliverRefreshControl, RefreshIndicatorMode;
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/preview/fluxer_widget_preview.dart';
import 'package:fluxer_app/features/ui/spinner/fluxer_loading_spinner.dart';
import 'package:fluxer_app/material_ui.dart';

class FluxerRefreshScrollView extends StatelessWidget {
  const FluxerRefreshScrollView({
    required this.onRefresh,
    required this.slivers,
    super.key,
    this.controller,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;

  static Widget buildSpinnerIndicator({
    required RefreshIndicatorMode refreshState,
    required double pulledExtent,
    required double refreshTriggerPullDistance,
  }) {
    final double percentageComplete = clampDouble(
      pulledExtent / refreshTriggerPullDistance,
      0,
      1,
    );
    final Widget spinner = switch (refreshState) {
      RefreshIndicatorMode.inactive => const SizedBox.shrink(),
      RefreshIndicatorMode.drag => FluxerLoadingSpinner(
        size: FluxerLoadingSpinnerSize.medium,
        revealProgress: percentageComplete,
      ),
      RefreshIndicatorMode.armed || RefreshIndicatorMode.refresh =>
        const FluxerLoadingSpinner(size: FluxerLoadingSpinnerSize.medium),
      RefreshIndicatorMode.done => Opacity(
        opacity: percentageComplete,
        child: const FluxerLoadingSpinner(
          size: FluxerLoadingSpinnerSize.medium,
        ),
      ),
    };
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(top: 15, left: 0, right: 0, child: Center(child: spinner)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_forkUsesMaterialRefresh(context)) {
      return _ForkMaterialRefreshScrollView(
        onRefresh: onRefresh,
        controller: controller,
        slivers: slivers,
      );
    }
    return CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        if (!FluxerBottomSheet.isInSheet(context))
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
            builder:
                (
                  BuildContext context,
                  RefreshIndicatorMode refreshState,
                  double pulledExtent,
                  double refreshTriggerPullDistance,
                  double refreshIndicatorExtent,
                ) {
                  return buildSpinnerIndicator(
                    refreshState: refreshState,
                    pulledExtent: pulledExtent,
                    refreshTriggerPullDistance: refreshTriggerPullDistance,
                  );
                },
          ),
        ...slivers,
      ],
    );
  }
}

@FluxerWidgetPreview(name: 'Default', group: 'FluxerRefreshScrollView')
Widget fluxerRefreshScrollViewPreview() {
  return SizedBox(
    height: 220,
    width: 280,
    child: ColoredBox(
      color: const Color(0xFF2B2D31),
      child: FluxerRefreshScrollView(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
        },
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(
                  8,
                  (int i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Builder(
                      builder: (BuildContext context) => Text(
                        'Pull from top — row ${i + 1}',
                        style: context.textStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Fork: the pull to refresh above needs scrolling that bounces past the top,
// which iOS has and Android does not (nor does any platform with reduced
// motion, which clamps scrolling), so on Android it could not be pulled at all.
// Where scrolling does not bounce, the list takes Android's own pull to
// refresh instead, which works with clamped scrolling. A list in a bottom sheet
// stays without one, as above.
bool _forkUsesMaterialRefresh(BuildContext context) {
  if (FluxerBottomSheet.isInSheet(context)) {
    return false;
  }
  ScrollPhysics? physics = ScrollConfiguration.of(
    context,
  ).getScrollPhysics(context);
  while (physics != null) {
    if (physics is BouncingScrollPhysics) {
      return false;
    }
    physics = physics.parent;
  }
  return true;
}

class _ForkMaterialRefreshScrollView extends StatelessWidget {
  const _ForkMaterialRefreshScrollView({
    required this.onRefresh,
    required this.slivers,
    this.controller,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: context.colors.brandPrimary,
      backgroundColor: context.colors.backgroundSecondary,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
