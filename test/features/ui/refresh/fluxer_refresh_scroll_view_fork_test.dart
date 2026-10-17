// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/accessibility/presentation/reduced_motion_scope.dart';
import 'package:fluxer_app/features/ui/refresh/fluxer_refresh_scroll_view.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../helpers/pump_fluxer_app.dart';

// Fork: pull to refresh works where scrolling does not bounce: Android, and any
// platform with reduced motion. Before, the list's pull to refresh needed a
// bounce past the top, so on Android it could not be pulled.

Future<int> _pullDown(WidgetTester tester, {bool reducedMotion = false}) async {
  var refreshes = 0;
  await tester.pumpWidget(
    pumpFluxerApp(
      child: ReducedMotionScope(
        enabled: reducedMotion,
        child: Scaffold(
          body: FluxerRefreshScrollView(
            onRefresh: () async => refreshes++,
            slivers: <Widget>[
              SliverList.list(
                children: <Widget>[
                  for (var i = 0; i < 3; i++)
                    SizedBox(height: 60, child: Text('row $i')),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.fling(find.text('row 0'), const Offset(0, 400), 1000);
  await tester.pumpAndSettle();
  return refreshes;
}

void main() {
  testWidgets('pulling down refreshes on Android, with its own indicator', (
    tester,
  ) async {
    expect(await _pullDown(tester), 1);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('pulling down refreshes on iOS, with its own control', (
    tester,
  ) async {
    expect(await _pullDown(tester), 1);
    expect(find.byType(RefreshIndicator), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'pulling down refreshes with reduced motion',
    (tester) async {
      expect(await _pullDown(tester, reducedMotion: true), 1);
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
