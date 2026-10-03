// Fork: tests the fork adds, kept out of upstream's mobile_chat_back_scope_test.dart so that file stays as
// upstream has it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/shell/presentation/mobile_chat_back_scope.dart';
import 'package:fluxer_app/features/shell/providers/reveal_side_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:go_router/go_router.dart';

GoRouter _routerFor(
  String initialLocation, {
  List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
}) {
  return GoRouter(
    initialLocation: initialLocation,
    observers: navigatorObservers,
    routes: [
      GoRoute(
        path: '/channels/@me',
        builder: (context, state) =>
            const MobileChatBackScope(child: Text('dms')),
      ),
      GoRoute(
        path: '/channels/:guildId',
        builder: (context, state) =>
            const MobileChatBackScope(child: Text('Select a channel')),
        routes: [
          GoRoute(
            path: ':channelId',
            builder: (context, state) =>
                const MobileChatBackScope(child: Text('chat')),
          ),
        ],
      ),
    ],
  );
}

ProviderContainer _containerFor(GoRouter router) {
  final container = ProviderContainer(
    overrides: [fluxerRouterProvider.overrideWithValue(router)],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _buildBackScopeApp(ProviderContainer container, GoRouter router) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile back closes drawer when the drawer is open', (
    tester,
  ) async {
    final router = _routerFor('/channels/guild/channel');
    addTearDown(router.dispose);
    final container = _containerFor(router);

    await tester.pumpWidget(_buildBackScopeApp(container, router));
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
