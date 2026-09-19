// Fork: tests the fork adds, kept out of upstream's accessibility_synced_field_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/synced_preferences/fields/accessibility_synced_field.dart';
import 'package:fluxer_app/core/synced_preferences/generated/fluxer/user/preferences/v1/accessibility.pb.dart'
    as accessibility_pb;
import 'package:fluxer_app/features/settings/providers/appearance_preferences_provider.dart';

import 'accessibility_synced_field_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccessibilitySyncedField', () {
    test(
      'ignores desktop fontSize and messageGroupSpacing when mobile layout fields are omitted',
      () {
        final proto = accessibility_pb.AccessibilitySettings(
          fontSize: 24,
          messageGroupSpacing: 0,
          compactMessageGroupSpacing: 0,
        );
        final restored = AccessibilitySyncedField.fromProto(proto);
        expect(restored.chatFontSize, 16);
        expect(restored.messageGroupSpacing, 16);
        expect(restored.compactMessageGroupSpacing, 0);
        expect(restored.hasMobileFontSizeInProto, isFalse);
        expect(restored.hasMobileMessageGroupSpacingInProto, isFalse);
      },
    );

    test(
      'mergeForMigration keeps local font size and spacing when remote omits mobile fields',
      () {
        final field = forkUpstream.splashZoomField();
        const local = AccessibilityLocalState(
          hideKeyboardHints: false,
          channelTypingIndicatorMode: ChannelTypingIndicatorMode.avatars,
          showSelectedChannelTypingIndicator: false,
          showFadedUnreadOnMutedChannels: false,
          dmMessagePreviewMode: DmMessagePreviewMode.all,
          showFavorites: true,
          useSystemLocaleForTimeFormat: false,
          messageGroupSpacing: 18,
          compactMessageGroupSpacing: 2,
          saturationFactor: 1,
          customThemeCss: null,
          chatFontSize: 18,
          hasMobileFontSizeInProto: true,
          hasMobileMessageGroupSpacingInProto: true,
          advanced: forkDefaultAdvancedAccessibility,
        );
        final remote = AccessibilitySyncedField.fromProto(
          accessibility_pb.AccessibilitySettings(
            fontSize: 24,
            messageGroupSpacing: 0,
          ),
        );
        final merged = field.mergeForMigration(local: local, remote: remote);
        expect(merged.chatFontSize, 18);
        expect(merged.messageGroupSpacing, 18);
      },
    );
  });
}
