import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

EditableTextState? editableTextStateForFocus(FocusNode node) {
  final BuildContext? context = node.context;
  if (context == null) {
    return null;
  }
  return context.findAncestorStateOfType<EditableTextState>();
}

void showComposerKeyboard(FocusNode node) {
  if (!node.canRequestFocus) {
    return;
  }
  if (!node.hasFocus) {
    node.requestFocus();
    return;
  }
  final EditableTextState? editable = editableTextStateForFocus(node);
  if (editable != null) {
    editable.requestKeyboard();
    return;
  }
  node.requestFocus();
}

bool _canToggleReadOnlyReconnect() {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}

/// Reopens the platform text input for [node] while keeping focus when possible.
void restartComposerTextInput({
  required FocusNode node,
  required bool Function() refocusWhen,
  void Function({required bool readOnly})? toggleReadOnly,
  void Function()? onFinished,
}) {
  if (!node.canRequestFocus) {
    return;
  }
  if (!node.hasFocus) {
    node.requestFocus();
    _scheduleAfterRefocus(node, onFinished);
    return;
  }
  if (toggleReadOnly != null && _canToggleReadOnlyReconnect()) {
    toggleReadOnly(readOnly: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!node.canRequestFocus) {
        toggleReadOnly(readOnly: false);
        onFinished?.call();
        return;
      }
      toggleReadOnly(readOnly: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleAfterRefocus(node, onFinished);
      });
    });
    return;
  }
  _cycleComposerFocus(node, refocusWhen, onFinished: onFinished);
}

void _scheduleAfterRefocus(FocusNode node, void Function()? onFinished) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (node.hasFocus) {
      showComposerKeyboard(node);
    }
    onFinished?.call();
  });
}

void cycleComposerFocusForTextInput({
  required FocusNode node,
  required bool Function() refocusWhen,
  void Function()? onFinished,
}) {
  _cycleComposerFocus(node, refocusWhen, onFinished: onFinished);
}

void _cycleComposerFocus(
  FocusNode node,
  bool Function() refocusWhen, {
  void Function()? onFinished,
}) {
  node.unfocus();
  WidgetsBinding.instance
    ..scheduleFrame()
    ..addPostFrameCallback((_) {
      if (refocusWhen()) {
        node.requestFocus();
        _scheduleAfterRefocus(node, onFinished);
        return;
      }
      onFinished?.call();
    });
}
