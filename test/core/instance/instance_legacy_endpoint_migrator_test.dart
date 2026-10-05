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
    test('normalises a default-instance snapshot with stale endpoints', () {
      const InstanceConfigSnapshot stale = InstanceConfigSnapshot(
        apiBaseUrl: InstanceConstants.defaultApiBaseUrl,
        gatewayUrl: 'wss://gateway.stale.example',
        displayDomain: InstanceConstants.defaultInstanceInputUrl,
      );
      final InstanceConfigSnapshot? migrated = migrator
          .migrateOfficialSnapshotIfNeeded(stale);
      expect(migrated, isNotNull);
      expect(migrated!.apiBaseUrl, InstanceConstants.defaultApiBaseUrl);
      expect(migrated.gatewayUrl, InstanceConstants.defaultGatewayUrl);
      expect(migrated.displayDomain, InstanceConstants.defaultInstanceInputUrl);
      expect(migrated.wellKnown, isNull);
    });

    test("leaves upstream's legacy production snapshot alone", () {
      const InstanceConfigSnapshot legacy = InstanceConfigSnapshot(
        apiBaseUrl: 'https://api.fluxer.app/v1',
        gatewayUrl: 'wss://gateway.fluxer.app',
        displayDomain: 'fluxer.app',
      );
      expect(migrator.migrateOfficialSnapshotIfNeeded(legacy), isNull);
    });

    test("leaves upstream's current production snapshot alone", () {
      const InstanceConfigSnapshot current = InstanceConfigSnapshot(
        apiBaseUrl: 'https://fluxer.com/api/v1',
        gatewayUrl: 'wss://gateway.fluxer.com',
        displayDomain: 'fluxer.com',
      );
      expect(migrator.migrateOfficialSnapshotIfNeeded(current), isNull);
    });

    test("leaves upstream's canary snapshot alone", () {
      const InstanceConfigSnapshot legacy = InstanceConfigSnapshot(
        apiBaseUrl: 'https://api.canary.fluxer.app/v1',
        gatewayUrl: 'wss://gateway.canary.fluxer.app',
        displayDomain: 'canary.fluxer.app',
      );
      expect(migrator.migrateOfficialSnapshotIfNeeded(legacy), isNull);
    });

    test('leaves self-hosted snapshots unchanged', () {
      const InstanceConfigSnapshot selfHosted = InstanceConfigSnapshot(
        apiBaseUrl: 'https://chat.example.com/v1',
        gatewayUrl: 'wss://chat.example.com/gateway',
        displayDomain: 'chat.example.com',
      );
      expect(migrator.migrateOfficialSnapshotIfNeeded(selfHosted), isNull);
    });

    test('leaves the current default snapshot unchanged', () {
      final InstanceConfigSnapshot current =
          InstanceConfigSnapshot.officialDefault();
      expect(migrator.migrateOfficialSnapshotIfNeeded(current), isNull);
    });
  });

  group('migrateOfficialApiBaseUrlIfNeeded', () {
    test("does not rewrite upstream's api base urls", () {
      for (final String url in <String>[
        'https://api.fluxer.app/v1',
        'https://api.canary.fluxer.app/v1',
        'https://fluxer.com/api/v1',
      ]) {
        expect(
          migrator.migrateOfficialApiBaseUrlIfNeeded(url),
          isNull,
          reason: url,
        );
      }
    });

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
    test("does not map upstream's domains to the default instance", () {
      for (final String domain in <String>['fluxer.app', 'fluxer.com']) {
        expect(
          migrator.migrateOfficialRecentDomainIfNeeded(domain),
          isNull,
          reason: domain,
        );
      }
    });

    test('ignores self-hosted domains', () {
      expect(
        migrator.migrateOfficialRecentDomainIfNeeded('chat.example.com'),
        isNull,
      );
    });
  });
}
