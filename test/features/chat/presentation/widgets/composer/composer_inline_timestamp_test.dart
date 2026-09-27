// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/composer_inline_timestamp.dart';
import 'package:fluxer_app/features/chat/services/timestamp_inline_token.dart';
import 'package:fluxer_app/features/settings/providers/use_12_hour_time_format_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../helpers/pump_fluxer_app.dart';

class _FakeUserSettings extends UserSettingsViewModel {
  @override
  UserSettingsViewState build() => const UserSettingsViewState(
        userId: '1',
        username: 'tester',
        displayName: 'Root User',
        discriminator: '0001',
        avatar: null,
        avatarColor: null,
        memberSince: null,
        status: 'online',
        messageDisplayCompact: false,
        developerMode: false,
        trustedDomains: <String>[],
        timezone: 'UTC',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const int testEpoch = 1774008000; // 2026-03-20 12:00:00 UTC

  Widget buildTestBed({
    required int epoch,
    required String style,
    VoidCallback? onTap,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        use12HourTimeFormatProvider.overrideWith((ref) => true),
      ],
      child: Scaffold(
        body: Center(
          child: ComposerInlineTimestamp(
            epoch: epoch,
            style: style,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('ComposerInlineTimestamp', () {
    testWidgets('renders clock icon and formatted text for combo style', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'combo',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ComposerInlineTimestamp), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.clock), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders relative time for "R" style', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'R',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ComposerInlineTimestamp), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.clock), findsOneWidget);
    });

    testWidgets('handles widget updates between relative and absolute styles', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'f',
        ),
      );
      await tester.pumpAndSettle();

      // Change to 'R'
      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'R',
        ),
      );
      await tester.pumpAndSettle();

      // Change to 'd'
      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'd',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ComposerInlineTimestamp), findsOneWidget);
    });

    testWidgets('tapping chip triggers onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestBed(
          epoch: testEpoch,
          style: 'combo',
          onTap: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ComposerInlineTimestamp));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('TimestampInlineToken', () {
    test('produces correct wireText for standard and combo styles', () {
      final tokenF = TimestampInlineToken(epoch: 1234567890, style: 'f');
      expect(tokenF.wireText, '<t:1234567890:f>');

      final tokenR = TimestampInlineToken(epoch: 1234567890, style: 'R');
      expect(tokenR.wireText, '<t:1234567890:R>');

      final tokenCombo = TimestampInlineToken(epoch: 1234567890, style: 'combo');
      expect(tokenCombo.wireText, '<t:1234567890:f> (<t:1234567890:R>)');
    });

    testWidgets('buildInline constructs ComposerInlineTimestamp widget', (tester) async {
      TimestampInlineToken? tappedToken;
      final token = TimestampInlineToken(
        epoch: testEpoch,
        style: 'F',
        onTap: (t) => tappedToken = t,
      );

      await tester.pumpWidget(
        pumpFluxerApp(
          overrides: [
            userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
            use12HourTimeFormatProvider.overrideWith((ref) => true),
          ],
          child: Scaffold(
            body: Builder(
              builder: (context) => token.buildInline(context, null),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ComposerInlineTimestamp), findsOneWidget);

      await tester.tap(find.byType(ComposerInlineTimestamp));
      await tester.pumpAndSettle();

      expect(tappedToken, same(token));
    });
  });
}
