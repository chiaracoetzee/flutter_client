import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluxer_app/core/updater/app_update_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _kGitHubRepo = 'chiaracoetzee/flutter_client';
  static const String _kLatestReleaseUrl =
      'https://api.github.com/repos/$_kGitHubRepo/releases/latest';

  static const MethodChannel _kInstallChannel =
      MethodChannel('fluxer_app/app_install');

  static bool isSupportedPlatform() => Platform.isAndroid;

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!isSupportedPlatform()) {
      return null;
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final Response<dynamic> response = await _dio.get<dynamic>(
        _kLatestReleaseUrl,
        options: Options(
          headers: const <String, String>{
            'User-Agent': 'FluxerApp',
            'Accept': 'application/vnd.github.v3+json',
          },
          responseType: ResponseType.json,
        ),
      );

      final dynamic responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        return null;
      }
      final Map<String, dynamic> data = responseData;

      final String tagName = (data['tag_name'] as String? ?? '').trim();
      final String title = (data['name'] as String? ?? tagName).trim();
      final String body = (data['body'] as String? ?? '').trim();
      final String? publishedAtStr = data['published_at'] as String?;
      final DateTime? publishedAt =
          publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      final List<dynamic> assets = data['assets'] as List<dynamic>? ?? <dynamic>[];
      Map<String, dynamic>? apkAsset;
      for (final dynamic item in assets) {
        if (item is Map<String, dynamic>) {
          final String name = item['name'] as String? ?? '';
          if (name.endsWith('.apk')) {
            apkAsset = item;
            break;
          }
        }
      }

      if (apkAsset == null || tagName.isEmpty) {
        return null;
      }

      final String downloadUrl =
          apkAsset['browser_download_url'] as String? ?? '';
      final String fileName = apkAsset['name'] as String? ?? 'fluxer.apk';
      final int fileSize = (apkAsset['size'] as num?)?.toInt() ?? 0;

      final (String latestVersion, int? latestBuild) =
          _parseTagVersion(tagName);
      final int? currentBuild = int.tryParse(packageInfo.buildNumber);

      final bool newer = isNewerVersion(
        currentVersion: packageInfo.version,
        latestVersion: latestVersion,
        currentBuild: currentBuild,
        latestBuild: latestBuild,
      );

      if (!newer) {
        return null;
      }

      return AppUpdateInfo(
        tagName: tagName,
        version: latestVersion,
        buildNumber: latestBuild,
        title: title,
        releaseNotes: body,
        downloadUrl: downloadUrl,
        fileName: fileName,
        fileSizeBytes: fileSize,
        publishedAt: publishedAt,
      );
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] check for update error: $e\n$st');
      }
      return null;
    }
  }

  Future<File?> downloadUpdate(
    AppUpdateInfo info, {
    void Function(double progress, int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/${info.fileName}';
      final File targetFile = File(targetPath);

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      await _dio.download(
        info.downloadUrl,
        targetPath,
        onReceiveProgress: (int received, int total) {
          if (onProgress != null && total > 0) {
            final double percent = received / total;
            onProgress(percent, received, total);
          }
        },
        cancelToken: cancelToken,
        options: Options(
          headers: const <String, String>{
            'User-Agent': 'FluxerApp',
          },
        ),
      );

      return targetFile;
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] download update error: $e\n$st');
      }
      return null;
    }
  }

  Future<bool> canRequestPackageInstalls() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool? result = await _kInstallChannel
          .invokeMethod<bool>('canRequestPackageInstalls');
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] canRequestPackageInstalls error: $e');
      }
      return false;
    }
  }

  Future<bool> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool? result = await _kInstallChannel
          .invokeMethod<bool>('openInstallPermissionSettings');
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] openInstallPermissionSettings error: $e');
      }
      return false;
    }
  }

  Future<bool> installUpdate(String filePath) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final bool? result = await _kInstallChannel.invokeMethod<bool>(
        'installPackage',
        <String, dynamic>{'filePath': filePath},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] installUpdate error: $e');
      }
      return false;
    }
  }

  static String cleanVersion(String v) {
    String clean = v.trim();
    if (clean.startsWith('v') || clean.startsWith('V')) {
      clean = clean.substring(1);
    }
    if (clean.contains('+')) {
      clean = clean.split('+')[0];
    }
    if (clean.contains('-')) {
      clean = clean.split('-')[0];
    }
    return clean;
  }

  static (String version, int? build) _parseTagVersion(String tag) {
    String clean = tag.trim();
    if (clean.startsWith('v') || clean.startsWith('V')) {
      clean = clean.substring(1);
    }
    int? build;
    if (clean.contains('+')) {
      final List<String> parts = clean.split('+');
      clean = parts[0];
      build = int.tryParse(parts[1]);
    }
    if (clean.contains('-')) {
      clean = clean.split('-')[0];
    }
    return (clean, build);
  }

  static bool isNewerVersion({
    required String currentVersion,
    required String latestVersion,
    int? currentBuild,
    int? latestBuild,
  }) {
    final String cleanCur = cleanVersion(currentVersion);
    final String cleanLat = cleanVersion(latestVersion);

    final List<int> curParts = cleanCur
        .split('.')
        .map((String p) => int.tryParse(p) ?? 0)
        .toList();
    final List<int> latParts = cleanLat
        .split('.')
        .map((String p) => int.tryParse(p) ?? 0)
        .toList();

    while (curParts.length < 3) {
      curParts.add(0);
    }
    while (latParts.length < 3) {
      latParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (latParts[i] > curParts[i]) {
        return true;
      }
      if (latParts[i] < curParts[i]) {
        return false;
      }
    }

    if (currentBuild != null && latestBuild != null) {
      return latestBuild > currentBuild;
    }

    return false;
  }
}
