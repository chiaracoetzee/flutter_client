// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/updater/app_update_info.dart';
import 'package:fluxer_app/core/updater/app_update_provider.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button.dart';
import 'package:fluxer_app/features/updater/presentation/app_update_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../helpers/pump_fluxer_app.dart';

class _FakeAppUpdateNotifier extends AppUpdateNotifier {
  _FakeAppUpdateNotifier([AppUpdateState state = const AppUpdateState()])
      : _initialState = state;

  final AppUpdateState _initialState;
  bool startDownloadCalled = false;
  bool installCalled = false;

  @override
  AppUpdateState build() => _initialState;

  @override
  Future<void> startDownload() async {
    startDownloadCalled = true;
  }

  @override
  Future<bool> install() async {
    installCalled = true;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testInfo = AppUpdateInfo(
    tagName: 'v2.1.0',
    version: '2.1.0',
    title: 'Fluxer 2.1.0 Release',
    releaseNotes: 'Fixed crash on startup and improved voice latency.',
    downloadUrl: 'https://example.com/app.apk',
    fileName: 'fluxer.apk',
    fileSizeBytes: 30 * 1024 * 1024,
  );

  testWidgets('renders title, tag, formatted size, release notes, and triggers download', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.available,
        updateInfo: testInfo,
      ),
    );

    bool closed = false;
    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: testInfo,
            close: () => closed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fluxer 2.1.0 Release'), findsOneWidget);
    expect(find.text('v2.1.0 • 30.0 MB'), findsOneWidget);
    expect(find.text('Fixed crash on startup and improved voice latency.'), findsOneWidget);

    final downloadBtn = find.byType(FluxerButton);
    expect(downloadBtn, findsOneWidget);
    expect(find.byIcon(PhosphorIconsBold.downloadSimple), findsOneWidget);

    await tester.tap(downloadBtn);
    await tester.pump();

    expect(notifier.startDownloadCalled, isTrue);
    expect(closed, isFalse);
  });

  testWidgets('falls back to tagName when title is empty, and omits size and notes when empty', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.available,
      ),
    );

    const minimalInfo = AppUpdateInfo(
      tagName: 'v2.1.1',
      version: '2.1.1',
      title: '',
      releaseNotes: '',
      downloadUrl: 'https://example.com/app.apk',
      fileName: 'fluxer.apk',
      fileSizeBytes: 0,
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: minimalInfo,
            close: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('v2.1.1'), findsNWidgets(2)); // Title fallback and tag subtitle
    expect(find.textContaining('•'), findsNothing);
  });

  testWidgets('renders downloading progress indicator and percentage text', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.downloading,
        progress: 0.72,
        updateInfo: testInfo,
      ),
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: testInfo,
            close: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final indicatorFinder = find.byType(LinearProgressIndicator);
    expect(indicatorFinder, findsOneWidget);
    final LinearProgressIndicator indicator = tester.widget(indicatorFinder);
    expect(indicator.value, 0.72);

    expect(find.textContaining('72%'), findsOneWidget);
    expect(find.byType(FluxerButton), findsNothing);
  });

  testWidgets('renders indeterminate progress indicator when progress is zero', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.downloading,
        progress: 0.0,
        updateInfo: testInfo,
      ),
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: testInfo,
            close: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final indicatorFinder = find.byType(LinearProgressIndicator);
    expect(indicatorFinder, findsOneWidget);
    final LinearProgressIndicator indicator = tester.widget(indicatorFinder);
    expect(indicator.value, isNull);
  });

  testWidgets('renders readyToInstall state with Install button and triggers install', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.readyToInstall,
        updateInfo: testInfo,
      ),
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: testInfo,
            close: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final installBtn = find.byType(FluxerButton);
    expect(installBtn, findsOneWidget);
    expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);

    await tester.tap(installBtn);
    await tester.pump();

    expect(notifier.installCalled, isTrue);
  });

  testWidgets('renders error text when status is error', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.error,
        errorMessage: 'Network error',
        updateInfo: testInfo,
      ),
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: AppUpdateSheet(
            info: testInfo,
            close: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FluxerButton), findsOneWidget);
    // Finds error text in red style
    expect(find.byWidgetPredicate((widget) {
      if (widget is Text && widget.data != null) {
        return widget.data!.toLowerCase().contains('update') &&
            widget.data!.toLowerCase().contains('failed');
      }
      return false;
    }), findsOneWidget);
  });

  testWidgets('AppUpdateSheet.show opens bottom sheet modal', (tester) async {
    final notifier = _FakeAppUpdateNotifier(
      const AppUpdateState(
        status: AppUpdateStatus.available,
        updateInfo: testInfo,
      ),
    );

    await tester.pumpWidget(
      pumpFluxerApp(
        overrides: [
          appUpdateProvider.overrideWith(() => notifier),
        ],
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppUpdateSheet.show(context, testInfo),
              child: const Text('Show Sheet'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Sheet'));
    await tester.pumpAndSettle();

    expect(find.byType(AppUpdateSheet), findsOneWidget);
    expect(find.text('Fluxer 2.1.0 Release'), findsOneWidget);
  });
}
