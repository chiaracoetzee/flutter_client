import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/instance/instance_config_snapshot.dart';
import 'package:fluxer_app/core/observability/measure_http_policy.dart';

// Fork imports.
// ignore: directives_ordering
import 'package:fluxer_app/core/instance/instance_constants.dart';

void main() {
  const MeasureHttpPolicy policy = kMeasureHttpPolicy;

  final InstanceConfigSnapshot official =
      InstanceConfigSnapshot.officialDefault();
  const InstanceConfigSnapshot selfHosted = InstanceConfigSnapshot(
    apiBaseUrl: 'https://chat.example.org/api/v1',
    gatewayUrl: 'wss://gateway.chat.example.org',
    displayDomain: 'chat.example.org',
  );

  test('tracks only official instance API hosts', () {
    expect(
      policy.shouldTrackHttpRequest(
        instance: official,
        // Fork: this build's own instance, not upstream's fluxer.com.
        requestUri: Uri.parse(
          '${InstanceConstants.defaultApiBaseUrl}/users/@me',
        ),
      ),
      isTrue,
    );
    expect(
      policy.shouldTrackHttpRequest(
        instance: selfHosted,
        requestUri: Uri.parse('https://chat.example.org/api/v1/users/@me'),
      ),
      isFalse,
    );
  });

  // Fork: this build's official hosts are InstanceConstants.officialInstanceHosts;
  // upstream's canary.fluxer.com is an ordinary instance here.
  test('isOfficialFluxerInstance includes canary defaults', () {
    for (final String host in InstanceConstants.officialInstanceHosts) {
      final InstanceConfigSnapshot canary = InstanceConfigSnapshot(
        apiBaseUrl: 'https://$host/api/v1',
        gatewayUrl: 'wss://gateway.$host',
        displayDomain: host,
      );
      expect(policy.isOfficialFluxerInstance(canary), isTrue);
      expect(
        policy.shouldTrackHttpRequest(
          instance: canary,
          requestUri: Uri.parse('https://$host/api/v1/guilds'),
        ),
        isTrue,
      );
    }
  });
}
