// Fork: tests the fork adds, kept out of upstream's composer_mention_controller_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/services/composer_mention_controller.dart';
import 'package:fluxer_app/material_ui.dart';

import 'composer_mention_controller_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'stores persona mention display label and renders wire text with personaId',
    (WidgetTester tester) async {
      final ComposerMentionController controller = await forkUpstream
          .pumpController(tester);

      controller.insertUserMentionPlaceholder(
        matchStart: 0,
        matchEnd: 0,
        userId: '1481621807877361924',
        personaId: '1550229100331794432',
        displayName: 'Bob the Fox',
      );
      await tester.pump();

      expect(find.text('@Bob the Fox'), findsOneWidget);
      expect(
        controller.toWireText().trim(),
        '<@1481621807877361924:1550229100331794432>',
      );
    },
  );

  testWidgets(
    'insertUserMentionPlaceholder with personaId replaces full autocomplete range',
    (WidgetTester tester) async {
      final ComposerMentionController controller = await forkUpstream
          .pumpController(tester);

      controller
        ..text = '@bob'
        ..selection = const TextSelection.collapsed(offset: 4)
        ..insertUserMentionPlaceholder(
          matchStart: 0,
          matchEnd: 4,
          userId: '1481621807877361924',
          personaId: '1550229100331794432',
          displayName: 'Bob the Fox',
        );
      await tester.pump();

      expect(find.text('@Bob the Fox'), findsOneWidget);
      expect(
        controller.toWireText().trim(),
        '<@1481621807877361924:1550229100331794432>',
      );
    },
  );
}
