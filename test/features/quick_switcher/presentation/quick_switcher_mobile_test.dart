// SPDX-License-Identifier: AGPL-3.0-or-later

// The quick switcher on phones: its button must build there (the primary
// button variant has no border colour on mobile), and its sheet must open at
// full height and keep its search field above the keyboard that field opens.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/platform/fluxer_platform.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/quick_switcher/presentation/sheets/quick_switcher_bottom_sheet.dart';
import 'package:fluxer_app/features/quick_switcher/presentation/widgets/quick_switcher_fab.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../helpers/open_test_database.dart';
import '../../../helpers/pump_fluxer_app.dart';

void main() {
  late FluxerDatabase db;

  setUp(() {
    debugSetFluxerRuntimeMobileFormFactor(value: true);
    // Closed by the helper's own teardown.
    db = openTestDatabase();
  });

  tearDown(() => debugSetFluxerRuntimeMobileFormFactor(value: null));

  testWidgets('the quick switcher button builds on a phone', (tester) async {
    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: <Override>[fluxerDatabaseProvider.overrideWithValue(db)],
        child: const Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned(right: 16, bottom: 16, child: QuickSwitcherFab()),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey<String>('quick-switcher-fab')),
      findsOneWidget,
    );
    await releaseTestWidgetTree(tester);
  });

  testWidgets(
    'the quick switcher sheet opens at full height on a phone with its search field above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        pumpFluxerApp(
          overrides: <Override>[fluxerDatabaseProvider.overrideWithValue(db)],
          child: Scaffold(
            body: Consumer(
              builder: (context, ref, _) => Center(
                child: TextButton(
                  onPressed: () => QuickSwitcherBottomSheet.show(context, ref),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      // Step through the opening animation frame by frame; one long pump is a
      // single frame and would see the sheet where it starts.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final Finder body = find.byWidgetPredicate(
        (Widget widget) =>
            widget.runtimeType.toString() == '_QuickSwitcherSheetBody',
      );
      expect(body, findsOneWidget);
      final double screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      // Full height whatever its content, so it does not resize while typing.
      final RenderBox box = tester.renderObject(body) as RenderBox;
      expect(box.localToGlobal(Offset.zero).dy, lessThan(screenHeight / 4));

      // The search field has focus; open the keyboard over several frames,
      // as Android reports it.
      const double keyboard = 300;
      for (final double fraction in <double>[0.02, 0.1, 0.3, 0.6, 0.85, 1]) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: keyboard * fraction * tester.view.devicePixelRatio,
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final Rect search = tester.getRect(
        find.descendant(of: body, matching: find.byType(EditableText)).first,
      );
      expect(search.top, greaterThanOrEqualTo(0));
      expect(search.bottom, lessThanOrEqualTo(screenHeight - keyboard));
      await releaseTestWidgetTree(tester);
    },
  );
}
