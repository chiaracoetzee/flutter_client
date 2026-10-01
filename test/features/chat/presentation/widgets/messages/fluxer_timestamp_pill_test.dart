// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/fluxer_timestamp_pill.dart';
import 'package:fluxer_app/features/settings/providers/use_12_hour_time_format_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/tooltip/fluxer_tooltip.dart';
import 'package:fluxer_app/material_ui.dart';

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

  final testDt = DateTime.utc(2026, 3, 20, 15, 30);

  Widget buildTestBed({
    required DateTime dateTime,
    required String flag,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        use12HourTimeFormatProvider.overrideWith((ref) => true),
      ],
      child: Scaffold(
        body: Center(
          child: FluxerTimestampPill(
            dateTime: dateTime,
            flag: flag,
          ),
        ),
      ),
    );
  }

  group('FluxerTimestampPill', () {
    testWidgets('renders absolute date/time and relative tooltip for "f" flag', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 'f',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FluxerTimestampPill), findsOneWidget);
      // Tooltip should be relative
      final tooltip = tester.widget<FluxerTooltip>(find.byType(FluxerTooltip));
      expect(tooltip.message, isNotEmpty);
    });

    testWidgets('renders relative time and absolute tooltip for "R" flag', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 'R',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FluxerTimestampPill), findsOneWidget);
      final tooltip = tester.widget<FluxerTooltip>(find.byType(FluxerTooltip));
      expect(tooltip.message, isNotEmpty);
    });

    testWidgets('handles widget updates changing flag between absolute and relative', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 'f',
        ),
      );
      await tester.pumpAndSettle();

      // Update to 'R'
      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 'R',
        ),
      );
      await tester.pumpAndSettle();

      // Update back to 't'
      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 't',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FluxerTimestampPill), findsOneWidget);
    });

    testWidgets('tapping pill copies text to clipboard', (tester) async {
      final List<MethodCall> log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await tester.pumpWidget(
        buildTestBed(
          dateTime: testDt,
          flag: 'f',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FluxerTimestampPill));
      await tester.pumpAndSettle();

      expect(
        log.any((call) => call.method == 'Clipboard.setData'),
        isTrue,
      );
    });
  });
}
