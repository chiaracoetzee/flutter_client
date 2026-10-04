import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/presentation/signal_bar_strip.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../helpers/pump_fluxer_app.dart';

const SignalBarSignal _reading = SignalBarSignal(
  id: 'reading',
  emojiName: '📖',
  animated: false,
  label: 'Reading',
);
const SignalBarSignal _done = SignalBarSignal(
  id: 'done',
  emojiName: '✅',
  animated: false,
);

SignalEntry _entry(String signalId, String userId, {String? persona}) {
  return SignalEntry(
    signalId: signalId,
    userId: userId,
    username: 'user$userId',
    personaId: persona == null ? null : 'p$userId',
    personaName: persona,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<String> toggles = <String>[];
  final List<String> details = <String>[];
  int collapseTaps = 0;

  setUp(() {
    toggles.clear();
    details.clear();
    collapseTaps = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    List<SignalEntry> entries = const <SignalEntry>[],
    bool collapsed = false,
    bool canToggle = true,
    double width = 400,
    List<SignalBarSignal> signals = const <SignalBarSignal>[_reading, _done],
  }) async {
    await tester.pumpWidget(
      pumpFluxerApp(
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: width,
              child: SignalBarView(
                signals: signals,
                entries: entries,
                currentUserId: '1',
                collapsed: collapsed,
                backgroundColor: const Color(0xFF26272D),
                dividerColor: const Color(0xFF3C3E47),
                onToggle: canToggle
                    ? (SignalBarSignal signal, {required bool mine}) =>
                          toggles.add('${signal.id}:$mine')
                    : null,
                onDetails:
                    (SignalBarSignal signal, List<SignalEntry> entries) =>
                        details.add('${signal.id}:${entries.length}'),
                onToggleCollapsed: () => collapseTaps++,
              ),
            ),
          ),
        ),
      ),
    );
    await pumpFluxerFramesQuick(tester);
  }

  testWidgets('labels unlit signals by name and lit ones with who is on', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      entries: <SignalEntry>[
        _entry('reading', '2'),
        _entry('reading', '3', persona: 'Kitsune'),
      ],
    );
    expect(find.bySemanticsLabel('Reading: user2, Kitsune'), findsOneWidget);
    expect(find.bySemanticsLabel('✅'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('signal-badge-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('signal-badge-3')),
      findsOneWidget,
    );
  });

  testWidgets('caps badges at three and shows the remainder', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      entries: <SignalEntry>[
        for (final String id in <String>['2', '3', '4', '5', '6'])
          _entry('reading', id),
      ],
    );
    expect(
      find.byKey(const ValueKey<String>('signal-badge-4')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('signal-badge-5')), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('tap toggles with whether the account already has it on', (
    WidgetTester tester,
  ) async {
    await pump(tester, entries: <SignalEntry>[_entry('reading', '1')]);
    await tester.tap(find.byKey(const ValueKey<String>('signal-reading')));
    await tester.tap(find.byKey(const ValueKey<String>('signal-done')));
    expect(toggles, <String>['reading:true', 'done:false']);
  });

  testWidgets('long press opens details and tap does nothing when read-only', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      entries: <SignalEntry>[_entry('reading', '2')],
      canToggle: false,
    );
    await tester.tap(find.byKey(const ValueKey<String>('signal-reading')));
    await tester.longPress(
      find.byKey(const ValueKey<String>('signal-reading')),
    );
    expect(toggles, isEmpty);
    expect(details, <String>['reading:1']);
  });

  testWidgets('collapsed hides the signals and keeps the caret', (
    WidgetTester tester,
  ) async {
    await pump(tester, collapsed: true);
    expect(find.byKey(const ValueKey<String>('signal-reading')), findsNothing);
    await tester.tap(find.byTooltip('Show signal bar'));
    expect(collapseTaps, 1);
  });

  testWidgets('twelve signals wrap onto more rows on a narrow phone', (
    WidgetTester tester,
  ) async {
    final List<SignalBarSignal> twelve = <SignalBarSignal>[
      for (int i = 0; i < 12; i++)
        SignalBarSignal(id: 's$i', emojiName: '✅', animated: false),
    ];
    await pump(tester, signals: twelve, width: 360);
    expect(tester.takeException(), isNull);
    final double firstTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('signal-s0')))
        .dy;
    final double lastTop = tester
        .getTopLeft(find.byKey(const ValueKey<String>('signal-s11')))
        .dy;
    expect(lastTop, greaterThan(firstTop));
  });
}
