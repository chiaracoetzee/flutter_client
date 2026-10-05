// Fork: tests the fork adds, kept out of upstream's instance_endpoint_normalizer_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/instance/instance_constants.dart';
import 'package:fluxer_app/core/instance/instance_endpoint_normalizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const InstanceEndpointNormalizer normalizer = InstanceEndpointNormalizer();

  group('isOfficialInstanceInput', () {
    test("matches this build's own instance host", () {
      expect(
        normalizer.isOfficialInstanceInput(
          InstanceConstants.defaultInstanceInputUrl,
        ),
        isTrue,
      );
      expect(
        normalizer.isOfficialInstanceInput(InstanceConstants.defaultApiBaseUrl),
        isTrue,
      );
    });

    test("does not treat upstream's hosts as this build's instance", () {
      for (final String host in <String>[
        'fluxer.com',
        'web.fluxer.com',
        'canary.fluxer.com',
        'fluxer.app',
        'web.fluxer.app',
        'canary.fluxer.app',
        'https://fluxer.com/api/v1',
      ]) {
        expect(normalizer.isOfficialInstanceInput(host), isFalse, reason: host);
      }
    });
  });

  group('describeApiEndpoint', () {
    test('maps the default instance to its input url', () {
      expect(
        normalizer.describeApiEndpoint(
          InstanceConstants.defaultInstanceInputUrl,
        ),
        InstanceConstants.defaultInstanceInputUrl,
      );
      expect(
        normalizer.describeApiEndpoint(InstanceConstants.defaultApiBaseUrl),
        InstanceConstants.defaultInstanceInputUrl,
      );
    });

    test("never labels upstream's hosts as the default instance", () {
      for (final String endpoint in <String>[
        'fluxer.com',
        'fluxer.app',
        'https://fluxer.com/api/v1',
      ]) {
        expect(
          normalizer.describeApiEndpoint(endpoint),
          isNot(InstanceConstants.defaultInstanceInputUrl),
          reason: endpoint,
        );
        expect(
          normalizer.describeApiEndpoint(endpoint),
          contains('fluxer.'),
          reason: endpoint,
        );
      }
    });
  });
}
