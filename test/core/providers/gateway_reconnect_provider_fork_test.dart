// Fork: tests the fork adds, kept out of upstream's gateway_reconnect_provider_test.dart so that file stays as
// upstream has it.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/providers/app_ui_lifecycle_provider.dart';
import 'package:fluxer_app/core/providers/gateway_connection_provider.dart';
import 'package:fluxer_app/core/providers/gateway_reconnect_provider.dart';
import 'package:fluxer_dart/gateway.dart';
import 'package:riverpod/src/framework.dart' show Override;

class _TestGatewayConnection extends GatewayConnection {
  _TestGatewayConnection() : super(token: 'test', dio: Dio());

  final StreamController<GatewayState> _states =
      StreamController<GatewayState>.broadcast(sync: true);
  GatewayState _current = GatewayState.disconnected;

  @override
  GatewayState get state => _current;

  @override
  Stream<GatewayState> get stateChanges => _states.stream;

  void emit(GatewayState value) {
    _current = value;
    _states.add(value);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
    await super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('moving to background immediately dismisses connected banner', () {
    fakeAsync((FakeAsync async) {
      final _TestGatewayConnection connection = _TestGatewayConnection();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          gatewayConnectionProvider.overrideWithValue(connection),
        ],
      )..read(gatewayReconnectBannerListenerProvider);

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
        final _TestGatewayConnection connection = _TestGatewayConnection();
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
        final _TestGatewayConnection connection = _TestGatewayConnection();
        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[
            gatewayConnectionProvider.overrideWithValue(connection),
          ],
        )..read(gatewayReconnectBannerListenerProvider);

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
