import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/widgets/rebuild_safe_layout_builder.dart';

/// Calls [onLayout] from inside its own layout: while the enclosing layout
/// builder is laying out its child, but outside any build - like a scroll
/// listener that updates a provider during viewport layout.
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

/// Mirrors MessageList / the composer: a widget inside the builder's scope
/// that gets dirtied once while the builder is mid-layout.
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int value = 0;
  bool probed = false;
  final List<AssertionError> swallowedAsserts = <AssertionError>[];

  void bump() => setState(() => value++);

  void _dirtyDuringLayout() {
    if (probed) {
      return;
    }
    probed = true;
    // Debug builds reject scheduling a frame from layout BEFORE the element
    // reaches the dirty list; release builds have no such check. Emulate
    // release so the host is genuinely queued in the builder's scope.
    final WidgetsBinding binding = WidgetsBinding.instance;
    // Test-only toggle of the debug flag to emulate release; no public API.
    // ignore: invalid_use_of_protected_member
    final bool wasBuilding = binding.debugBuildingDirtyElements;
    // Test-only toggle of the debug flag to emulate release; no public API.
    // ignore: invalid_use_of_protected_member
    binding.debugBuildingDirtyElements = false;
    try {
      bump();
      // Deliberate: emulating release, where this assert does not exist.
      // ignore: avoid_catching_errors
    } on AssertionError catch (error) {
      // A stock LayoutBuilder asserts in markNeedsLayout AFTER it has already
      // set its private rebuild-pending flag; release builds have no assert
      // and continue in exactly this state.
      swallowedAsserts.add(error);
    } finally {
      // Restores the flag toggled above.
      // ignore: invalid_use_of_protected_member
      binding.debugBuildingDirtyElements = wasBuilding;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('v$value'),
        _LayoutProbe(
          onLayout: _dirtyDuringLayout,
          child: const SizedBox(height: 10),
        ),
      ],
    );
  }
}

Widget _frame({required bool safe}) {
  Widget builder(BuildContext context, BoxConstraints constraints) =>
      const _Host();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: safe
        ? RebuildSafeLayoutBuilder(builder: builder)
        : LayoutBuilder(builder: builder),
  );
}

void main() {
  group('RebuildSafeLayoutBuilder', () {
    testWidgets(
      'a stock LayoutBuilder never rebuilds again after a descendant is '
      'dirtied mid-layout (control)',
      (WidgetTester tester) async {
        await tester.pumpWidget(_frame(safe: false));
        final _HostState host = tester.state<_HostState>(find.byType(_Host));
        expect(host.probed, isTrue);
        expect(host.swallowedAsserts, hasLength(1));

        await tester.pump();
        await tester.pump();
        expect(host.value, 1);
        expect(find.text('v0'), findsOneWidget);

        // Ordinary setState outside layout is ignored too: the scope is
        // permanently stuck - the frozen list and composer seen on device.
        host.bump();
        await tester.pump();
        await tester.pump();
        expect(host.value, 2);
        expect(find.text('v0'), findsOneWidget);
      },
    );

    testWidgets('defers a mid-layout rebuild to the next frame', (
      WidgetTester tester,
    ) async {
      final int rescuesBefore = RenderRebuildSafeLayoutBuilder.rescueCount;
      await tester.pumpWidget(_frame(safe: true));
      expect(tester.takeException(), isNull);
      final _HostState host = tester.state<_HostState>(find.byType(_Host));
      expect(host.probed, isTrue);
      expect(host.swallowedAsserts, isEmpty);
      expect(RenderRebuildSafeLayoutBuilder.rescueCount, rescuesBefore + 1);

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('v1'), findsOneWidget);

      // And the scope keeps working afterwards.
      host.bump();
      await tester.pump();
      expect(find.text('v2'), findsOneWidget);
    });

    testWidgets('rebuilds on constraint changes like LayoutBuilder', (
      WidgetTester tester,
    ) async {
      final List<double> heights = <double>[];
      Widget frame(double height) => Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            height: height,
            child: RebuildSafeLayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                heights.add(constraints.maxHeight);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(frame(400));
      await tester.pumpWidget(frame(300));
      await tester.pump();
      expect(heights, <double>[400, 300]);
      expect(tester.getSize(find.byType(RebuildSafeLayoutBuilder)).height, 300);
    });
  });
}
