// Fork: tests the fork adds, kept out of upstream's auth_repository_test.dart so that file stays as
// upstream has it.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/instance/instance_config_snapshot.dart';
import 'package:fluxer_app/features/auth/data/auth_repository.dart';
import 'package:fluxer_app/features/auth/data/auth_token_storage.dart';
import 'package:fluxer_dart/export.dart';

import '../../../helpers/open_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository', () {
    late FluxerDatabase db;
    late MapAuthTokenStorage tokenStorage;
    late AuthRepository repository;

    setUp(() {
      db = openTestDatabase();
      tokenStorage = MapAuthTokenStorage();
      repository = AuthRepository(
        FluxerClient(Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))),
        db,
        tokenStorage,
        readInstanceSnapshot: InstanceConfigSnapshot.officialDefault,
      );
    });

    test(
      'migrateLegacyInstanceEndpoints leaves a stored upstream Fluxer account on its own endpoints',
      () async {
        const InstanceConfigSnapshot legacy = InstanceConfigSnapshot(
          apiBaseUrl: 'https://api.fluxer.app/v1',
          gatewayUrl: 'wss://gateway.fluxer.app',
          displayDomain: 'fluxer.app',
        );
        await db.authSessionDao.saveSessionMetadata(
          userId: 'user-1',
          instanceSnapshotJson: legacy.toJson(),
        );
        await tokenStorage.saveToken(userId: 'user-1', token: 'token-1');
        await tokenStorage.saveApiBaseUrl(
          userId: 'user-1',
          apiBaseUrl: 'https://api.fluxer.app/v1',
        );

        await repository.migrateLegacyInstanceEndpoints();

        final InstanceConfigSnapshot restored = await repository
            .resolveInstanceSnapshotForUser('user-1');
        // Rewriting these to this build's instance would send the account's
        // Fluxer token to a different server.
        expect(restored.apiBaseUrl, 'https://api.fluxer.app/v1');
        expect(restored.gatewayUrl, 'wss://gateway.fluxer.app');
        expect(restored.displayDomain, 'fluxer.app');
        expect(
          await tokenStorage.readApiBaseUrl('user-1'),
          'https://api.fluxer.app/v1',
        );
      },
    );
  });
}
