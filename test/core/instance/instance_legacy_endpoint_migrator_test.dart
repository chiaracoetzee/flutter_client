import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/instance/instance_config_snapshot.dart';
import 'package:fluxer_app/core/instance/instance_constants.dart';
import 'package:fluxer_app/core/instance/instance_legacy_endpoint_migrator.dart';

// In this fork the "official" instance is the build's own default, not
// fluxer.com. The migrator must only ever normalise snapshots of that instance;
// a stored account on upstream's Fluxer keeps its own endpoints, otherwise its
// token would be sent to this build's server.
void main() {
  const InstanceLegacyEndpointMigrator migrator =
      InstanceLegacyEndpointMigrator();

  group('migrateOfficialSnapshotIfNeeded', () {
    test('leaves self-hosted snapshots unchanged', () {
      const InstanceConfigSnapshot selfHosted = InstanceConfigSnapshot(
        apiBaseUrl: 'https://chat.example.com/v1',
        gatewayUrl: 'wss://chat.example.com/gateway',
        displayDomain: 'chat.example.com',
      );
      expect(migrator.migrateOfficialSnapshotIfNeeded(selfHosted), isNull);
    });
  });

  group('migrateOfficialApiBaseUrlIfNeeded', () {
    test('ignores current api base url', () {
      expect(
        migrator.migrateOfficialApiBaseUrlIfNeeded(
          InstanceConstants.defaultApiBaseUrl,
        ),
        isNull,
      );
    });
  });

  group('migrateOfficialRecentDomainIfNeeded', () {
    test('ignores self-hosted domains', () {
      expect(
        migrator.migrateOfficialRecentDomainIfNeeded('chat.example.com'),
        isNull,
      );
    });
  });
}
