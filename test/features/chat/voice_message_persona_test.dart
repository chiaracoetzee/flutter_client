// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/message_repository.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/utils/attachments/voice_message_constants.dart';

void main() {
  group('Voice message and retry persona payload handling', () {
    test('buildMessageCreateBody includes subprofile for voice message with personaData', () {
      final personaData = <String, dynamic>{
        'id': 'persona_123',
        'name': 'Test Persona',
        'avatar': 'https://example.com/avatar.png',
        'banner': 'https://example.com/banner.png',
        'display_tag_text': 'TAG',
        'system_name': 'TAG',
        'display_tag_icon': 'https://example.com/icon.png',
        'avatar_color': 0xFF00FF,
        'color': 0xFF00FF,
      };

      final body = buildMessageCreateBody(
        content: '',
        messageFlags: kMessageFlagVoiceMessage,
        personaData: personaData,
        clientNonce: '123456789',
      );

      expect(body['subprofile'], equals(personaData));
      expect(body['flags'], equals(kMessageFlagVoiceMessage));
      expect(body['nonce'], equals('123456789'));
      expect(body.containsKey('content'), isFalse);
    });

    test('buildMessageCreateBody omits subprofile when personaData is null', () {
      final body = buildMessageCreateBody(
        content: '',
        messageFlags: kMessageFlagVoiceMessage,
        personaData: null,
        clientNonce: '123456789',
      );

      expect(body.containsKey('subprofile'), isFalse);
      expect(body['flags'], equals(kMessageFlagVoiceMessage));
      expect(body['nonce'], equals('123456789'));
    });

    test('reconstructing personaData from failed message preserves full subprofile identity', () {
      final failedMessage = Message(
        id: 'msg_999',
        channelId: 'channel_1',
        authorId: 'user_1',
        authorName: 'RootUser',
        content: 'Failed message',
        timestamp: DateTime.utc(2026, 1, 1),
        deliveryState: MessageDeliveryState.failed,
        personaId: 'persona_alice',
        personaName: 'Alice',
        personaAvatar: 'https://example.com/alice.png',
        personaBanner: 'https://example.com/alice_banner.png',
        personaTag: 'ALICE_TAG',
        personaTagIcon: 'https://example.com/alice_icon.png',
        authorAvatarColor: 0x123456,
      );

      // Reconstruct personaData as done in retryFailedMessage
      final String? pTag = failedMessage.personaTag;
      final Map<String, dynamic>? retryPersonaData = failedMessage.personaId != null &&
              failedMessage.personaId!.isNotEmpty
          ? <String, dynamic>{
              'id': failedMessage.personaId,
              if (failedMessage.personaName != null) 'name': failedMessage.personaName,
              if (failedMessage.personaAvatar != null) 'avatar': failedMessage.personaAvatar,
              if (failedMessage.personaBanner != null) 'banner': failedMessage.personaBanner,
              if (pTag != null) 'display_tag_text': pTag,
              if (pTag != null) 'system_name': pTag,
              if (failedMessage.personaTagIcon != null)
                'display_tag_icon': failedMessage.personaTagIcon,
              if (failedMessage.authorAvatarColor != null)
                'avatar_color': failedMessage.authorAvatarColor,
              if (failedMessage.authorAvatarColor != null)
                'color': failedMessage.authorAvatarColor,
            }
          : null;

      expect(retryPersonaData, isNotNull);
      expect(retryPersonaData!['id'], equals('persona_alice'));
      expect(retryPersonaData['name'], equals('Alice'));
      expect(retryPersonaData['avatar'], equals('https://example.com/alice.png'));
      expect(retryPersonaData['banner'], equals('https://example.com/alice_banner.png'));
      expect(retryPersonaData['display_tag_text'], equals('ALICE_TAG'));
      expect(retryPersonaData['system_name'], equals('ALICE_TAG'));
      expect(retryPersonaData['display_tag_icon'], equals('https://example.com/alice_icon.png'));
      expect(retryPersonaData['color'], equals(0x123456));

      // Verify body with reconstructed retry persona data
      final body = buildMessageCreateBody(
        content: failedMessage.content,
        personaData: retryPersonaData,
      );

      expect(body['subprofile'], equals(retryPersonaData));
      expect(body['content'], equals('Failed message'));
    });
  });
}
