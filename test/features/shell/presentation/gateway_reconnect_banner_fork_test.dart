// Fork: tests the fork adds, kept out of upstream's gateway_reconnect_banner_test.dart so that file stays as
// upstream has it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/providers/app_ui_lifecycle_provider.dart';
import 'package:fluxer_app/core/providers/gateway_reconnect_provider.dart';
import 'package:fluxer_app/features/shell/presentation/gateway_reconnect_banner.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../helpers/pump_fluxer_app.dart';
import '../../../helpers/test_l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpBanner(WidgetTester tester) async {
    await tester.pumpWidget(
      pumpFluxerApp(
        child: const GatewayReconnectBannerOverlay(child: SizedBox.expand()),
      ),
    );
    return ProviderScope.containerOf(
      tester.element(find.byType(GatewayReconnectBannerOverlay)),
    );
  }

  testWidgets('connected toast dismisses cleanly when hide is called', (
    tester,
  ) async {
    final ProviderContainer container = await pumpBanner(tester);

    container.read(gatewayReconnectBannerProvider.notifier).showConnected();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text(testL10n.gatewayConnectedToast), findsOneWidget);

    container.read(gatewayReconnectBannerProvider.notifier).hide();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(testL10n.gatewayConnectedToast), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rapid background/foreground transitions dismiss banner cleanly without getting stuck',
    (tester) async {
      final ProviderContainer container = await pumpBanner(tester);
      // Upstream's lifecycle starts in the background when the binding has no
      // state yet, as in tests; the app is in the foreground here.
      container.read(appUiForegroundProvider.notifier).setResumed(true);

      container.read(gatewayReconnectBannerProvider.notifier).showConnected();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));

      expect(find.text(testL10n.gatewayConnectedToast), findsOneWidget);

      container.read(appUiForegroundProvider.notifier).setResumed(false);
      await tester.pump();

      expect(find.text(testL10n.gatewayConnectedToast), findsNothing);

      container.read(appUiForegroundProvider.notifier).setResumed(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(testL10n.gatewayConnectedToast), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
