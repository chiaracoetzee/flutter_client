import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/instance/instance_config_snapshot.dart';
import 'package:fluxer_app/features/auth/data/auth_repository.dart';
import 'package:fluxer_app/features/auth/data/auth_token_storage.dart';
import 'package:fluxer_dart/export.dart';

import '../../../helpers/open_test_database.dart';

void main() {
  group('AuthRepository.logout (fork)', () {
    late FluxerDatabase db;
    late AuthRepository repository;

    setUp(() {
      db = openTestDatabase();
      repository = AuthRepository(
        FluxerClient(
          Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'))
            ..httpClientAdapter = const _OfflineAdapter(),
        ),
        db,
        MapAuthTokenStorage(),
        readInstanceSnapshot: InstanceConfigSnapshot.officialDefault,
      );
    });

    Future<void> saveRegistration(String userId) {
      return db.mobilePushRegistrationDao.upsert(
        userId: userId,
        pushSubscriptionId: 'subscription-$userId',
        endpointUrl: 'https://push.example/$userId',
        encryptionKey: '',
        authSecret: '',
        vapidPublicKey: 'vapid',
      );
    }

    test('forgets the push registration of the signed-out user', () async {
      await saveRegistration('1');

      await repository.logout('1');

      expect(await db.mobilePushRegistrationDao.getForUser('1'), isNull);
    });

    test('keeps other accounts and the cached VAPID key', () async {
      await saveRegistration('1');
      await saveRegistration('2');
      await db.mobilePushRegistrationDao.saveVapidForInstance(
        instanceId: 'instance.test',
        vapidPublicKey: 'vapid',
      );

      await repository.logout('1');

      expect(
        (await db.mobilePushRegistrationDao.getForUser(
          '2',
        ))?.pushSubscriptionId,
        'subscription-2',
      );
      expect(
        await db.mobilePushRegistrationDao.getVapidForInstance('instance.test'),
        'vapid',
      );
    });
  });
}

/// Fails every request, as on a device without a network.
class _OfflineAdapter implements HttpClientAdapter {
  const _OfflineAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
    );
  }

  @override
  void close({bool force = false}) {}
}
