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

  testWidgets('long press opens details; tap is inert when read-only', (
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

  Future<void> pumpSheet(
    WidgetTester tester, {
    required bool canManage,
    required List<String> actions,
  }) async {
    await tester.pumpWidget(
      pumpFluxerApp(
        child: Scaffold(
          body: SignalDetailsSheet(
            signal: _reading,
            entries: <SignalEntry>[
              _entry('reading', '1'),
              _entry('reading', '2'),
            ],
            onTurnOff: canManage
                ? (SignalEntry entry) => actions.add('off:${entry.userId}')
                : null,
            onReset: canManage ? () => actions.add('reset') : null,
          ),
        ),
      ),
    );
  }

  testWidgets('details sheet only lists names for people who cannot manage', (
    WidgetTester tester,
  ) async {
    final List<String> actions = <String>[];
    await pumpSheet(tester, canManage: false, actions: actions);
    final String name = _entry('reading', '2').displayName;
    expect(find.text(name), findsOneWidget);
    expect(find.text('Turn off $name'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('signal-details-reset')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey<String>('signal-details-2')));
    expect(actions, isEmpty);
  });

  testWidgets('details sheet lets managers turn one off or reset', (
    WidgetTester tester,
  ) async {
    final List<String> actions = <String>[];
    await pumpSheet(tester, canManage: true, actions: actions);
    final String name = _entry('reading', '2').displayName;
    expect(find.text('Turn off $name'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('signal-details-2')));
    await tester.tap(
      find.byKey(const ValueKey<String>('signal-details-reset')),
    );
    expect(actions, <String>['off:2', 'reset']);
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

  group('signalBarSignalSize', () {
    test('keeps the default size while one row holds them all', () {
      for (int count = 1; count <= 7; count++) {
        expect(signalBarSignalSize(count: count, width: 355), 40);
      }
    });

    test('keeps the default size when every row is at least half full', () {
      // 7 and 5; 7, 7 and 7.
      expect(signalBarSignalSize(count: 12, width: 355), 40);
      expect(signalBarSignalSize(count: 21, width: 355), 40);
    });

    test('shrinks when that saves a row', () {
      // 40 gives 7, 7 and 4; 30 gives 9 and 9.
      expect(signalBarSignalSize(count: 18, width: 355), 30);
    });

    test('shrinks so fifteen signals make two rows instead of 7, 7, 1', () {
      expect(signalBarSignalSize(count: 15, width: 355), 35);
    });

    test('shrinks to fit one row rather than leave one signal alone', () {
      expect(signalBarSignalSize(count: 8, width: 355), 35);
    });

    test('grows when shrinking cannot fill the last row', () {
      // 40 gives 7 and 3; 30 gives 9 and 1; 43 gives 6 and 4.
      expect(signalBarSignalSize(count: 10, width: 355), 43);
    });

    test('stays in range and falls back to the default without a width', () {
      for (int count = 1; count <= 60; count++) {
        for (double width = 120; width <= 900; width += 37) {
          final double size = signalBarSignalSize(count: count, width: width);
          expect(size, inInclusiveRange(30, 48));
        }
      }
      expect(signalBarSignalSize(count: 5, width: double.infinity), 40);
      expect(signalBarSignalSize(count: 0, width: 355), 40);
    });
  });

  testWidgets('fifteen signals on a phone leave no row less than half full', (
    WidgetTester tester,
  ) async {
    final List<SignalBarSignal> fifteen = <SignalBarSignal>[
      for (int i = 0; i < 15; i++)
        SignalBarSignal(id: 's$i', emojiName: '✅', animated: false),
    ];
    await pump(tester, signals: fifteen, width: 411);
    expect(tester.takeException(), isNull);
    final Map<double, int> perRow = <double, int>{};
    for (int i = 0; i < 15; i++) {
      final Rect rect = tester.getRect(
        find.byKey(ValueKey<String>('signal-s$i')),
      );
      expect(rect.width, lessThan(40));
      perRow.update(rect.top, (int n) => n + 1, ifAbsent: () => 1);
    }
    expect(perRow.length, 2);
    final List<int> counts = perRow.values.toList();
    expect(counts.last * 2, greaterThanOrEqualTo(counts.first));
  });
}
