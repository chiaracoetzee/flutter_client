import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list_scroll_position.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list_viewport.dart';
import 'package:fluxer_app/features/chat/utils/messages/channel_message_stream.dart';
import 'package:fluxer_app/material_ui.dart';

/// Calls [onLayout] from inside its own layout - i.e. while the enclosing
/// sliver is mid-layout, but outside any build - like a scroll notification
/// or listener that dirties an ancestor during viewport layout.
class _LayoutProbe extends SingleChildRenderObjectWidget {
  const _LayoutProbe({required this.onLayout, super.child});

  final VoidCallback onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLayoutProbe(onLayout);

  @override
  void updateRenderObject(BuildContext context, _RenderLayoutProbe render) {
    render.onLayout = onLayout;
  }
}

class _RenderLayoutProbe extends RenderProxyBox {
  _RenderLayoutProbe(this.onLayout);

  VoidCallback onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout();
  }
}

/// Mirrors MessageList: a host whose rebuild re-anchors (bumps the epoch and
/// remounts the scroll view). The first row laid out dirties the host once.
class _Host extends StatefulWidget {
  const _Host({required this.isolated});

  /// True: the real [MessageListViewport] (with its build scope boundary).
  /// False: the same structure without the boundary (control).
  final bool isolated;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final LiveTailScrollController controller = LiveTailScrollController();
  final GlobalKey centerKey = GlobalKey();
  int epoch = 0;
  bool remountOnNextBuild = false;
  bool probed = false;

  static const int _count = 60;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _dirtyHostDuringLayout() {
    if (probed) {
      return;
    }
    probed = true;
    // Debug builds reject scheduling a frame from layout BEFORE the element
    // reaches the dirty list; release builds have no such check. Emulate
    // release so the host is genuinely dirty in the root scope mid-layout.
    final WidgetsBinding binding = WidgetsBinding.instance;
    // Test-only toggle of the debug flag to emulate release; no public API.
    // ignore: invalid_use_of_protected_member
    final bool wasBuilding = binding.debugBuildingDirtyElements;
    // Test-only toggle of the debug flag to emulate release; no public API.
    // ignore: invalid_use_of_protected_member
    binding.debugBuildingDirtyElements = false;
    try {
      setState(() => remountOnNextBuild = true);
    } finally {
      // Restores the flag toggled above.
      // ignore: invalid_use_of_protected_member
      binding.debugBuildingDirtyElements = wasBuilding;
    }
  }

  Widget _row(BuildContext context, int dataIndex) {
    final Widget row = SizedBox(
      key: ValueKey<int>(dataIndex),
      height: 40,
      child: Text('Row $dataIndex'),
    );
    // Leading sliver builds newest-first: the first row created is the last
    // data index, and more rows are created after it in the same layout.
    if (dataIndex == _count - 1) {
      return _LayoutProbe(onLayout: _dirtyHostDuringLayout, child: row);
    }
    return row;
  }

  @override
  Widget build(BuildContext context) {
    if (remountOnNextBuild) {
      // MessageList's mid-build re-anchor: direct field writes.
      remountOnNextBuild = false;
      epoch++;
    }
    if (!widget.isolated) {
      return KeyedSubtree(
        key: ValueKey<int>(epoch),
        child: CustomScrollView(
          controller: controller,
          center: centerKey,
          anchor: 1,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) =>
                      _row(context, _count - 1 - index),
                  childCount: _count,
                ),
              ),
            ),
            SliverToBoxAdapter(key: centerKey, child: const SizedBox.shrink()),
          ],
        ),
      );
    }
    return MessageListViewport(
      anchorEpoch: epoch,
      stream: List<ChannelStreamItem>.generate(
        _count,
        (_) => const ChannelStreamItem(type: ChannelStreamType.divider),
      ),
      anchorId: null,
      anchorFraction: 1,
      anchorEdge: MessageListAnchorEdge.after,
      controller: controller,
      centerKey: centerKey,
      itemBuilder: _row,
      childIndexForKey:
          (Key key, int start, int end, {required bool reverse}) => null,
      scrollCacheExtentPixels: 250,
      onScrollNotification: (_) => false,
      onScrollMetricsNotification: (_) => false,
      onPointerDown: (_) {},
      onPointerUp: (_) {},
      isLoadingMore: false,
      isLoadingNewer: false,
      trailingInset: 0,
    );
  }
}

void main() {
  group('MessageListScrollViewBuildScope', () {
    testWidgets(
      'without the boundary, an ancestor dirtied mid-layout is rebuilt '
      'inside the sliver layout (control)',
      (WidgetTester tester) async {
        final List<String> errors = <String>[];
        final FlutterExceptionHandler? previous = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          errors.add(details.exceptionAsString());
        };
        try {
          await tester.pumpWidget(
            const MaterialApp(home: _Host(isolated: false)),
          );
          await tester.pumpWidget(const SizedBox.shrink());
        } finally {
          FlutterError.onError = previous;
        }
        // Debug builds assert "wrong build scope"; release builds rebuild the
        // host. Either way the remount detaches the sliver being laid out -
        // the same `Null check operator` cascade logged on device.
        expect(errors.first, contains('wrong build scope'));
        expect(
          errors.skip(1),
          contains(contains('Null check operator used on a null value')),
        );
      },
    );

    testWidgets(
      'the viewport defers an ancestor dirtied mid-layout to the next frame',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: _Host(isolated: true)));
        expect(tester.takeException(), isNull);
        final _HostState host = tester.state<_HostState>(find.byType(_Host));
        expect(host.probed, isTrue);
        // Not rebuilt inside layout: the re-anchor is still pending.
        expect(host.epoch, 0);

        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(host.epoch, 1);
        expect(host.controller.positions.length, 1);
        expect(find.text('Row ${_HostState._count - 1}'), findsOneWidget);
      },
    );

    testWidgets('constraint changes do not rebuild the scroll view', (
      WidgetTester tester,
    ) async {
      int builds = 0;
      final Widget child = Builder(
        builder: (BuildContext context) {
          builds++;
          return const SizedBox.expand();
        },
      );
      Widget frame(double height) => Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            height: height,
            child: MessageListScrollViewBuildScope(child: child),
          ),
        ),
      );
      await tester.pumpWidget(frame(400));
      await tester.pumpWidget(frame(300));
      await tester.pumpWidget(frame(200));
      expect(builds, 1);
    });
  });
}
