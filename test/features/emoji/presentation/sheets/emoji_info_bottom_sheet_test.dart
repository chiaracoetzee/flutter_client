// Root ProviderScope built by a helper; the lint only exempts a
// ProviderScope written inline in pumpWidget.
// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

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

  testWidgets('shows default emoji info content', (tester) async {
    final entry = EmojiRegistry.allEmojis.first;

    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  EmojiInfoBottomSheet.show(
                    context,
                    emoji: EmojiInfoData(name: entry.surrogates),
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

    expect(find.text(':${entry.primaryName}:'), findsOneWidget);
    expect(
      find.text(testL10n.emojiInfoDefaultDescription('Fluxer')),
      findsOneWidget,
    );
  });

  testWidgets('shows guild section for custom emoji', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  EmojiInfoBottomSheet.show(
                    context,
                    emoji: const EmojiInfoData(
                      id: 'emoji-1',
                      name: 'party',
                      guildId: 'guild-1',
                    ),
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

    expect(find.text(':party:'), findsOneWidget);
    expect(find.text(testL10n.emojiInfoCustomGuildDescription), findsOneWidget);
    expect(
      find.text(testL10n.emojiInfoFromHeader.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('Test Community'), findsOneWidget);
    expect(find.text(testL10n.emojiInfoPrivateCommunity), findsOneWidget);
    expect(
      find.bySemanticsLabel(testL10n.emojiInfoAddToFavorites),
      findsOneWidget,
    );
  });

  testWidgets('shows source community instead of this community', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        currentGuildId: 'guild-2',
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  EmojiInfoBottomSheet.show(
                    context,
                    emoji: const EmojiInfoData(
                      id: 'emoji-1',
                      name: 'party',
                      guildId: 'guild-1',
                    ),
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

    expect(find.text(testL10n.emojiInfoCustomGuildDescription), findsOneWidget);
    expect(
      find.text(testL10n.emojiInfoCustomInviteRequiredDescription),
      findsNothing,
    );
    expect(
      find.text(testL10n.emojiInfoFromHeader.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('Test Community'), findsOneWidget);
  });

  testWidgets('asks for an invite when the source community is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  EmojiInfoBottomSheet.show(
                    context,
                    emoji: const EmojiInfoData(
                      id: 'emoji-2',
                      name: 'secret',
                      guildId: 'guild-3',
                    ),
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

    expect(
      find.text(testL10n.emojiInfoCustomInviteRequiredDescription),
      findsOneWidget,
    );
    expect(find.text(testL10n.emojiInfoCustomGuildDescription), findsNothing);
    expect(find.text(testL10n.emojiInfoFromHeader.toUpperCase()), findsNothing);
    expect(find.text('Test Community'), findsNothing);
  });

  testWidgets('shows favorite toggle for unicode emoji', (tester) async {
    final entry = EmojiRegistry.allEmojis.first;
    final data = EmojiInfoData(name: entry.surrogates);

    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                unawaited(EmojiInfoBottomSheet.show(context, emoji: data));
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(testL10n.emojiInfoAddToFavorites),
      findsOneWidget,
    );
    expect(data.favoriteKeyForGuild(null), isNotNull);
  });

  testWidgets('shows "React as..." and opens PersonaReactAsSheet when messageId and personas present', (tester) async {
    const testPersona = Persona(id: 'p1', name: 'Bob the Fox');
    final entry = EmojiRegistry.allEmojis.first;
    final data = EmojiInfoData(name: entry.surrogates);

    await tester.pumpWidget(
      _buildTestApp(
        extraOverrides: [
          myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(const [testPersona])),
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
  });
}
