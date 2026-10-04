import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fluxer_app/features/chat/utils/composer/bottom_input_slot_layout.dart';
import 'package:fluxer_app/shared/utils/composer_text_input_reconnect.dart';

const Duration kKeyboardFocusRestoreRetryDelay = Duration(milliseconds: 350);

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
    this.onBeginKeyboardLayoutHold,
    this.onEndKeyboardLayoutHold,
    this.toggleComposerReadOnly,
  });

  final FocusNode focusNode;
  final bool Function() shouldTrackOnBackground;
  final bool Function() canRestoreFocus;
  final VoidCallback? onBeginKeyboardLayoutHold;
  final VoidCallback? onEndKeyboardLayoutHold;
  final void Function({required bool readOnly})? toggleComposerReadOnly;

  bool _pendingRestore = false;
  int _restoreGeneration = 0;
  Timer? _deadImeRetry;

  bool get hasPendingRestore => _pendingRestore;

  void dispose() {
    _deadImeRetry?.cancel();
    _restoreGeneration++;
    onEndKeyboardLayoutHold?.call();
  }

  void reconnectOpenField() {
    _pendingRestore = false;
    if (!_canAttemptRestore() || _anotherEditableHasFocus()) {
      return;
    }
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
      return;
    }
    final int generation = ++_restoreGeneration;
    _reconnectFocused(generation);
  }

  void replaceFocusedConnection() {
    _pendingRestore = false;
    if (!focusNode.hasFocus || !_canAttemptRestore()) {
      return;
    }
    _deadImeRetry?.cancel();
    final int generation = ++_restoreGeneration;
    _restartTextInput(generation, scheduleDeadImeRetry: false);
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
      _reconnectFocused(generation);
      return;
    }
    focusNode.requestFocus();
    showComposerKeyboard(focusNode);
  }

  void _reconnectFocused(int generation) {
    _restartTextInput(generation, scheduleDeadImeRetry: true);
  }

  void _restartTextInput(int generation, {required bool scheduleDeadImeRetry}) {
    onBeginKeyboardLayoutHold?.call();
    restartComposerTextInput(
      node: focusNode,
      toggleReadOnly: toggleComposerReadOnly,
      refocusWhen: () => _canRefocusAfterCycle(generation),
      onFinished: () {
        if (generation != _restoreGeneration) {
          onEndKeyboardLayoutHold?.call();
          return;
        }
        onEndKeyboardLayoutHold?.call();
      },
    );
    if (scheduleDeadImeRetry) {
      _scheduleDeadImeRetry(generation);
    }
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
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
        showComposerKeyboard(focusNode);
        return;
      }
      if (_keyboardInsetBottom() > 0) {
        showComposerKeyboard(focusNode);
        return;
      }
      if (_anotherEditableHasFocus() || _fieldIsComposing()) {
        return;
      }
      _restartTextInput(generation, scheduleDeadImeRetry: false);
    });
  }

  bool _canRefocusAfterCycle(int generation) {
    if (generation != _restoreGeneration || !_canAttemptRestore()) {
      return false;
    }
    if (focusNode.context == null ||
        focusNode.hasFocus ||
        _anotherEditableHasFocus()) {
      return false;
    }
    return focusNode.canRequestFocus;
  }

  double _keyboardInsetBottom() {
    final BuildContext? context = focusNode.context;
    if (context == null) {
      return 0;
    }
    final double mediaQueryInset = MediaQuery.viewInsetsOf(context).bottom;
    final view = View.of(context);
    return resolvedKeyboardInsetBottomFrom(
      mediaQueryInsetBottom: mediaQueryInset,
      physicalViewInsetBottom: view.viewInsets.bottom,
      devicePixelRatio: view.devicePixelRatio,
    );
  }

  bool _fieldIsComposing() {
    final EditableTextState? editable = editableTextStateForFocus(focusNode);
    if (editable == null) {
      return false;
    }
    final TextRange composing = editable.widget.controller.value.composing;
    return composing.isValid && !composing.isCollapsed;
  }
}

void reconnectComposerKeyboard(FocusNode node) {
  restartComposerTextInput(
    node: node,
    refocusWhen: () =>
        node.canRequestFocus && node.context != null && !node.hasFocus,
  );
}

bool _isEditableFocus(FocusNode node) {
  final BuildContext? context = node.context;
  if (context == null) {
    return false;
  }
  return context.widget is EditableText ||
      context.findAncestorWidgetOfExactType<EditableText>() != null;
}
