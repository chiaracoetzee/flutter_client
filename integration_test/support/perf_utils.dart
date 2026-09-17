import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'scroll_utils.dart';

Future<void> traceScrollPerf(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester, {
  required String reportKey,
  required Finder scrollTarget,
  // A fling plus pause costs ~7.8k timeline events, the ring buffer holds
  // ~32k: more than three flings and the earlier ones are evicted.
  int flingCount = 3,
  Offset direction = const Offset(0, -1200),
  Duration pause = const Duration(milliseconds: 150),
}) async {
  final LiveTestWidgetsFlutterBindingFramePolicy previousPolicy =
      binding.framePolicy;
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final Stopwatch actionClock = Stopwatch();
  List<String> trail = const <String>[];
  try {
    await binding.traceAction(
      () async {
        actionClock.start();
        trail = await flingScrollable(
          tester,
          scrollTarget,
          count: flingCount,
          direction: direction,
          pause: pause,
        );
        await tester.pump(const Duration(milliseconds: 500));
        actionClock.stop();
      },
      // 'all' floods the ~32k event VM timeline ring buffer: the API stream
      // alone was 86% of it, evicting the scroll that was being measured.
      streams: const <String>['Dart', 'Embedder', 'GC'],
      reportKey: reportKey,
    );
  } finally {
    binding.framePolicy = previousPolicy;
    final Object? timeline = binding.reportData?[reportKey];
    final Object? extentMicros = timeline is Map<String, dynamic>
        ? timeline['timeExtentMicros']
        : null;
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['$reportKey.scroll'] = <String>[
      'action=${actionClock.elapsedMilliseconds}ms',
      'timeline=${extentMicros is num ? (extentMicros / 1000).round() : -1}ms',
      ...trail,
    ].join(' | ');
  }
}
