// Fork: tests the fork adds, kept out of upstream's fluxer_color_picker_field_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/ui/color_picker/fluxer_color_picker_field.dart';
import 'package:fluxer_app/material_ui.dart';

import 'fluxer_color_picker_field_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FluxerColorPickerField input', () {
    testWidgets('default value renders defaultValue hex and swatch', (
      tester,
    ) async {
      await tester.pumpWidget(
        forkUpstream.wrap(
          FluxerColorPickerField(
            value: 0xE5A53B,
            defaultValue: 0xE5A53B,
            isDefaultValue: true,
            onChanged: (_) {},
            label: 'Accent Color',
          ),
        ),
      );

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller.text, '#E5A53B');

      final swatch = tester.widget<ColoredBox>(
        find.descendant(
          of: find.bySemanticsLabel('Open color picker'),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(swatch.color, const Color(0xFFE5A53B));
    });

    testWidgets(
      'dynamic defaultValue update updates text field when not focused',
      (tester) async {
        await tester.pumpWidget(
          forkUpstream.wrap(
            FluxerColorPickerField(
              value: 0x112233,
              defaultValue: 0x112233,
              isDefaultValue: true,
              onChanged: (_) {},
              label: 'Accent Color',
            ),
          ),
        );

        var editable = tester.widget<EditableText>(find.byType(EditableText));
        expect(editable.controller.text, '#112233');

        // Now update widget with new default color (e.g. user updated avatar)
        await tester.pumpWidget(
          forkUpstream.wrap(
            FluxerColorPickerField(
              value: 0x445566,
              defaultValue: 0x445566,
              isDefaultValue: true,
              onChanged: (_) {},
              label: 'Accent Color',
            ),
          ),
        );

        editable = tester.widget<EditableText>(find.byType(EditableText));
        expect(editable.controller.text, '#445566');
      },
    );

    testWidgets(
      'entering Fluxer Blue while in default mode triggers onChanged with 0x4641D9',
      (tester) async {
        final values = <int>[];
        await tester.pumpWidget(
          forkUpstream.wrap(
            FluxerColorPickerField(
              value: 0x64392B,
              defaultValue: 0x64392B,
              isDefaultValue: true,
              onChanged: values.add,
              label: 'Accent Color',
            ),
          ),
        );

        // Typing Fluxer Blue (#4641D9) triggers onChanged and sets explicit color
        await tester.enterText(find.byType(EditableText), '#4641D9');
        await tester.pump();

        expect(values, contains(0x4641D9));
      },
    );

    testWidgets(
      'submitting text field while in default mode commits explicit value',
      (tester) async {
        final values = <int>[];
        await tester.pumpWidget(
          forkUpstream.wrap(
            FluxerColorPickerField(
              value: 0x4641D9,
              defaultValue: 0x4641D9,
              isDefaultValue: true,
              onChanged: values.add,
              label: 'Accent Color',
            ),
          ),
        );

        await tester.tap(find.byType(EditableText));
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(values, contains(0x4641D9));
      },
    );
  });
}
