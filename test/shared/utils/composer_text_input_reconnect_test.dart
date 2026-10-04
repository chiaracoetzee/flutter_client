import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/composer_text_input_reconnect.dart';
import 'package:fluxer_app/shared/utils/keyboard_focus_restore.dart';

class _ReconnectFieldHarness extends StatefulWidget {
  const _ReconnectFieldHarness({
    required this.controller,
    required this.focusNode,
    required this.onReadOnlyChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<bool> onReadOnlyChanged;

  @override
  State<_ReconnectFieldHarness> createState() => _ReconnectFieldHarnessState();
}

class _ReconnectFieldHarnessState extends State<_ReconnectFieldHarness> {
  bool _readOnly = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: _readOnly,
    );
  }

  void setReconnectReadOnly(bool readOnly) {
    widget.onReadOnlyChanged(readOnly);
    setState(() => _readOnly = readOnly);
  }
}

void main() {
  testWidgets('restartComposerTextInput keeps focus on mobile', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    final GlobalKey<_ReconnectFieldHarnessState> harnessKey =
        GlobalKey<_ReconnectFieldHarnessState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _ReconnectFieldHarness(
            key: harnessKey,
            controller: controller,
            focusNode: focusNode,
            onReadOnlyChanged: (_) {},
          ),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    tester.testTextInput.log.clear();
    restartComposerTextInput(
      node: focusNode,
      refocusWhen: () => false,
      toggleReadOnly: ({required bool readOnly}) {
        harnessKey.currentState!.setReconnectReadOnly(readOnly);
      },
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);
    await tester.enterText(find.byType(TextField), 'abc');
    expect(controller.text, 'abc');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('resume restore accepts text after background', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    final GlobalKey<_ReconnectFieldHarnessState> harnessKey =
        GlobalKey<_ReconnectFieldHarnessState>();
    final KeyboardFocusRestoreHandle handle = KeyboardFocusRestoreHandle(
      focusNode: focusNode,
      shouldTrackOnBackground: () => true,
      canRestoreFocus: () => true,
      toggleComposerReadOnly: ({required bool readOnly}) {
        harnessKey.currentState?.setReconnectReadOnly(readOnly);
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _ReconnectFieldHarness(
            key: harnessKey,
            controller: controller,
            focusNode: focusNode,
            onReadOnlyChanged: (_) {},
          ),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    handle
      ..handleLifecycleState(AppLifecycleState.inactive)
      ..handleLifecycleState(AppLifecycleState.hidden)
      ..handleLifecycleState(AppLifecycleState.paused);
    handle
      ..handleLifecycleState(AppLifecycleState.hidden)
      ..handleLifecycleState(AppLifecycleState.inactive)
      ..handleLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump(kKeyboardFocusRestoreRetryDelay);

    expect(focusNode.hasFocus, isTrue);
    await tester.enterText(find.byType(TextField), 'hello');
    expect(controller.text, 'hello');
    debugDefaultTargetPlatformOverride = null;
  });
}
