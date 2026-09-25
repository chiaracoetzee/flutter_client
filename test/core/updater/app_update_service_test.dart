import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/updater/app_update_service.dart';

void main() {
  group('AppUpdateService.cleanVersion', () {
    test('cleans leading v and trailing metadata', () {
      expect(AppUpdateService.cleanVersion('v1.0.22'), '1.0.22');
      expect(AppUpdateService.cleanVersion('V1.0.22'), '1.0.22');
      expect(AppUpdateService.cleanVersion('1.0.23-canary'), '1.0.23');
      expect(AppUpdateService.cleanVersion('1.0.23-beta.1'), '1.0.23');
      expect(AppUpdateService.cleanVersion('1.0.23+24'), '1.0.23');
      expect(AppUpdateService.cleanVersion('v1.0.23-canary+24'), '1.0.23');
    });
  });

  group('AppUpdateService.isNewerVersion', () {
    test('current version with -canary suffix is not older than lower release', () {
      final bool newer = AppUpdateService.isNewerVersion(
        currentVersion: '1.0.23-canary',
        latestVersion: '1.0.22',
        currentBuild: 24,
      );
      expect(newer, isFalse);
    });

    test('current version with -canary suffix detects genuinely newer release', () {
      final bool newer = AppUpdateService.isNewerVersion(
        currentVersion: '1.0.23-canary',
        latestVersion: '1.0.24',
        currentBuild: 24,
      );
      expect(newer, isTrue);
    });

    test('same version compares build numbers if available', () {
      expect(
        AppUpdateService.isNewerVersion(
          currentVersion: '1.0.23-canary',
          latestVersion: '1.0.23',
          currentBuild: 24,
          latestBuild: 25,
        ),
        isTrue,
      );

      expect(
        AppUpdateService.isNewerVersion(
          currentVersion: '1.0.23-canary',
          latestVersion: '1.0.23',
          currentBuild: 24,
          latestBuild: 24,
        ),
        isFalse,
      );

      expect(
        AppUpdateService.isNewerVersion(
          currentVersion: '1.0.23-canary',
          latestVersion: '1.0.23',
          currentBuild: 24,
        ),
        isFalse,
      );
    });

    test('older test build (1.0.21) sees 1.0.22 as newer', () {
      expect(
        AppUpdateService.isNewerVersion(
          currentVersion: '1.0.21-canary',
          latestVersion: '1.0.22',
          currentBuild: 20,
          latestBuild: 23,
        ),
        isTrue,
      );
    });
  });
}
