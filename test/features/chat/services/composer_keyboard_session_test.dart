import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/services/composer_keyboard_session.dart';
import 'package:fluxer_app/shared/utils/keyboard_focus_restore.dart';

void main() {
  testWidgets('cancelReadOnlyReconnect clears reconnect readOnly flag', (
    tester,
  ) async {
    final FocusNode focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    late ComposerKeyboardSession session;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? _) {
                session = ComposerKeyboardSession(
                  ref: ref,
                  focusNode: focusNode,
                  isMounted: () => true,
                  isMobileLayout: () => true,
                  isSlashSessionActive: () => false,
                  composerEntryFocused: () => focusNode.hasFocus,
                  requestRebuild: () {},
                );
                return TextField(focusNode: focusNode);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    session.reconnectOpenField();
    await tester.pump();
    expect(session.reconnectReadOnly, isTrue);
    expect(session.keyboardState, ComposerKeyboardState.imeReconnecting);

    session.cancelReadOnlyReconnect();
    expect(session.reconnectReadOnly, isFalse);
    expect(isActiveReadOnlyReconnect(), isFalse);
    session.dispose();
  });
}
