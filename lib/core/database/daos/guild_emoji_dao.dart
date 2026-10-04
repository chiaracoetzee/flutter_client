import 'package:drift/drift.dart';
import 'package:fluxer_app/core/database/drift_stream_utils.dart';

import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/database/tables/guild_emojis.dart';

part 'guild_emoji_dao.g.dart';

@DriftAccessor(tables: [GuildEmojis])
class GuildEmojiDao extends DatabaseAccessor<FluxerDatabase>
    with _$GuildEmojiDaoMixin {
  GuildEmojiDao(super.attachedDatabase);

  Stream<List<GuildEmoji>> watchByGuild(String guildId) =>
      (select(guildEmojis)
            ..where((e) => e.guildId.equals(guildId))
            ..orderBy([
              (e) => OrderingTerm(
                expression: e.name.collate(Collate.noCase),
              ),
              (e) => OrderingTerm(
                expression: e.id,
              ),
            ]))
          .watch()
          .suppressDriftCancellation;

  Stream<List<GuildEmoji>> watchAll() =>
      (select(guildEmojis)..orderBy([
            (e) => OrderingTerm(
              expression: e.name.collate(Collate.noCase),
            ),
            (e) => OrderingTerm(
              expression: e.id,
            ),
          ]))
          .watch()
          .suppressDriftCancellation;

  Future<GuildEmoji?> getById(String id) =>
      (select(guildEmojis)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> replaceForGuild(
    String guildId,
    List<GuildEmojisCompanion> emojis,
  ) async {
    await (delete(guildEmojis)..where((e) => e.guildId.equals(guildId))).go();
    await batch((b) {
      for (final emoji in emojis) {
        b.insert(guildEmojis, emoji);
      }
    });
  }

  Future<void> clearAll() => delete(guildEmojis).go();
}
