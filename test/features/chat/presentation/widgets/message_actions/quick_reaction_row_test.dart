import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/message_actions/quick_reaction_row.dart';
import 'package:fluxer_app/features/chat/providers/pickers/emoji_picker_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/emoji_image_cache.dart';
import 'package:fluxer_app/shared/widgets/unicode_emoji_widget.dart';

import '../../../../../helpers/test_l10n.dart';

void main() {
  Widget buildApp(Widget child) {
    final colorTheme = buildDarkColorTheme();
    return ProviderScope(
      child: MaterialApp(
        locale: kTestLocale,
        localizationsDelegates: FluxerLocalizations.localizationsDelegates,
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

  testWidgets('renders animated and static custom emojis with correct properties', (
    tester,
  ) async {
    final items = [
      const UnicodeQuickReaction('👍'),
      CustomQuickReaction(
        GuildEmojiEntry(
          id: 'custom_animated',
          name: 'blobwave',
          animated: true,
          guildId: 'g1',
        ),
      ),
      CustomQuickReaction(
        GuildEmojiEntry(
          id: 'custom_static',
          name: 'pepe',
          animated: false,
          guildId: 'g1',
        ),
      ),
    ];

    await tester.pumpWidget(
      buildApp(
        QuickReactionRow(
          items: items,
          onReaction: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(UnicodeEmojiWidget), findsOneWidget);
    final emojiWidgets = tester.widgetList<CachedEmojiImage>(find.byType(CachedEmojiImage)).toList();
    expect(emojiWidgets, hasLength(2));

    final animatedEmoji = emojiWidgets.firstWhere((w) => w.emojiId == 'custom_animated');
    expect(animatedEmoji.animated, isTrue);
    expect(animatedEmoji.pauseWhenOffscreen, isFalse);

    final staticEmoji = emojiWidgets.firstWhere((w) => w.emojiId == 'custom_static');
    expect(staticEmoji.animated, isFalse);
    expect(staticEmoji.pauseWhenOffscreen, isFalse);
  });
}
