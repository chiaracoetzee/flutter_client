// Fork: tests the fork adds, kept out of upstream's mobile_chat_back_scope_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/shell/providers/reveal_side_provider.dart';

import 'mobile_chat_back_scope_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile back closes drawer when the drawer is open', (
    tester,
  ) async {
    final router = forkUpstream.routerFor('/channels/guild/channel');
    addTearDown(router.dispose);
    final container = forkUpstream.containerFor(router);

    await tester.pumpWidget(forkUpstream.buildBackScopeApp(container, router));
    await tester.pumpAndSettle();

    expect(container.read(currentRevealSideProvider), RevealSide.main);

    final firstHandled = await tester.binding.handlePopRoute();
    await tester.pump();

    expect(firstHandled, isTrue);
    expect(container.read(currentRevealSideProvider), RevealSide.left);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/channels/guild/channel',
    );

    container.read(currentRevealSideProvider.notifier).set(RevealSide.left);
    await tester.pump();

    final secondHandled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(secondHandled, isTrue);
    expect(container.read(currentRevealSideProvider), RevealSide.main);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/channels/guild/channel',
    );
  });
}
