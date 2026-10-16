// SPDX-License-Identifier: AGPL-3.0-or-later

// Upstream's search fields must ask Android for a normal text keyboard. A
// field without suggestions is declared a visible password field there, and
// Gboard shows its password layout (a number row, no swipe typing).

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/channel_search_token.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/search/channel_search_field.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/pickers/picker_search_input.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../helpers/pump_fluxer_app.dart';

/// What the focused field asked the platform's keyboard for.
Future<Map<String, dynamic>> _keyboardRequest(
  WidgetTester tester,
  Widget field,
) async {
  await tester.pumpWidget(pumpFluxerApp(child: Scaffold(body: field)));
  await tester.tap(find.byType(EditableText));
  await tester.pump();
  final Map<String, dynamic>? args = tester.testTextInput.setClientArgs;
  expect(args, isNotNull);
  return args!;
}

void _expectSearchKeyboard(Map<String, dynamic> request) {
  final bool android = defaultTargetPlatform == TargetPlatform.android;
  // Nothing typed into a search field is replaced, on any platform.
  expect(request['autocorrect'], isFalse);
  expect(request['enableSuggestions'], android);
}

void main() {
  final TargetPlatformVariant platforms = TargetPlatformVariant(
    <TargetPlatform>{TargetPlatform.android, TargetPlatform.iOS},
  );

  testWidgets('the shared picker search field', (tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    _expectSearchKeyboard(
      await _keyboardRequest(
        tester,
        PickerSearchInput(controller: controller, hintText: 'Search'),
      ),
    );
  }, variant: platforms);

  testWidgets('the message search field', (tester) async {
    final TextEditingController controller = TextEditingController();
    final FocusNode focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    _expectSearchKeyboard(
      await _keyboardRequest(
        tester,
        ChannelSearchField(
          controller: controller,
          focusNode: focusNode,
          tokens: const <ChannelSearchToken>[],
          guildId: null,
          hintText: 'Search',
          isSearching: false,
          onSubmitted: (_) {},
          onRemoveToken: (_) {},
          onClear: () {},
        ),
      ),
    );
  }, variant: platforms);
}
