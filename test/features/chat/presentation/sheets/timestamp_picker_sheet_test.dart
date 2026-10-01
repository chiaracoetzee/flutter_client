// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/sheets/timestamp_picker_sheet.dart';
import 'package:fluxer_app/features/chat/providers/pickers/timestamp_insert_provider.dart';
import 'package:fluxer_app/features/settings/providers/use_12_hour_time_format_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../helpers/pump_fluxer_app.dart';

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

  Widget buildTestBed({
    int? initialEpoch,
    String? initialStyle,
    void Function(int epoch, String style)? onInsert,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        use12HourTimeFormatProvider.overrideWith((ref) => true),
      ],
      child: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              key: const ValueKey('open_timestamp_picker_btn'),
              onPressed: () => TimestampPickerSheet.show(
                context,
                initialEpoch: initialEpoch,
                initialStyle: initialStyle,
                onInsert: onInsert,
              ),
              child: const Text('Open Timestamp Picker'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPicker(
    WidgetTester tester, {
    int? initialEpoch,
    String? initialStyle,
    void Function(int epoch, String style)? onInsert,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildTestBed(
        initialEpoch: initialEpoch,
        initialStyle: initialStyle,
        onInsert: onInsert,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_timestamp_picker_btn')));
    await tester.pumpAndSettle();
  }

  group('TimestampPickerSheet', () {
    testWidgets('renders all controls with initial values', (tester) async {
      // 2026-03-20 12:00:00 UTC = 1774008000
      await openPicker(
        tester,
        initialEpoch: 1774008000,
        initialStyle: 'f',
      );

      expect(find.text('Insert Timestamp'), findsWidgets);
      expect(find.text('e.g. tomorrow at 3pm, in 2 hours, now'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('TIME ZONE'), findsOneWidget);
      expect(find.text('FORMAT PREVIEW'), findsOneWidget);
      expect(find.text('Insert'), findsOneWidget);
    });

    testWidgets('typing NLP expression updates input and clear icon resets it', (tester) async {
      await openPicker(tester);

      final nlpInput = find.byType(TextField).first;
      await tester.enterText(nlpInput, 'tomorrow at 3pm');
      await tester.pumpAndSettle();

      expect(find.text('tomorrow at 3pm'), findsOneWidget);

      // Suffix icon PhosphorIconsFill.xCircle should be visible
      final clearIcon = find.byIcon(PhosphorIconsFill.xCircle);
      expect(clearIcon, findsOneWidget);

      await tester.tap(clearIcon);
      await tester.pumpAndSettle();

      expect(find.text('tomorrow at 3pm'), findsNothing);
    });

    testWidgets('tapping Insert invokes onInsert callback and closes sheet', (tester) async {
      int? capturedEpoch;
      String? capturedStyle;

      await openPicker(
        tester,
        initialEpoch: 1774008000,
        initialStyle: 'R',
        onInsert: (epoch, style) {
          capturedEpoch = epoch;
          capturedStyle = style;
        },
      );

      await tester.tap(find.text('Insert'));
      await tester.pumpAndSettle();

      expect(capturedEpoch, isNotNull);
      expect(capturedStyle, 'R');

      // Sheet is closed
      expect(find.text('FORMAT PREVIEW'), findsNothing);
    });

    testWidgets('tapping Insert without callback emits to pendingTimestampInsertProvider', (tester) async {
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        pumpFluxerApp(
          overrides: [
            userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
            use12HourTimeFormatProvider.overrideWith((ref) => true),
          ],
          child: Scaffold(
            body: Center(
              child: Consumer(
                builder: (context, ref, _) {
                  capturedRef = ref;
                  return ElevatedButton(
                    key: const ValueKey('open_btn'),
                    onPressed: () => TimestampPickerSheet.show(
                      context,
                      initialEpoch: 1774008000,
                      initialStyle: 'D',
                    ),
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('open_btn')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insert'));
      await tester.pumpAndSettle();

      final emitted = capturedRef.read(pendingTimestampInsertProvider);
      expect(emitted, isNotNull);
      expect(emitted?.style, 'D');
    });

    testWidgets('initializes with default current time and combo style when no arguments passed', (tester) async {
      await openPicker(tester);

      expect(find.text('FORMAT PREVIEW'), findsOneWidget);
      expect(find.text('Insert'), findsOneWidget);
    });
  });
}
