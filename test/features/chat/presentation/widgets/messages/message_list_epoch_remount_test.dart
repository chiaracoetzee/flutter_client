import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list_scroll_position.dart';
import 'package:fluxer_app/material_ui.dart';

/// Stock [ScrollController.position] semantics (single-position assert), used
/// as the control that reproduces the release crash.
class _StockController extends ScrollController {
  double armedInitialOffset = 0;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    final double initialPixels = armedInitialOffset;
    armedInitialOffset = 0;
    return MessageListScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialPixels,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _EpochHarness extends StatelessWidget {
  const _EpochHarness({
    required this.controller,
    required this.epoch,
    required this.itemCount,
    required this.onStart,
  });

  final ScrollController controller;
  final int epoch;
  final int itemCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.depth == 0 &&
              notification is ScrollStartNotification) {
            // Mirrors MessageList._syncCoastingDefer.
            onStart();
          }
          return false;
        },
        // Mirrors MessageListViewport: a re-anchor remounts the scroll view
        // under a fresh key while the controller is reused.
        child: KeyedSubtree(
          key: ValueKey<int>(epoch),
          child: CustomScrollView(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) =>
                      SizedBox(height: 48, child: Text('Row $index')),
                  childCount: itemCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('anchor-epoch remount', () {
    // A remount whose first layout lands out of range starts a ballistic
    // settle during layout, while the outgoing scroll view's position is
    // still attached (it detaches only in finalizeTree).
    Future<List<ScrollPosition>> remountOutOfRange(
      WidgetTester tester, {
      required ScrollController controller,
      required void Function(double) arm,
    }) async {
      final List<ScrollPosition> seen = <ScrollPosition>[];
      void onStart() => seen.add(controller.position);

      await tester.pumpWidget(
        _EpochHarness(
          controller: controller,
          epoch: 0,
          itemCount: 80,
          onStart: onStart,
        ),
      );
      arm(50000);
      await tester.pumpWidget(
        _EpochHarness(
          controller: controller,
          epoch: 1,
          itemCount: 80,
          onStart: onStart,
        ),
      );
      return seen;
    }

    testWidgets('stock controller throws in the remount frame (control)', (
      WidgetTester tester,
    ) async {
      final _StockController controller = _StockController();
      addTearDown(controller.dispose);
      await remountOutOfRange(
        tester,
        controller: controller,
        arm: (double v) => controller.armedInitialOffset = v,
      );
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('LiveTailScrollController resolves the incoming position', (
      WidgetTester tester,
    ) async {
      final LiveTailScrollController controller = LiveTailScrollController();
      addTearDown(controller.dispose);
      final List<ScrollPosition> seen = await remountOutOfRange(
        tester,
        controller: controller,
        arm: (double v) => controller.armedInitialOffset = v,
      );
      expect(tester.takeException(), isNull);
      expect(seen, isNotEmpty);
      // The outgoing position is gone after the frame; what the handler saw
      // is the one that survived.
      expect(controller.positions.length, 1);
      expect(seen.last, same(controller.position));
      await tester.pumpAndSettle();
      expect(controller.position.outOfRange, isFalse);
    });

    testWidgets('position reads during layout of a remount see the new one', (
      WidgetTester tester,
    ) async {
      final LiveTailScrollController controller = LiveTailScrollController();
      addTearDown(controller.dispose);
      int? positionsDuringLayout;
      ScrollPosition? readDuringLayout;

      Widget build(int epoch) {
        return MaterialApp(
          home: KeyedSubtree(
            key: ValueKey<int>(epoch),
            child: CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints _) {
                      positionsDuringLayout = controller.positions.length;
                      readDuringLayout = controller.position;
                      return const SizedBox(height: 48);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      await tester.pumpWidget(build(0));
      final ScrollPosition first = controller.position;
      await tester.pumpWidget(build(1));
      expect(tester.takeException(), isNull);
      expect(positionsDuringLayout, 2);
      expect(readDuringLayout, isNot(same(first)));
      expect(readDuringLayout, same(controller.position));
    });
  });
}
