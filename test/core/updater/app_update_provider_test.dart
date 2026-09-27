// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/updater/app_update_info.dart';
import 'package:fluxer_app/core/updater/app_update_provider.dart';
import 'package:fluxer_app/core/updater/app_update_service.dart';

class _FakeAppUpdateService extends AppUpdateService {
  AppUpdateInfo? updateInfoResult;
  File? downloadFileResult;
  bool canRequestPackageInstallsResult = true;
  bool openSettingsCalled = false;
  String? installedFilePath;

  @override
  Future<AppUpdateInfo?> checkForUpdate() async => updateInfoResult;

  @override
  Future<File?> downloadUpdate(
    AppUpdateInfo info, {
    void Function(double progress, int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (onProgress != null) {
      onProgress(0.5, 50, 100);
    }
    return downloadFileResult;
  }

  @override
  Future<bool> canRequestPackageInstalls() async =>
      canRequestPackageInstallsResult;

  @override
  Future<bool> openInstallPermissionSettings() async {
    openSettingsCalled = true;
    return true;
  }

  @override
  Future<bool> installUpdate(String filePath) async {
    installedFilePath = filePath;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory? tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_update_provider_test');
    AppUpdateService.platformOverride = true;
  });

  tearDown(() async {
    AppUpdateService.platformOverride = null;
    final dir = tempDir;
    if (dir != null && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  const testInfo = AppUpdateInfo(
    tagName: 'v2.2.0',
    version: '2.2.0',
    title: 'Version 2.2.0',
    releaseNotes: 'Performance improvements',
    downloadUrl: 'https://example.com/app.apk',
    fileName: 'fluxer.apk',
    fileSizeBytes: 1024,
  );

  group('AppUpdateState', () {
    test('copyWith updates specified fields correctly', () {
      const state = AppUpdateState();
      final updated = state.copyWith(
        status: AppUpdateStatus.available,
        updateInfo: testInfo,
        progress: 0.5,
        downloadedFilePath: '/tmp/test.apk',
        errorMessage: 'Something broke',
        isManualCheck: true,
      );

      expect(updated.status, AppUpdateStatus.available);
      expect(updated.updateInfo, testInfo);
      expect(updated.progress, 0.5);
      expect(updated.downloadedFilePath, '/tmp/test.apk');
      expect(updated.errorMessage, 'Something broke');
      expect(updated.isManualCheck, isTrue);
    });
  });

  group('AppUpdateNotifier', () {
    test('checkForUpdate does nothing when platform is unsupported', () async {
      AppUpdateService.platformOverride = false;
      final fakeService = _FakeAppUpdateService();
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      expect(container.read(appUpdateProvider).status, AppUpdateStatus.idle);
    });

    test('checkForUpdate transitions to available when update is found', () async {
      final fakeService = _FakeAppUpdateService()..updateInfoResult = testInfo;
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate(manual: true);
      final state = container.read(appUpdateProvider);
      expect(state.status, AppUpdateStatus.available);
      expect(state.updateInfo, testInfo);
      expect(state.isManualCheck, isTrue);
    });

    test('checkForUpdate transitions to upToDate when no update found', () async {
      final fakeService = _FakeAppUpdateService()..updateInfoResult = null;
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      final state = container.read(appUpdateProvider);
      expect(state.status, AppUpdateStatus.upToDate);
      expect(state.updateInfo, isNull);
    });

    test('startDownload does nothing when updateInfo is null', () async {
      final fakeService = _FakeAppUpdateService();
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).startDownload();
      expect(container.read(appUpdateProvider).status, AppUpdateStatus.idle);
    });

    test('startDownload transitions to readyToInstall and triggers install on success', () async {
      final testFile = File('${tempDir!.path}/downloaded.apk');
      testFile.writeAsStringSync('binary-data');

      final fakeService = _FakeAppUpdateService()
        ..updateInfoResult = testInfo
        ..downloadFileResult = testFile;

      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      await container.read(appUpdateProvider.notifier).startDownload();

      final state = container.read(appUpdateProvider);
      expect(state.status, AppUpdateStatus.readyToInstall);
      expect(state.downloadedFilePath, testFile.path);
      expect(state.progress, 1.0);
      expect(fakeService.installedFilePath, testFile.path);
    });

    test('startDownload transitions to error when file is null or does not exist', () async {
      final fakeService = _FakeAppUpdateService()
        ..updateInfoResult = testInfo
        ..downloadFileResult = null;

      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      await container.read(appUpdateProvider.notifier).startDownload();

      final state = container.read(appUpdateProvider);
      expect(state.status, AppUpdateStatus.error);
      expect(state.errorMessage, 'Failed to download update');
    });

    test('install requests permission settings when canRequestPackageInstalls is false', () async {
      final testFile = File('${tempDir!.path}/downloaded.apk');
      testFile.writeAsStringSync('binary-data');

      final fakeService = _FakeAppUpdateService()
        ..updateInfoResult = testInfo
        ..downloadFileResult = testFile
        ..canRequestPackageInstallsResult = false;

      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      await container.read(appUpdateProvider.notifier).startDownload();

      expect(fakeService.openSettingsCalled, isTrue);
      expect(fakeService.installedFilePath, testFile.path);
    });

    test('install returns false when downloadedFilePath is null', () async {
      final fakeService = _FakeAppUpdateService();
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appUpdateProvider.notifier).install();
      expect(result, isFalse);
    });

    test('dismiss resets state to initial default', () async {
      final fakeService = _FakeAppUpdateService()..updateInfoResult = testInfo;
      final container = ProviderContainer(
        overrides: [
          appUpdateServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appUpdateProvider.notifier).checkForUpdate();
      expect(container.read(appUpdateProvider).status, AppUpdateStatus.available);

      container.read(appUpdateProvider.notifier).dismiss();
      expect(container.read(appUpdateProvider).status, AppUpdateStatus.idle);
      expect(container.read(appUpdateProvider).updateInfo, isNull);
    });
  });
}
