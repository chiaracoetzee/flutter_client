import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/settings/providers/quick_switcher_button_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to true when no value saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(quickSwitcherButtonPreferencesProvider), isTrue);
  });

  test('loads saved preference from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      'show_quick_switcher_button': false,
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(quickSwitcherButtonPreferencesProvider.notifier)
        .load();

    expect(container.read(quickSwitcherButtonPreferencesProvider), isFalse);
  });

  test('setEnabled updates state and writes to SharedPreferences', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(quickSwitcherButtonPreferencesProvider), isTrue);

    await container
        .read(quickSwitcherButtonPreferencesProvider.notifier)
        .setEnabled(value: false);

    expect(container.read(quickSwitcherButtonPreferencesProvider), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('show_quick_switcher_button'), isFalse);

    await container
        .read(quickSwitcherButtonPreferencesProvider.notifier)
        .setEnabled(value: true);

    expect(container.read(quickSwitcherButtonPreferencesProvider), isTrue);
    expect(prefs.getBool('show_quick_switcher_button'), isTrue);
  });
}
