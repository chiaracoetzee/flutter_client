import 'dart:async';

import 'package:flutter/widgets.dart';

const Duration kKeyboardFocusRestoreRetryDelay = Duration(milliseconds: 100);

/// paused or hidden. inactive is system UI over the app, like paste.
bool isAppBackgroundLifecycleState(AppLifecycleState state) {
  return state == AppLifecycleState.paused || state == AppLifecycleState.hidden;
}

bool _canSafelyRequestFocus([AppLifecycleState? state]) {
  final AppLifecycleState? current =
      state ?? WidgetsBinding.instance.lifecycleState;
  return current == null || current == AppLifecycleState.resumed;
}

/// Re-requests [focusNode] on resume when the keyboard was open before backgrounding.
class KeyboardFocusRestoreHandle {
  KeyboardFocusRestoreHandle({
    required this.focusNode,
    required this.shouldTrackOnBackground,
    required this.canRestoreFocus,
  });

  final FocusNode focusNode;
  final bool Function() shouldTrackOnBackground;
  final bool Function() canRestoreFocus;

  bool _pendingRestore = false;
  int _restoreGeneration = 0;
  Timer? _deadImeRetry;

  bool get hasPendingRestore => _pendingRestore;

  void dispose() {
    _deadImeRetry?.cancel();
    _restoreGeneration++;
  }

  void handleLifecycleState(AppLifecycleState state) {
    if (isAppBackgroundLifecycleState(state)) {
      if (shouldTrackOnBackground()) {
        _pendingRestore = true;
      }
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _restoreGeneration++;
      _deadImeRetry?.cancel();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      scheduleRestoreIfPending();
    }
  }

  void scheduleRestoreIfPending() {
    if (!_pendingRestore || !canRestoreFocus()) {
      return;
    }
    final int generation = ++_restoreGeneration;
    WidgetsBinding.instance
      ..scheduleFrame()
      ..addPostFrameCallback((_) {
        if (generation != _restoreGeneration) {
          return;
        }
        _pendingRestore = false;
        _restoreFocus(generation);
      });
  }

  void _restoreFocus(int generation) {
    if (!_canAttemptRestore()) {
      return;
    }
    if (_anotherEditableHasFocus()) {
      return;
    }
    if (focusNode.hasFocus) {
      reconnectComposerKeyboard(focusNode);
      _scheduleDeadImeRetry(generation);
      return;
    }
    focusNode.requestFocus();
  }

  bool _canAttemptRestore() {
    if (!canRestoreFocus() || !focusNode.canRequestFocus) {
      return false;
    }
    return _canSafelyRequestFocus();
  }

  bool _anotherEditableHasFocus() {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    return primary != null &&
        primary.hasFocus &&
        primary != focusNode &&
        _isEditableFocus(primary);
  }

  void _scheduleDeadImeRetry(int generation) {
    _deadImeRetry?.cancel();
    _deadImeRetry = Timer(kKeyboardFocusRestoreRetryDelay, () {
      if (generation != _restoreGeneration || !_canAttemptRestore()) {
        return;
      }
      if (!focusNode.hasFocus || _keyboardInsetBottom() > 0) {
        return;
      }
      if (_anotherEditableHasFocus()) {
        return;
      }
      focusNode.unfocus();
      WidgetsBinding.instance
        ..scheduleFrame()
        ..addPostFrameCallback((_) {
          if (generation != _restoreGeneration || !_canAttemptRestore()) {
            return;
          }
          if (focusNode.hasFocus || _anotherEditableHasFocus()) {
            return;
          }
          focusNode.requestFocus();
        });
    });
  }

  double _keyboardInsetBottom() {
    final BuildContext? context = focusNode.context;
    if (context == null) {
      return 0;
    }
    return MediaQuery.viewInsetsOf(context).bottom;
  }
}

void reconnectComposerKeyboard(FocusNode node) {
  final EditableTextState? editable = _editableTextState(node);
  if (editable != null) {
    editable.requestKeyboard();
    return;
  }
  if (node.canRequestFocus) {
    node.requestFocus();
  }
}

bool _isEditableFocus(FocusNode node) {
  final BuildContext? context = node.context;
  if (context == null) {
    return false;
  }
  return context.widget is EditableText ||
      context.findAncestorWidgetOfExactType<EditableText>() != null;
}

EditableTextState? _editableTextState(FocusNode node) {
  final BuildContext? context = node.context;
  if (context == null) {
    return null;
  }
  return context.findAncestorStateOfType<EditableTextState>();
}
