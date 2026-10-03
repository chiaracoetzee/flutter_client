// Fork: tests the fork adds, kept out of upstream's shell_back_resolver_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/shell/navigation/shell_back_resolver.dart';
import 'package:fluxer_app/features/shell/providers/reveal_side_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveShellBackAction', () {
    test('open drawer on chat closes the drawer', () {
      expect(
        resolveShellBackAction(
          hasPopupOverlay: false,
          hasManualGestureBlock: false,
          hasExpressionPanelOpen: false,
          hasChannelDetailsDrawerOpen: false,
          revealSide: RevealSide.left,
          shellLocation: '/channels/guild/channel',
        ),
        ShellBackAction.closeDrawer,
      );
    });
  });
}
