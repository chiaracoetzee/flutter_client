import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

const int _kMaxPushImageBytes = 5 * 1024 * 1024;

const Duration _kPushImageTimeout = Duration(seconds: 20);

Future<String?> downloadPushNotificationImage(String rawUrl) async {
  final Uri? uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client
        .getUrl(uri)
        .timeout(_kPushImageTimeout);
    final HttpClientResponse response = await request.close().timeout(
      _kPushImageTimeout,
    );
    if (response.statusCode != 200) {
      await response.drain<void>();
      return null;
    }
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in response.timeout(_kPushImageTimeout)) {
      if (builder.length + chunk.length > _kMaxPushImageBytes) {
        return null;
      }
      builder.add(chunk);
    }
    final Uint8List bytes = builder.takeBytes();
    if (bytes.isEmpty) {
      return null;
    }
    final Directory dir = await Directory.systemTemp.createTemp('fluxer_push_');
    final File file = File('${dir.path}/image');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } on Object {
    return null;
  } finally {
    client.close(force: true);
  }
}

String? pushAuthorAvatarUrl(Map<String, String> payload) {
  return _httpUrl(payload['author_avatar_url']) ?? _httpUrl(payload['icon']);
}

String? pushAttachmentImageUrl(Map<String, String> payload) {
  if (_mediaDisabled(payload)) {
    return null;
  }
  return _httpUrl(payload['image_url']) ?? _httpUrl(payload['image']);
}

bool _mediaDisabled(Map<String, String> payload) {
  final String? value = payload['has_media']?.toLowerCase();
  return value == 'false' || value == '0';
}

String? _httpUrl(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final Uri? uri = Uri.tryParse(raw);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  return raw;
}
