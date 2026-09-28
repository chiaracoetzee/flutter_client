// Fork: tests the fork adds, kept out of upstream's emoji_info_bottom_sheet_test.dart so that file stays as
// upstream has it.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/router/route_state_providers.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/providers/pickers/expression_picker_preferences_provider.dart';
import 'package:fluxer_app/features/emoji/domain/emoji_info_data.dart';
import 'package:fluxer_app/features/emoji/presentation/sheets/emoji_info_bottom_sheet.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/guilds/providers/guild_list_view_model.dart';
import 'package:fluxer_app/features/guilds/providers/guild_providers.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_registry.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../helpers/test_l10n.dart';

class _FakeFavoriteEmojiKeys extends FavoriteEmojiKeys {
  @override
  Future<List<String>> build() => Future.value(const <String>[]);
}

class _FakeGuildListViewModel extends GuildListViewModel {
  @override
  GuildListViewState build() => const GuildListViewState(
    guilds: [Guild(id: 'guild-1', name: 'Test Community', ownerId: 'owner')],
  );
}

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
  String? currentGuildId = 'guild-1',
  List<Override> extraOverrides = const [],
}) {
  final colorTheme = buildDarkColorTheme();

  return ProviderScope(
    overrides: [
      favoriteEmojiKeysProvider.overrideWith(_FakeFavoriteEmojiKeys.new),
      guildListViewModelProvider.overrideWith(_FakeGuildListViewModel.new),
      contextualGuildIdProvider.overrideWithValue(currentGuildId),
      guildByIdProvider('guild-1').overrideWith(
        (ref) => const Guild(
          id: 'guild-1',
          name: 'Test Community',
          ownerId: 'owner',
        ),
      ),
      guildByIdProvider('guild-3').overrideWith((ref) => null),
      ...extraOverrides,
    ],
    child: MaterialApp(
      locale: kTestLocale,
      localizationsDelegates: fluxerLocalizationsDelegates,
      supportedLocales: FluxerLocalizations.supportedLocales,
      theme: buildFluxerTheme(
        colorTheme: colorTheme,
        textTheme: FluxerTextTheme.fromColors(colorTheme),
        layoutTheme: FluxerLayoutTheme.scaled(),
      ),
      home: Scaffold(body: child),
    ),
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
