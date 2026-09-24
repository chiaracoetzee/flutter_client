import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_dart/export.dart';

void main() {
  group('buildCurrentUserProfileUpdatePayload', () {
    test('only includes fields that changed', () {
      const state = UserSettingsViewState(
        userId: '1',
        username: 'alice',
        displayName: 'Alice',
        discriminator: '0',
        avatar: 'existing_hash',
        avatarColor: null,
        memberSince: null,
        status: 'online',
        bio: 'Hello',
        pronouns: 'she/her',
        accentColor: 0xFF0000,
        messageDisplayCompact: false,
        developerMode: false,
        trustedDomains: [],
        editedAvatarBase64: 'data:image/png;base64,abc',
      );

      final json = buildCurrentUserProfileUpdatePayload(state);
      expect(json.keys, ['avatar']);
    });

    test('constructor null marks field present', () {
      const clearedAvatar = UserUpdateWithVerificationRequest(avatar: null);
      expect(clearedAvatar.toJson().containsKey('avatar'), isTrue);

      final partial = UserUpdateWithVerificationRequest.fromJson({
        'avatar': 'data:image/png;base64,abc',
      });
      expect(partial.toJson().containsKey('bio'), isFalse);
    });
  });
}
