import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/instance/instance_constants.dart';
import 'package:fluxer_app/core/instance/instance_endpoint_normalizer.dart';

void main() {
  const InstanceEndpointNormalizer normalizer = InstanceEndpointNormalizer();

  group('normalizeEndpoint', () {
    test('prepends https for bare hostnames', () {
      expect(
        normalizer.normalizeEndpoint('chat.example.com'),
        'https://chat.example.com/api',
      );
    });

    test('preserves explicit https URL with path', () {
      expect(
        normalizer.normalizeEndpoint('https://chat.example.com/v1'),
        'https://chat.example.com/v1',
      );
    });

    test('strips trailing slashes from path', () {
      expect(
        normalizer.normalizeEndpoint('https://chat.example.com/api/'),
        'https://chat.example.com/api',
      );
    });

    test('allows http for LAN installs', () {
      expect(
        normalizer.normalizeEndpoint('http://192.168.1.10'),
        'http://192.168.1.10/api',
      );
    });

    test('throws on empty input', () {
      expect(
        () => normalizer.normalizeEndpoint('  '),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('buildWellKnownUrl', () {
    test('uses api well-known for self-hosted endpoints', () {
      expect(
        normalizer.buildWellKnownUrl('https://chat.example.com/api'),
        'https://chat.example.com/api/.well-known/fluxer',
      );
    });

    test('uses api well-known for self-hosted api client endpoints', () {
      expect(
        normalizer.buildWellKnownUrl('https://chat.example.com/v1'),
        'https://chat.example.com/api/.well-known/fluxer',
      );
    });

    test('uses api well-known for official marketing api path', () {
      expect(
        normalizer.buildWellKnownUrl('https://fluxer.com/api'),
        'https://fluxer.com/api/.well-known/fluxer',
      );
    });

    test('uses api well-known for official web app host', () {
      expect(
        normalizer.buildWellKnownUrl('https://web.fluxer.app/api'),
        'https://web.fluxer.app/api/.well-known/fluxer',
      );
    });
  });

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

    test('rejects self-hosted host', () {
      expect(normalizer.isOfficialInstanceInput('chat.example.com'), isFalse);
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

    test('keeps self-hosted host and non-default path', () {
      expect(
        normalizer.describeApiEndpoint('https://chat.example.com/api'),
        'chat.example.com',
      );
      expect(
        normalizer.describeApiEndpoint('https://chat.example.com/v1'),
        'chat.example.com/v1',
      );
    });
  });

  group('formatDisplayDomain', () {
    test('strips api subdomain prefix', () {
      expect(normalizer.formatDisplayDomain('api.fluxer.app'), 'fluxer.app');
    });

    test('leaves domains without api prefix unchanged', () {
      expect(
        normalizer.formatDisplayDomain('chat.example.com'),
        'chat.example.com',
      );
    });
  });

  group('extractDisplayDomain', () {
    test('strips api subdomain from api endpoint host', () {
      expect(
        normalizer.extractDisplayDomain('https://api.fluxer.app/v1'),
        'fluxer.app',
      );
    });
  });
}
