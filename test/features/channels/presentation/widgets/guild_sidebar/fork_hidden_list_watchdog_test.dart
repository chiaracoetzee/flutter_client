import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/channels/presentation/widgets/guild_sidebar/fork_hidden_list_watchdog.dart';

class _Probe {
  bool hidden = true;
  bool canRun = true;
  int retries = 0;
  int giveUps = 0;
}

class _HiddenList extends StatefulWidget {
  const _HiddenList({required this.probe, required this.watchdog, super.key});

  final _Probe probe;
  final ForkHiddenListWatchdog watchdog;

  @override
  State<_HiddenList> createState() => _HiddenListState();
}

class _HiddenListState extends State<_HiddenList> {
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final _Probe probe = widget.probe;
    widget.watchdog.watch(
      isHidden: () => probe.hidden,
      canRun: () => mounted && probe.canRun,
      retry: () => probe.retries++,
      onGiveUp: () => setState(() {
        probe.giveUps++;
        probe.hidden = false;
      }),
    );
    return const SizedBox.shrink();
  }
}

Future<void> _pumpFrames(WidgetTester tester, int frames) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump();
  }
}

void main() {
  testWidgets('shows a list that stays hidden after maxHiddenFrames frames', (
    WidgetTester tester,
  ) async {
    final _Probe probe = _Probe();
    final ForkHiddenListWatchdog watchdog = ForkHiddenListWatchdog(
      maxHiddenFrames: 5,
    );
    // The frame pumpWidget draws is the first hidden one.
    await tester.pumpWidget(_HiddenList(probe: probe, watchdog: watchdog));

    await _pumpFrames(tester, 3);
    expect(probe.giveUps, 0);
    expect(probe.retries, 4);
    expect(probe.hidden, isTrue);

    await tester.pump();
    expect(probe.giveUps, 1);
    expect(probe.hidden, isFalse);

    await _pumpFrames(tester, 10);
    expect(probe.giveUps, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('keeps going on its own without other frames being requested', (
    WidgetTester tester,
  ) async {
    final _Probe probe = _Probe();
    final ForkHiddenListWatchdog watchdog = ForkHiddenListWatchdog(
      maxHiddenFrames: 3,
    );
    await tester.pumpWidget(_HiddenList(probe: probe, watchdog: watchdog));

    for (int i = 0; i < 2; i++) {
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pump();
    }
    expect(probe.giveUps, 1);
  });

  testWidgets('does nothing when the reveal finishes in time', (
    WidgetTester tester,
  ) async {
    final _Probe probe = _Probe();
    final ForkHiddenListWatchdog watchdog = ForkHiddenListWatchdog(
      maxHiddenFrames: 5,
    );
    await tester.pumpWidget(_HiddenList(probe: probe, watchdog: watchdog));

    await _pumpFrames(tester, 3);
    probe.hidden = false;
    await _pumpFrames(tester, 10);

    expect(probe.giveUps, 0);
    expect(watchdog.hiddenFrames, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('starts counting again when the list is hidden a second time', (
    WidgetTester tester,
  ) async {
    final _Probe probe = _Probe();
    final ForkHiddenListWatchdog watchdog = ForkHiddenListWatchdog(
      maxHiddenFrames: 5,
    );
    final GlobalKey<_HiddenListState> key = GlobalKey<_HiddenListState>();
    await tester.pumpWidget(
      _HiddenList(key: key, probe: probe, watchdog: watchdog),
    );

    await _pumpFrames(tester, 3);
    probe.hidden = false;
    await tester.pump();

    probe.hidden = true;
    key.currentState!.rebuild();
    await _pumpFrames(tester, 4);
    expect(probe.giveUps, 0);

    await tester.pump();
    expect(probe.giveUps, 1);
  });

  testWidgets('stops without showing the list when it may no longer run', (
    WidgetTester tester,
  ) async {
    final _Probe probe = _Probe();
    final ForkHiddenListWatchdog watchdog = ForkHiddenListWatchdog(
      maxHiddenFrames: 5,
    );
    await tester.pumpWidget(_HiddenList(probe: probe, watchdog: watchdog));

    await _pumpFrames(tester, 2);
    probe.canRun = false;
    await _pumpFrames(tester, 10);

    expect(probe.giveUps, 0);
    expect(probe.hidden, isTrue);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
