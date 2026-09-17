import 'package:flutter/foundation.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'typing_sender.g.dart';

const Duration kTypingThrottle = Duration(seconds: 8);

@Riverpod(keepAlive: true)
class TypingSender extends _$TypingSender {
  final Map<String, DateTime> _lastSentAt = <String, DateTime>{};
  final Map<String, String?> _lastSentPersonaId = <String, String?>{};

  @override
  void build() {}

  Future<void> notifyUserTyping(
    String channelId, {
    Map<String, dynamic>? personaData,
  }) async {
    if (channelId.isEmpty) {
      return;
    }
    final String? personaId =
        personaData != null ? personaData['id'] as String? : null;
    final now = DateTime.now();
    final lastSent = _lastSentAt[channelId];
    final bool hasSentBefore = _lastSentPersonaId.containsKey(channelId);
    final lastPersonaId = _lastSentPersonaId[channelId];
    final bool personaChanged = hasSentBefore && lastPersonaId != personaId;

    if (!personaChanged &&
        lastSent != null &&
        now.difference(lastSent) < kTypingThrottle) {
      return;
    }
    _lastSentAt[channelId] = now;
    _lastSentPersonaId[channelId] = personaId;
    try {
      final Map<String, dynamic>? body = personaData != null
          ? <String, dynamic>{'subprofile': personaData}
          : null;
      await ref
          .read(fluxerClientProvider)
          .channels
          .indicateTyping(channelId: channelId, body: body);
    } on Exception catch (err) {
      debugPrint('[TypingSender] Failed to send typing for $channelId: $err');
    }
  }

  void clearChannel(String channelId) {
    _lastSentAt.remove(channelId);
    _lastSentPersonaId.remove(channelId);
  }

  void reset() {
    _lastSentAt.clear();
    _lastSentPersonaId.clear();
  }
}
