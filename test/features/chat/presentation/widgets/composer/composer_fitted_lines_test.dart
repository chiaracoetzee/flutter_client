import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/theme/fluxer_color_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/channel_textarea.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/composer_fitted_lines.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/mobile_composer_bar.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../../../helpers/composer_channel_textarea_harness.dart';
import '../../../../../helpers/open_test_database.dart';
import '../../../../../helpers/test_l10n.dart';

final String _longDraft = List<String>.filled(30, 'This is a test.').join(' ');

/// The composer at the bottom of a chat panel [height] tall, laid out the
/// way `ChannelChatPanel` does it: the message list takes what is left.
Future<void> _pumpComposerIn(WidgetTester tester, double height) async {
  final FluxerColorTheme colorTheme = buildDarkColorTheme();
  final ProviderContainer container = ProviderContainer(
    overrides: composerChannelTextareaOverrides(database: openTestDatabase()),
  );
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: kTestLocale,
        localizationsDelegates: fluxerLocalizationsDelegates,
        supportedLocales: FluxerLocalizations.supportedLocales,
        theme: buildFluxerTheme(
          colorTheme: colorTheme,
          textTheme: FluxerTextTheme.fromColors(colorTheme),
          layoutTheme: FluxerLayoutTheme.scaled(),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              key: const ValueKey<String>('panel'),
              height: height,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    children: <Widget>[
                      const Expanded(child: SizedBox.expand()),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                        ),
                        child: const ChannelTextarea(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.enterText(channelComposerField(), _longDraft);
  await tester.pump();
  // Upstream's composer animates to its new height (MobileComposerTextGrowth).
  await tester.pump(MobileComposerLayout.resize);
}

/// Lets the composer's typing timers run out on the fake clock, then
/// unmounts it, as the other `ChannelTextarea` tests do.
Future<void> _release(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 400));
  await releaseTestWidgetTree(tester);
}

int _fieldMaxLines(WidgetTester tester) {
  return tester.widget<TextField>(channelComposerField()).maxLines!;
}

void main() {
  group('composerFittedMaxLines', () {
    test('keeps the maximum when there is room or no bound', () {
      expect(
        composerFittedMaxLines(
          maxHeight: 400,
          lineHeight: 20,
          verticalPadding: 20,
          maxLines: 6,
        ),
        6,
      );
      expect(
        composerFittedMaxLines(
          maxHeight: double.infinity,
          lineHeight: 20,
          verticalPadding: 20,
          maxLines: 6,
        ),
        6,
      );
    });

    test('counts whole lines that fit, an exact fit included', () {
      expect(
        composerFittedMaxLines(
          maxHeight: 99,
          lineHeight: 20,
          verticalPadding: 20,
          maxLines: 6,
        ),
        3,
      );
      expect(
        composerFittedMaxLines(
          maxHeight: 100,
          lineHeight: 20,
          verticalPadding: 20,
          maxLines: 6,
        ),
        4,
      );
    });

    test('never goes below one line', () {
      expect(
        composerFittedMaxLines(
          maxHeight: 10,
          lineHeight: 20,
          verticalPadding: 20,
          maxLines: 6,
        ),
        1,
      );
    });
  });

  testWidgets('a long draft shows the most lines when there is room', (
    WidgetTester tester,
  ) async {
    await _pumpComposerIn(tester, 700);
    expect(tester.takeException(), isNull);
    expect(_fieldMaxLines(tester), MobileComposerLayout.maxLines);
    await _release(tester);
  });

  testWidgets('a long draft in a short space shows fewer lines and fits', (
    WidgetTester tester,
  ) async {
    await _pumpComposerIn(tester, 110);
    expect(tester.takeException(), isNull);
    final int lines = _fieldMaxLines(tester);
    expect(lines, inInclusiveRange(1, 5));
    final Rect panel = tester.getRect(
      find.byKey(const ValueKey<String>('panel')),
    );
    final Rect field = tester.getRect(channelComposerField());
    expect(field.bottom, lessThanOrEqualTo(panel.bottom));
    await _release(tester);
  });
}
