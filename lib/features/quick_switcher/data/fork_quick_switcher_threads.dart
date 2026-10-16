// Fork: threads, forum posts and forums in the quick switcher's recent channels.
//
// Upstream's recents only resolve text, voice and announcement channels, so a
// thread or forum post someone just had open never shows up there; it can only
// be found by typing. This builds the same entry search shows for it, with the
// channel or forum it belongs to in the subtitle.

import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/quick_switcher/data/quick_switcher_result_converters.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_candidate.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_types.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/shared/utils/snowflake_time.dart';

/// The recent-channels entry for [channel] if it is a thread, forum post,
/// forum or media channel, and null for every other channel type.
QuickSwitcherResult? forkQuickSwitcherThreadResult(
  Channel channel, {
  required FluxerLocalizations l10n,
  required Map<String, Channel> guildChannelsById,
  required Map<String, Guild> guildsById,
  String? viewContext,
}) {
  if (!isThreadFeatureChannelType(channel.type.wireValue)) {
    return null;
  }
  final String guildName = guildsById[channel.guildId]?.name ?? '';
  final String? parentName = isThreadChannelType(channel.type.wireValue)
      ? guildChannelsById[channel.parentId]?.name
      : null;
  return candidateToQuickSwitcherResult(
    QuickSwitcherChannelCandidate(
      id: channel.id,
      title: channel.name,
      subtitle: parentName == null ? guildName : '$parentName · $guildName',
      channelId: channel.id,
      guildId: channel.guildId,
      isVoice: false,
      channelType: channel.type,
      searchValues: <String>[channel.name, ?parentName, guildName, channel.id],
      sortWeight: dateTimeFromSnowflakeAsLocalOrNow(
        channel.id,
      ).millisecondsSinceEpoch,
    ),
    l10n,
    viewContext: viewContext,
  );
}
