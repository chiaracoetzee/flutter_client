import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/message_actions/double_tap_reaction_hint.dart';
import 'package:fluxer_app/features/chat/providers/pickers/emoji_picker_provider.dart';
import 'package:fluxer_app/features/settings/providers/double_tap_reaction_preferences_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';

import '../../../../../helpers/test_l10n.dart';

void main() {
  testWidgets('shows double tap hint and edit control', (tester) async {
    final colorTheme = buildDarkColorTheme();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: kTestLocale,
          localizationsDelegates: FluxerLocalizations.localizationsDelegates,
          supportedLocales: FluxerLocalizations.supportedLocales,
          theme: buildFluxerTheme(
            colorTheme: colorTheme,
            textTheme: FluxerTextTheme.fromColors(colorTheme),
            layoutTheme: FluxerLayoutTheme.scaled(),
          ),
          home: const Scaffold(body: DoubleTapReactionHint()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Double tap a message to'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('renders custom animated emoji in double tap hint with pauseWhenOffscreen false', (
    tester,
  ) async {
    final colorTheme = buildDarkColorTheme();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          doubleTapReactionPreferencesProvider.overrideWith(
            () => _FakeDoubleTapReactionPreferences(
              const DoubleTapReactionPreferencesState(
                name: 'custom_animated',
                id: 'e1',
                isSet: true,
              ),
            ),
          ),
          allGuildEmojisForPickerProvider.overrideWith(
            (ref) => Stream.value([
              GuildEmojiEntry(
                id: 'e1',
                name: 'custom_animated',
                animated: true,
                guildId: 'g1',
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          locale: kTestLocale,
          localizationsDelegates: FluxerLocalizations.localizationsDelegates,
          supportedLocales: FluxerLocalizations.supportedLocales,
          theme: buildFluxerTheme(
            colorTheme: colorTheme,
            textTheme: FluxerTextTheme.fromColors(colorTheme),
            layoutTheme: FluxerLayoutTheme.scaled(),
          ),
          home: const Scaffold(body: DoubleTapReactionHint()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final image = tester.widget<CachedEmojiImage>(find.byType(CachedEmojiImage));
    expect(image.emojiId, 'e1');
    expect(image.animated, isTrue);
    expect(image.pauseWhenOffscreen, isFalse);
  });
}

class _FakeDoubleTapReactionPreferences extends DoubleTapReactionPreferences {
  _FakeDoubleTapReactionPreferences(this._initialState);
  final DoubleTapReactionPreferencesState _initialState;

  @override
  DoubleTapReactionPreferencesState build() => _initialState;
}
