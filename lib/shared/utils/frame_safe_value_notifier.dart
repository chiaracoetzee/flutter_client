import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// A [ValueNotifier] whose writes made during build/layout/paint are applied
/// after the frame instead of notifying listeners mid-frame.
///
/// Listeners such as `ListenableBuilder` call `setState`. Doing that while the
/// render tree is mid-layout (for example from a scroll notification that a
/// viewport dispatches in `applyContentDimensions`) dirties widgets in the
/// middle of layout, which can lose the rebuild inside a `LayoutBuilder` (see
/// `RebuildSafeLayoutBuilder`). Such a rebuild could only land on the next
/// frame anyway, so deferring the write to the end of this frame changes no
/// visible timing.
///
/// Writes outside [SchedulerPhase.persistentCallbacks] (pointer handlers,
/// tickers, microtasks, timers) apply synchronously and supersede any pending
/// deferred write, so ordering between the two is preserved.
class FrameSafeValueNotifier<T> extends ValueNotifier<T> {
  // ValueNotifier's own parameter is the private `_value`, which cannot be
  // matched by name.
  // ignore: matching_super_parameters
  FrameSafeValueNotifier(super.value);

  bool _hasPending = false;
  T? _pending;
  bool _flushScheduled = false;
  bool _disposed = false;

  /// Whether a write made mid-frame is waiting for the end of the frame.
  @visibleForTesting
  bool get hasPendingWrite => _hasPending;

  @override
  set value(T newValue) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _pending = newValue;
      _hasPending = true;
      _scheduleFlush();
      return;
    }
    _hasPending = false;
    _pending = null;
    super.value = newValue;
  }

  void _scheduleFlush() {
    if (_flushScheduled) {
      return;
    }
    _flushScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      if (_disposed || !_hasPending) {
        return;
      }
      final T next = _pending as T;
      _hasPending = false;
      _pending = null;
      super.value = next;
    }, debugLabel: 'FrameSafeValueNotifier.flush');
  }

  @override
  void dispose() {
    _disposed = true;
    _hasPending = false;
    _pending = null;
    super.dispose();
  }
}
