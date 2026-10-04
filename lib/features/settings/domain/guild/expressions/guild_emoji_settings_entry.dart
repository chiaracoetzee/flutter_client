import 'package:fluxer_app/features/settings/domain/guild/expressions/guild_expression_uploader.dart';
import 'package:fluxer_dart/export.dart';

class GuildEmojiSettingsEntry {
  const GuildEmojiSettingsEntry({
    required this.id,
    required this.name,
    required this.animated,
    required this.uploader,
  });

  final String id;
  final String name;
  final bool animated;
  final GuildExpressionUploader uploader;

  factory GuildEmojiSettingsEntry.fromResponse(
    GuildEmojiWithUserResponse response,
  ) {
    return GuildEmojiSettingsEntry(
      id: response.id,
      name: response.name,
      animated: response.animated,
      uploader: GuildExpressionUploader.fromResponse(response.user),
    );
  }
}

int compareGuildEmojiSettingsEntriesByName(
  GuildEmojiSettingsEntry left,
  GuildEmojiSettingsEntry right,
) {
  final diff = left.name.toLowerCase().compareTo(right.name.toLowerCase());
  if (diff != 0) {
    return diff;
  }
  final exactDiff = left.name.compareTo(right.name);
  if (exactDiff != 0) {
    return exactDiff;
  }
  return left.id.compareTo(right.id);
}
