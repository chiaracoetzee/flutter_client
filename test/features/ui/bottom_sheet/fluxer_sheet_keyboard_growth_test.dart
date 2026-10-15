// SPDX-License-Identifier: AGPL-3.0-or-later

// A sheet sized to its content must stay above the keyboard as the keyboard
// opens. Android reports the keyboard's inset growing over a dozen or so
// frames, not in one step, so the sheet has to follow the inset all the way.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/input/fluxer_input.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../helpers/pump_fluxer_app.dart';

const Key _fieldKey = ValueKey<String>('sheet-field');

/// Logical keyboard insets, one per frame, as Android reports an opening
/// keyboard.
const List<double> _keyboardOpening = <double>[
  6,
  24,
  60,
  110,
  165,
  215,
  255,
  282,
  296,
  300,
];

Future<void> _openSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    pumpFluxerApp(
      child: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => unawaited(
                FluxerBottomSheet.showScrollable<void>(
                  context,
                  builder: (sheetContext, scrollController, close) => ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: const <Widget>[
                      FluxerInput(key: _fieldKey, hint: 'Search'),
                      SizedBox(height: 48),
                      SizedBox(height: 48),
                      SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await _pumpFrames(tester, 10);
}

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

double _screenHeight(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

void main() {
  testWidgets(
    'a sheet sized to its content keeps its field above a keyboard that opens over several frames',
    (tester) async {
      await _openSheet(tester);
      await tester.tap(find.byKey(_fieldKey));
      for (final double inset in _keyboardOpening) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: inset * tester.view.devicePixelRatio,
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await _pumpFrames(tester, 10);

      final Rect field = tester.getRect(find.byKey(_fieldKey));
      final double keyboardTop = _screenHeight(tester) - _keyboardOpening.last;
      expect(field.bottom, lessThanOrEqualTo(keyboardTop));
      expect(field.top, greaterThanOrEqualTo(0));
    },
  );

  testWidgets(
    'a sheet sized to its content settles back down when the keyboard closes',
    (tester) async {
      await _openSheet(tester);
      final double restingTop = tester.getRect(find.byKey(_fieldKey)).top;
      await tester.tap(find.byKey(_fieldKey));
      for (final double inset in _keyboardOpening) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: inset * tester.view.devicePixelRatio,
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await _pumpFrames(tester, 10);
      for (final double inset in _keyboardOpening.reversed.skip(1)) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: inset * tester.view.devicePixelRatio,
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      tester.view.viewInsets = FakeViewPadding.zero;
      await _pumpFrames(tester, 10);

      expect(tester.getRect(find.byKey(_fieldKey)).top, restingTop);
    },
  );
}
