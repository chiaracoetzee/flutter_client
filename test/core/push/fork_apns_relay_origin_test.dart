// Fork: the shipped flavour's iOS relay URLs name a host of the fork's, which the instance's push
// service delivers itself with the fork's APNs key, instead of Fluxer's relay.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/push/relay_consent/push_relay_consent_logic.dart';
import 'package:fluxer_app/core/push/web_push/web_push_relay.dart';

String _shippedApnsRelayOrigin() {
  final Object? defines = jsonDecode(
    File('tool/dart_defines/canary.json').readAsStringSync(),
  );
  return (defines! as Map<String, dynamic>)['FORK_APNS_RELAY_ORIGIN'] as String;
}

void main() {
  test('the shipped flavour names its own APNs relay host', () {
    final Uri origin = Uri.parse(_shippedApnsRelayOrigin());
    expect(origin.scheme, 'https');
    expect(origin.host, 'push.tyne.chat');
    expect(origin.path, isEmpty);
    expect(origin.host, isNot(Uri.parse(kPushRelayOrigin).host));
  });

  test(
    'its relay URLs are not Fluxer relay URLs and need no relay consent',
    () {
      final String relayUrl =
          '${_shippedApnsRelayOrigin()}/relay/v1/apns/canary/production/ab';
      expect(isFluxerPushRelayUrl(relayUrl), isFalse);
      expect(
        isPushRelayConsentRequired(
          relayUrl: relayUrl,
          isConsentGranted: false,
          isOfficialInstance: false,
        ),
        isFalse,
      );
    },
  );

  test("without the build setting the APNs relay URLs stay upstream's", () {
    expect(
      apnsRelayUrl(
        appId: 'canary',
        environment: 'production',
        deviceTokenHex: 'ab',
      ),
      '$kPushRelayOrigin/relay/v1/apns/canary/production/ab',
    );
    expect(
      apnsVoipRelayUrl(
        appId: 'canary',
        environment: 'production',
        deviceTokenHex: 'ab',
      ),
      '$kPushRelayOrigin/relay/v1/apns-voip/canary/production/ab',
    );
  });
}
