import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/frame_safe_value_notifier.dart';

/// Calls [onLayout] from inside its own layout, like a scroll notification a
/// viewport dispatches from `applyContentDimensions`.
class _LayoutProbe extends SingleChildRenderObjectWidget {
  const _LayoutProbe({required this.onLayout});

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FrameSafeValueNotifier', () {
    test('writes outside a frame apply synchronously', () {
      final FrameSafeValueNotifier<bool> notifier =
          FrameSafeValueNotifier<bool>(false);
      addTearDown(notifier.dispose);
      int notifications = 0;
      notifier
        ..addListener(() => notifications++)
        ..value = true;
      expect(notifier.value, isTrue);
      expect(notifier.hasPendingWrite, isFalse);
      expect(notifications, 1);
    });

    testWidgets('a write during layout lands at the end of the frame', (
      WidgetTester tester,
    ) async {
      final FrameSafeValueNotifier<bool> notifier =
          FrameSafeValueNotifier<bool>(false);
      addTearDown(notifier.dispose);
      final List<SchedulerPhase> notifiedIn = <SchedulerPhase>[];
      notifier.addListener(
        () => notifiedIn.add(SchedulerBinding.instance.schedulerPhase),
      );
      bool wroteDuringLayout = false;
      bool? valueRightAfterWrite;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: <Widget>[
              ListenableBuilder(
                listenable: notifier,
                builder: (BuildContext context, Widget? child) =>
                    Text('defer=${notifier.value}'),
              ),
              _LayoutProbe(
                onLayout: () {
                  if (wroteDuringLayout) {
                    return;
                  }
                  wroteDuringLayout = true;
                  notifier.value = true;
                  valueRightAfterWrite = notifier.value;
                },
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(wroteDuringLayout, isTrue);
      // Not applied mid-layout: listeners did not run inside layout.
      expect(valueRightAfterWrite, isFalse);
      // Applied in this frame's post-frame phase.
      expect(notifier.value, isTrue);
      expect(notifier.hasPendingWrite, isFalse);
      expect(notifiedIn, <SchedulerPhase>[SchedulerPhase.postFrameCallbacks]);
      expect(find.text('defer=false'), findsOneWidget);

      await tester.pump();
      expect(find.text('defer=true'), findsOneWidget);
    });

    testWidgets('a later synchronous write supersedes a pending one', (
      WidgetTester tester,
    ) async {
      final FrameSafeValueNotifier<bool> notifier =
          FrameSafeValueNotifier<bool>(false);
      addTearDown(notifier.dispose);
      bool wroteDuringLayout = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              // Registered during build, so it runs before the flush the
              // layout-time write schedules: a settle that arrives after a
              // deferred start.
              SchedulerBinding.instance.addPostFrameCallback((_) {
                notifier.value = false;
              });
              return _LayoutProbe(
                onLayout: () {
                  if (wroteDuringLayout) {
                    return;
                  }
                  wroteDuringLayout = true;
                  notifier.value = true;
                },
              );
            },
          ),
        ),
      );

      expect(wroteDuringLayout, isTrue);
      expect(notifier.hasPendingWrite, isFalse);
      expect(notifier.value, isFalse);
    });

    testWidgets('disposing with a pending write is safe', (
      WidgetTester tester,
    ) async {
      final FrameSafeValueNotifier<bool> notifier =
          FrameSafeValueNotifier<bool>(false);
      bool wrote = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              // Runs before the flush: dispose while the write is pending.
              SchedulerBinding.instance.addPostFrameCallback((_) {
                notifier.dispose();
              });
              return _LayoutProbe(
                onLayout: () {
                  if (wrote) {
                    return;
                  }
                  wrote = true;
                  notifier.value = true;
                },
              );
            },
          ),
        ),
      );
      expect(wrote, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
