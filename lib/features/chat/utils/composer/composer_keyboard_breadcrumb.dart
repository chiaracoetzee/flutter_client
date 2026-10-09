import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kComposerKeyboardStateKey = 'composer_keyboard_state';
const String kComposerKeyboardReadOnlyKey = 'composer_keyboard_read_only';
const String kComposerKeyboardAtKey = 'composer_keyboard_at_ms';

Future<void> persistComposerKeyboardBreadcrumb({
  required String keyboardState,
  required bool reconnectReadOnly,
}) async {
  if (!kDebugMode) {
    return;
  }
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kComposerKeyboardStateKey, keyboardState);
    await prefs.setBool(kComposerKeyboardReadOnlyKey, reconnectReadOnly);
    await prefs.setInt(
      kComposerKeyboardAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  } on Object {
    // Throw error
  }
}

Future<Map<String, String>?> readComposerKeyboardBreadcrumb() async {
  if (!kDebugMode) {
    return null;
  }
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? keyboardState = prefs.getString(kComposerKeyboardStateKey);
    if (keyboardState == null || keyboardState.isEmpty) {
      return null;
    }
    final bool? readOnly = prefs.getBool(kComposerKeyboardReadOnlyKey);
    final int? atMs = prefs.getInt(kComposerKeyboardAtKey);
    return <String, String>{
      'composer.keyboard.state': keyboardState,
      if (readOnly != null) 'composer.keyboard.read_only': '$readOnly',
      if (atMs != null) 'composer.keyboard.at_ms': '$atMs',
    };
  } on Object {
    return null;
  }
}

Future<void> clearComposerKeyboardBreadcrumb() async {
  if (!kDebugMode) {
    return;
  }
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kComposerKeyboardStateKey);
    await prefs.remove(kComposerKeyboardReadOnlyKey);
    await prefs.remove(kComposerKeyboardAtKey);
  } on Object {
    // Throw error
  }
}
