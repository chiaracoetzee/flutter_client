import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/updater/app_update_info.dart';
import 'package:fluxer_app/core/updater/app_update_service.dart';

final Provider<AppUpdateService> appUpdateServiceProvider =
    Provider<AppUpdateService>((Ref ref) {
  return AppUpdateService();
});

enum AppUpdateStatus {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  readyToInstall,
  error,
}

class AppUpdateState {
  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.updateInfo,
    this.progress = 0.0,
    this.downloadedFilePath,
    this.errorMessage,
    this.isManualCheck = false,
  });

  final AppUpdateStatus status;
  final AppUpdateInfo? updateInfo;
  final double progress;
  final String? downloadedFilePath;
  final String? errorMessage;
  final bool isManualCheck;

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    AppUpdateInfo? updateInfo,
    double? progress,
    String? downloadedFilePath,
    String? errorMessage,
    bool? isManualCheck,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      progress: progress ?? this.progress,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
      isManualCheck: isManualCheck ?? this.isManualCheck,
    );
  }
}

class AppUpdateNotifier extends Notifier<AppUpdateState> {
  @override
  AppUpdateState build() => const AppUpdateState();

  AppUpdateService get _service => ref.read(appUpdateServiceProvider);

  Future<void> checkForUpdate({bool manual = false}) async {
    if (!AppUpdateService.isSupportedPlatform()) {
      return;
    }

    state = state.copyWith(
      status: AppUpdateStatus.checking,
      isManualCheck: manual,
    );

    final AppUpdateInfo? info = await _service.checkForUpdate();
    if (info != null) {
      state = state.copyWith(
        status: AppUpdateStatus.available,
        updateInfo: info,
      );
    } else {
      state = state.copyWith(
        status: AppUpdateStatus.upToDate,
      );
    }
  }

  Future<void> startDownload() async {
    final AppUpdateInfo? info = state.updateInfo;
    if (info == null) {
      return;
    }

    state = state.copyWith(
      status: AppUpdateStatus.downloading,
      progress: 0,
    );

    final File? file = await _service.downloadUpdate(
      info,
      onProgress: (double progress, int received, int total) {
        state = state.copyWith(progress: progress);
      },
    );

    if (file != null && file.existsSync()) {
      state = state.copyWith(
        status: AppUpdateStatus.readyToInstall,
        downloadedFilePath: file.path,
        progress: 1,
      );
      await install();
    } else {
      state = state.copyWith(
        status: AppUpdateStatus.error,
        errorMessage: 'Failed to download update',
      );
    }
  }

  Future<bool> install() async {
    final String? filePath = state.downloadedFilePath;
    if (filePath == null) {
      return false;
    }

    final bool canInstall = await _service.canRequestPackageInstalls();
    if (!canInstall) {
      await _service.openInstallPermissionSettings();
    }

    return _service.installUpdate(filePath);
  }

  void dismiss() {
    state = const AppUpdateState();
  }
}

final NotifierProvider<AppUpdateNotifier, AppUpdateState> appUpdateProvider =
    NotifierProvider<AppUpdateNotifier, AppUpdateState>(AppUpdateNotifier.new);
