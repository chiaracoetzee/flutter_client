import 'package:flutter/scheduler.dart';

/// Fork: makes sure a list hidden while it scrolls to its selected row is
/// shown again, even when the scroll step stops without finishing.
///
/// Upstream's guild channel list paints itself fully transparent until it has
/// scrolled the selected channel into view. If that step gives up early (no
/// scroll view attached yet, community switched mid-way, an exception in a
/// post-frame callback), nothing clears the flag and the list stays blank
/// until the user switches community. The watchdog counts the frames the list
/// spends hidden, asks for another attempt on each one, and after
/// [maxHiddenFrames] calls `onGiveUp` so the list can show itself unscrolled.
class ForkHiddenListWatchdog {
  ForkHiddenListWatchdog({this.maxHiddenFrames = 60});

  /// Upstream's reveal takes at most about 23 frames (one restore, one jump
  /// to the top and 20 steps), so 60 leaves room without leaving the list
  /// blank for more than about a second.
  final int maxHiddenFrames;

  int _hiddenFrames = 0;
  bool _scheduled = false;

  int get hiddenFrames => _hiddenFrames;

  /// Call on every build of the list. [isHidden] and [canRun] are checked
  /// again on each frame, so they must read live state.
  void watch({
    required bool Function() isHidden,
    required bool Function() canRun,
    required VoidCallback retry,
    required VoidCallback onGiveUp,
  }) {
    if (!isHidden()) {
      _hiddenFrames = 0;
      return;
    }
    if (_scheduled) {
      return;
    }
    _scheduleTick(
      isHidden: isHidden,
      canRun: canRun,
      retry: retry,
      onGiveUp: onGiveUp,
    );
  }

  void _scheduleTick({
    required bool Function() isHidden,
    required bool Function() canRun,
    required VoidCallback retry,
    required VoidCallback onGiveUp,
  }) {
    _scheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) {
        _scheduled = false;
        if (!canRun() || !isHidden()) {
          _hiddenFrames = 0;
          return;
        }
        _hiddenFrames++;
        if (_hiddenFrames >= maxHiddenFrames) {
          _hiddenFrames = 0;
          onGiveUp();
          return;
        }
        retry();
        _scheduleTick(
          isHidden: isHidden,
          canRun: canRun,
          retry: retry,
          onGiveUp: onGiveUp,
        );
      })
      ..scheduleFrame();
  }
}
