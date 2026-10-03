// Fork: tests the fork adds, kept out of upstream's app_location_persistence_test.dart so that file stays as
// upstream has it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/router/app_location_persistence.dart';
import 'package:fluxer_app/core/router/guild_root_redirect.dart';
import 'package:fluxer_app/core/router/pre_reconnecting_location_provider.dart';
import 'package:fluxer_app/core/router/route_names.dart';

import '../../helpers/open_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FluxerDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  group('PreReconnectingLocation.takeOrRestore', () {
    test('restores dm channel from last location', () async {
      await db.dmChannelDao.upsertDmChannels([
        DmChannelsCompanion.insert(id: 'dm-1', recipientId: 'user-1'),
      ]);
      persistAppLocation(db, '/channels/@me/dm-1');
      persistGuildChannelFromLocation(db, '/channels/@me/dm-1');
      await Future<void>.delayed(Duration.zero);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container
            .read(preReconnectingLocationProvider.notifier)
            .takeOrRestore(db, currentUserId: null),
        '/channels/@me/dm-1',
      );
    });

    test('redirects channels me root to last dm channel', () async {
      await db.dmChannelDao.upsertDmChannels([
        DmChannelsCompanion.insert(id: 'dm-1', recipientId: 'user-1'),
      ]);
      persistAppLocation(db, RoutePaths.me);
      await db.guildLastChannelDao.setLastChannel(kDmLastChannelKey, 'dm-1');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container
            .read(preReconnectingLocationProvider.notifier)
            .takeOrRestore(db, currentUserId: null),
        '/channels/@me/dm-1',
      );
    });
  });

  group('clearPersistedLocation', () {
    test('clears app location and dm last channel', () async {
      persistAppLocation(db, '/channels/@me/dm-1');
      persistGuildChannelFromLocation(db, '/channels/@me/dm-1');
      await Future<void>.delayed(Duration.zero);

      await clearPersistedLocation(db, '/channels/@me/dm-1');

      expect(await readPersistedAppLocation(db), isNull);
      expect(
        await db.guildLastChannelDao.getLastChannel(kDmLastChannelKey),
        isNull,
      );
    });
  });
}
