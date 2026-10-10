// Fork: tests the fork adds, kept out of upstream's gateway_reconnect_provider_test.dart so that file stays as
// upstream has it.
import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/providers/app_ui_lifecycle_provider.dart';
import 'package:fluxer_app/core/providers/gateway_connection_provider.dart';
import 'package:fluxer_app/core/providers/gateway_reconnect_provider.dart';
import 'package:fluxer_dart/gateway.dart';
import 'package:riverpod/src/framework.dart' show Override;

import 'gateway_reconnect_provider_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('moving to background immediately dismisses connected banner', () {
    fakeAsync((FakeAsync async) {
      final ForkTestGatewayConnection connection = ForkTestGatewayConnection();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          gatewayConnectionProvider.overrideWithValue(connection),
        ],
      )..read(gatewayReconnectBannerListenerProvider);
      // The banner only shows while the app is in the foreground.
      container.read(appUiForegroundProvider.notifier).setResumed(true);

      connection
        ..emit(GatewayState.connected)
        ..emit(GatewayState.reconnecting);
      async.elapse(kReconnectBannerDelay);
      connection.emit(GatewayState.connected);

      expect(
        container.read(gatewayReconnectBannerProvider),
        GatewayReconnectBannerPhase.connected,
      );

      container.read(appUiForegroundProvider.notifier).setResumed(false);
      expect(
        container.read(gatewayReconnectBannerProvider),
        GatewayReconnectBannerPhase.hidden,
      );

      container.dispose();
      unawaited(connection.dispose());
    });
  });

  test(
    'background disconnect and reconnect does not show reconnect banner',
    () {
      fakeAsync((FakeAsync async) {
        final ForkTestGatewayConnection connection =
            ForkTestGatewayConnection();
        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[
            gatewayConnectionProvider.overrideWithValue(connection),
          ],
        )..read(gatewayReconnectBannerListenerProvider);

        connection.emit(GatewayState.connected);
        container.read(appUiForegroundProvider.notifier).setResumed(false);

        connection.emit(GatewayState.reconnecting);
        async.elapse(const Duration(seconds: 5));
        expect(
          container.read(gatewayReconnectBannerProvider),
          GatewayReconnectBannerPhase.hidden,
        );

        connection.emit(GatewayState.connected);
        expect(
          container.read(gatewayReconnectBannerProvider),
          GatewayReconnectBannerPhase.hidden,
        );

        container.dispose();
        unawaited(connection.dispose());
      });
    },
  );

  test(
    'banner hold expires if wall-clock deadline passes while backgrounded',
    () {
      fakeAsync((FakeAsync async) {
        final ForkTestGatewayConnection connection =
            ForkTestGatewayConnection();
        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[
            gatewayConnectionProvider.overrideWithValue(connection),
          ],
        )..read(gatewayReconnectBannerListenerProvider);
        // The banner only shows while the app is in the foreground.
        container.read(appUiForegroundProvider.notifier).setResumed(true);

        container.read(gatewayReconnectBannerProvider.notifier).showConnected();
        expect(
          container.read(gatewayReconnectBannerProvider),
          GatewayReconnectBannerPhase.connected,
        );

        container.read(appUiForegroundProvider.notifier).setResumed(false);
        expect(
          container.read(gatewayReconnectBannerProvider),
          GatewayReconnectBannerPhase.hidden,
        );

        async.elapse(kReconnectBannerSuccessHold * 2);
        container.read(appUiForegroundProvider.notifier).setResumed(true);
        expect(
          container.read(gatewayReconnectBannerProvider),
          GatewayReconnectBannerPhase.hidden,
        );

        container.dispose();
        unawaited(connection.dispose());
      });
    },
  );
}
