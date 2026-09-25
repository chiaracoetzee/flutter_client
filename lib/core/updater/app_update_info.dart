class AppUpdateInfo {
  const AppUpdateInfo({
    required this.tagName,
    required this.version,
    required this.title,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.fileName,
    required this.fileSizeBytes,
    this.buildNumber,
    this.publishedAt,
  });

  final String tagName;
  final String version;
  final int? buildNumber;
  final String title;
  final String releaseNotes;
  final String downloadUrl;
  final String fileName;
  final int fileSizeBytes;
  final DateTime? publishedAt;

  String get formattedFileSize {
    if (fileSizeBytes <= 0) {
      return '';
    }
    final double mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
