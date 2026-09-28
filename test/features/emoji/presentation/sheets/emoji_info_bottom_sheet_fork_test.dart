// Fork: tests the fork adds, kept out of upstream's emoji_info_bottom_sheet_test.dart so that file stays as
// upstream has it.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/emoji/domain/emoji_info_data.dart';
import 'package:fluxer_app/features/emoji/presentation/sheets/emoji_info_bottom_sheet.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_registry.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../helpers/test_l10n.dart';
import 'emoji_info_bottom_sheet_test.dart' hide main;

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._personas);
  final List<Persona> _personas;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_personas);

  @override
  Future<void> reloadSilently() async {}
}

Widget _buildTestApp({
  required Widget child,
  List<Override> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: extraOverrides,
    child: forkUpstream.buildTestApp(child: child),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EmojiRegistry.preload();
  });

  testWidgets(
    'shows "React as..." and opens PersonaReactAsSheet when messageId and personas present',
    (tester) async {
      const testPersona = Persona(id: 'p1', name: 'Bob the Fox');
      final entry = EmojiRegistry.allEmojis.first;
      final data = EmojiInfoData(name: entry.surrogates);

      await tester.pumpWidget(
        _buildTestApp(
          extraOverrides: [
            myPersonasProvider.overrideWith(
              () => _FakeMyPersonasNotifier(const [testPersona]),
            ),
          ],
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(
                    EmojiInfoBottomSheet.show(
                      context,
                      emoji: data,
                      messageId: 'msg-1',
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(testL10n.fork.chatReactAs), findsOneWidget);

      await tester.tap(find.text(testL10n.fork.chatReactAs));
      await tester.pumpAndSettle();

      expect(find.text('Bob the Fox'), findsWidgets);
    },
  );
}
