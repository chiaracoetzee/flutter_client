import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fluxer_app/core/talker.dart';

/// A [LayoutBuilder] whose subtree cannot freeze when a descendant is marked
/// dirty while the builder itself is mid-layout.
///
/// A stock [LayoutBuilder] owns its own [BuildScope]: descendants marked dirty
/// are queued there, and the queue is flushed by re-running the layout
/// callback. The first dirty descendant asks the render object to
/// `scheduleLayoutCallback`, which sets a private "rebuild pending" flag and
/// marks the render object as needing layout.
///
/// If that request arrives AFTER the layout callback has run but BEFORE the
/// render object finishes its own `performLayout` (for example a scroll
/// listener that updates a provider while the viewport below is laid out),
/// `markNeedsLayout` is a no-op because layout is already in progress, and the
/// framework then clears the needs-layout flag when `performLayout` returns.
/// The pending flag stays set, so every later `scheduleLayoutCallback` returns
/// early and the scope's queue is never flushed again. Debug builds assert;
/// release builds silently stop rebuilding the whole subtree until its
/// constraints change.
///
/// This render object notices such a request and, instead of losing it,
/// re-dirties its layout on the next frame, which flushes the queued
/// rebuilds exactly as the root build scope would.
class RebuildSafeLayoutBuilder
    extends ConstrainedLayoutBuilder<BoxConstraints> {
  const RebuildSafeLayoutBuilder({
    required super.builder,
    this.debugLabel,
    super.key,
  });

  /// Names this builder in the rescue diagnostic log.
  final String? debugLabel;

  @override
  RenderAbstractLayoutBuilderMixin<BoxConstraints, RenderBox>
  createRenderObject(BuildContext context) =>
      RenderRebuildSafeLayoutBuilder(debugLabel: debugLabel);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRebuildSafeLayoutBuilder renderObject,
  ) {
    renderObject.debugLabel = debugLabel;
  }
}

/// Render object for [RebuildSafeLayoutBuilder].
class RenderRebuildSafeLayoutBuilder extends RenderBox
    with
        RenderObjectWithChildMixin<RenderBox>,
        RenderObjectWithLayoutCallbackMixin,
        RenderAbstractLayoutBuilderMixin<BoxConstraints, RenderBox> {
  RenderRebuildSafeLayoutBuilder({this.debugLabel});

  /// Names this builder in the rescue diagnostic log.
  String? debugLabel;

  /// Total rescues across all instances, for log throttling and tests.
  @visibleForTesting
  static int rescueCount = 0;

  static const int _kLoggedRescuesWithStack = 20;
  static const int _kLogEveryNthRescue = 50;
  static const int _kMaxLoggedFrames = 40;

  // True between the layout callback returning and performLayout finishing:
  // the window in which a stock LayoutBuilder loses rebuild requests.
  bool _layingOutChild = false;
  bool _rebuildRequestedMidLayout = false;
  bool _rescueScheduled = false;
  StackTrace? _midLayoutRequestStack;

  @override
  void scheduleLayoutCallback() {
    if (_layingOutChild) {
      // Calling super here would set the pending flag while markNeedsLayout
      // is swallowed by the in-progress layout: the permanent freeze. Defer
      // the request to the next frame instead.
      _rebuildRequestedMidLayout = true;
      _midLayoutRequestStack ??= StackTrace.current;
      return;
    }
    super.scheduleLayoutCallback();
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    runLayoutCallback();
    _layingOutChild = true;
    try {
      if (child != null) {
        child!.layout(constraints, parentUsesSize: true);
        size = constraints.constrain(child!.size);
      } else {
        size = constraints.biggest;
      }
    } finally {
      _layingOutChild = false;
    }
    if (_rebuildRequestedMidLayout) {
      _rebuildRequestedMidLayout = false;
      _scheduleRescue();
    }
  }

  void _scheduleRescue() {
    if (_rescueScheduled) {
      return;
    }
    _rescueScheduled = true;
    final StackTrace? stack = _midLayoutRequestStack;
    _midLayoutRequestStack = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _rescueScheduled = false;
      if (!attached) {
        return;
      }
      // Re-running layout re-runs the layout callback, which flushes the
      // descendants still queued in this builder's build scope.
      markNeedsLayout();
      _logRescue(stack);
    }, debugLabel: 'RebuildSafeLayoutBuilder.rescue');
  }

  void _logRescue(StackTrace? stack) {
    rescueCount++;
    final int count = rescueCount;
    if (count > _kLoggedRescuesWithStack && count % _kLogEveryNthRescue != 0) {
      return;
    }
    final String label = debugLabel ?? 'unnamed';
    if (count > _kLoggedRescuesWithStack || stack == null) {
      talker.debug('[LayoutBuilderRescue] label=$label count=$count');
      return;
    }
    final String frames = stack
        .toString()
        .split('\n')
        .where((String line) => line.trim().isNotEmpty)
        .take(_kMaxLoggedFrames)
        .join('\n');
    talker.debug(
      '[LayoutBuilderRescue] label=$label count=$count '
      'rebuild requested mid-layout; deferred to next frame\n$frames',
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    assert(
      debugCannotComputeDryLayout(
        reason:
            'Calculating the dry layout would require running the layout '
            'callback speculatively, which might mutate the live render tree.',
      ),
      'RebuildSafeLayoutBuilder does not support dry layout.',
    );
    return Size.zero;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return child?.getDistanceToActualBaseline(baseline) ??
        super.computeDistanceToActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child?.hitTest(result, position: position) ?? false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
