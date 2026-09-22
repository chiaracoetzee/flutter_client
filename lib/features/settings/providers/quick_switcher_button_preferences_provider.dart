import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kShowQuickSwitcherButtonKey = 'show_quick_switcher_button';

class QuickSwitcherButtonPreferences extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_init());
    return true;
  }

  Future<void> _init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool? value = preferences.getBool(_kShowQuickSwitcherButtonKey);
    if (value != null && state != value) {
      state = value;
    }
  }

  Future<void> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool value =
        preferences.getBool(_kShowQuickSwitcherButtonKey) ?? true;
    state = value;
  }

  Future<void> setEnabled({required bool value}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_kShowQuickSwitcherButtonKey, value);
    state = value;
  }
}

final quickSwitcherButtonPreferencesProvider =
    NotifierProvider<QuickSwitcherButtonPreferences, bool>(
      QuickSwitcherButtonPreferences.new,
    );
