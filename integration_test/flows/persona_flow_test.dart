import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/navigation_helpers.dart';
import '../support/session_helpers.dart';
import '../support/test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('persona flow: navigate to channel, verify composer and persona switcher', (
    WidgetTester tester,
  ) async {
    if (kIsWeb) {
      return;
    }

    // 1. Authenticate with test lab credentials
    await bootstrapAuthenticatedApp(tester);

    // 2. Open guild channel if configured, otherwise open personal notes
    if (IntegrationTestConfig.hasGuildChannel) {
      await openGuildChannel(tester);
    } else {
      await openPersonalNotes(tester);
    }

    // 3. Ensure messages list and composer are rendered
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(EditableText), findsAtLeast(1));

    // 4. Verify composer persona pill / selector exists if personas are configured
    final Finder personaPill = find.byKey(const ValueKey<String>('persona-composer-pill'));
    if (personaPill.evaluate().isNotEmpty) {
      await tester.tap(personaPill);
      await tester.pumpAndSettle();

      // Verify bottom sheet modal opened
      expect(find.byType(BottomSheet), findsOneWidget);

      // Dismiss sheet by tapping outside or barrier
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('persona flow: navigate to settings and verify persona management tab', (
    WidgetTester tester,
  ) async {
    if (kIsWeb) {
      return;
    }

    await bootstrapAuthenticatedApp(tester);

    // Navigate to user settings via profile/more tab
    final Finder youTab = find.bySemanticsLabel('You');
    final Finder settingsTab = find.bySemanticsLabel('Settings');

    if (youTab.evaluate().isNotEmpty) {
      await tester.tap(youTab);
      await tester.pumpAndSettle();
    } else if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
    }

    // Look for Personas or Subprofiles navigation tile
    final Finder personasTile = find.text('Personas');
    if (personasTile.evaluate().isNotEmpty) {
      await tester.tap(personasTile);
      await tester.pumpAndSettle();

      // Verify we arrived at personas settings screen
      expect(find.text('Personas'), findsWidgets);
    }
  });
}
