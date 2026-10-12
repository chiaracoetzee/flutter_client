import 'package:flutter_test/flutter_test.dart';

/// Waits for something that happens in the background, however long the
/// machine takes over it, and fails with [what] if it never does.
///
/// Use this instead of a fixed pause: a pause that is long enough on one
/// machine is too short on a slower one, and the test then fails for no
/// reason of its own.
Future<void> waitUntil(
  bool Function() done,
  String what, {
  Duration limit = const Duration(seconds: 10),
}) async {
  final Stopwatch waited = Stopwatch()..start();
  while (!done()) {
    if (waited.elapsed > limit) {
      fail('Timed out waiting for $what');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
