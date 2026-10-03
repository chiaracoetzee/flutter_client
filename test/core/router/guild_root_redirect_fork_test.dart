// Fork: tests the fork adds, kept out of upstream's guild_root_redirect_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/router/guild_root_redirect.dart';
import 'package:fluxer_app/core/router/route_names.dart';

import '../../helpers/open_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FluxerDatabase db;

  setUp(() {
    db = openTestDatabase();
  });

  group('resolveDmRootRedirect', () {
    Future<void> addDm(String id) async {
      await db.dmChannelDao.upsertDmChannels([
        DmChannelsCompanion.insert(id: id, recipientId: 'user-$id'),
      ]);
    }

    test('restores the remembered dm', () async {
      await addDm('dm-1');
      await addDm('dm-2');
      await db.guildLastChannelDao.setLastChannel(kDmLastChannelKey, 'dm-2');

      final result = await resolveDmRootRedirect(
        fullPath: RoutePaths.me,
        db: db,
      );

      expect(result, RoutePaths.dmChannel('dm-2'));
    });

    test('skips removed dms and picks latest active dm', () async {
      await addDm('dm-1');
      await db.guildLastChannelDao.setLastChannel(kDmLastChannelKey, 'missing');

      final result = await resolveDmRootRedirect(
        fullPath: RoutePaths.me,
        db: db,
      );

      expect(result, RoutePaths.dmChannel('dm-1'));
    });

    test('returns null when dms are empty', () async {
      final result = await resolveDmRootRedirect(
        fullPath: RoutePaths.me,
        db: db,
      );

      expect(result, isNull);
    });

    test('child route returns null', () async {
      await addDm('dm-1');
      await db.guildLastChannelDao.setLastChannel(kDmLastChannelKey, 'dm-1');

      final result = await resolveDmRootRedirect(
        fullPath: RoutePaths.dmChannel('dm-1'),
        db: db,
      );

      expect(result, isNull);
    });
  });

  group('persistGuildChannelFromLocation', () {
    test('saves dm channel paths', () async {
      persistGuildChannelFromLocation(db, '/channels/@me/dm-1');
      expect(
        await db.guildLastChannelDao.getLastChannel(kDmLastChannelKey),
        'dm-1',
      );
    });

    test('ignores message jumps', () async {
      persistGuildChannelFromLocation(db, '/channels/@me/dm-1/msg-1');
      persistGuildChannelFromLocation(db, '/channels/guild-1/chan-1/msg-1');
      persistGuildChannelFromLocation(db, '/channels/@favorites/fav-1/msg-1');
      expect(await db.guildLastChannelDao.getLastChannel('guild-1'), isNull);
      expect(
        await db.guildLastChannelDao.getLastChannel(kFavoritesLastChannelKey),
        isNull,
      );
      expect(
        await db.guildLastChannelDao.getLastChannel(kDmLastChannelKey),
        isNull,
      );
    });
  });
}
