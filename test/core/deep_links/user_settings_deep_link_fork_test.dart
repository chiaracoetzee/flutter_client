// Fork: tests the fork adds, kept out of upstream's user_settings_deep_link_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/deep_links/user_settings_deep_link.dart';
import 'package:fluxer_app/features/settings/domain/user_settings_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Uri uri(String path) => Uri.parse('https://web.fluxer.app$path');

  group('parseUserSettingsDeepLink', () {
    test('resolves personas tab to personas section', () {
      final UserSettingsDeepLinkTarget? target = parseUserSettingsDeepLink(
        uri('/settings/user?tab=personas'),
      );
      expect(target?.section, UserSettingsSection.personas);
      expect(target?.tab, 'personas');
      expect(target?.fieldId, isNull);
    });
  });
}
