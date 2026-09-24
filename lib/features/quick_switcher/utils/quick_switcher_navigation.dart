import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/providers/instance_runtime_config_provider.dart';
import 'package:fluxer_app/core/router/navigate_to_content.dart';
import 'package:fluxer_app/core/router/route_names.dart';
import 'package:fluxer_app/features/channels/utils/navigate_to_channel_content.dart';
import 'package:fluxer_app/features/dm/providers/dm_providers.dart';
import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_types.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:go_router/go_router.dart';

String settingsTargetPath(QuickSwitcherSettingsTarget target) =>
    switch (target) {
      QuickSwitcherSettingsTarget.userSettings => RoutePaths.youPath,
      QuickSwitcherSettingsTarget.notifications => RoutePaths.notificationsPath,
      QuickSwitcherSettingsTarget.bookmarks => RoutePaths.bookmarksPath,
      QuickSwitcherSettingsTarget.mentions => RoutePaths.mentionsPath,
    };

String virtualGuildPath(QuickSwitcherVirtualGuildType type) => switch (type) {
  QuickSwitcherVirtualGuildType.home => RoutePaths.me,
  QuickSwitcherVirtualGuildType.favorites => RoutePaths.favoritesBase,
};

Future<void> navigateToDmChannelFromQuickSwitcher({
  required BuildContext context,
  required WidgetRef ref,
  required String channelId,
}) async {
  await navigateToDmChannelContent(
    context: context,
    ref: ref,
    channelId: channelId,
  );
}

Future<void> openDmWithUserFromQuickSwitcher({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  required VoidCallback onClose,
  String? dmChannelId,
}) async {
  if (ref.read(instanceRuntimeConfigProvider).directMessagesDisabled) {
    return;
  }
  String? resolvedChannelId = dmChannelId;
  if (resolvedChannelId == null || resolvedChannelId.isEmpty) {
    resolvedChannelId = await ref
        .read(dmRepositoryProvider)
        .ensureDmChannel(userId);
  }
  if (!context.mounted) {
    return;
  }
  onClose();
  if (!context.mounted) {
    return;
  }
  await navigateToDmChannelFromQuickSwitcher(
    context: context,
    ref: ref,
    channelId: resolvedChannelId,
  );
}

Future<void> executeQuickSwitcherResult({
  required BuildContext context,
  required WidgetRef ref,
  required QuickSwitcherResult result,
  required VoidCallback onClose,
}) async {
  switch (result) {
    case QuickSwitcherUserResult(:final userId, :final dmChannelId):
      await openDmWithUserFromQuickSwitcher(
        context: context,
        ref: ref,
        userId: userId,
        onClose: onClose,
        dmChannelId: dmChannelId,
      );
      return;
    default:
      break;
  }
  onClose();
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case QuickSwitcherUserResult():
      break;
    case QuickSwitcherGroupDmResult(:final channelId):
      await navigateToDmChannelFromQuickSwitcher(
        context: context,
        ref: ref,
        channelId: channelId,
      );
    case QuickSwitcherTextChannelResult(:final channelId, :final guildId):
      await navigateToChannelContent(
        context: context,
        ref: ref,
        channelId: channelId,
        guildId: guildId,
      );
    case QuickSwitcherVoiceChannelResult(:final channelId, :final guildId):
      await navigateToChannelContent(
        context: context,
        ref: ref,
        channelId: channelId,
        guildId: guildId,
      );
    case QuickSwitcherGuildResult(:final guild):
      context.go('/channels/${guild.id}');
    case QuickSwitcherVirtualGuildResult(:final virtualGuildType):
      context.go(virtualGuildPath(virtualGuildType));
    case QuickSwitcherSettingsResult(:final target):
      context.go(settingsTargetPath(target));
    case QuickSwitcherLinkResult(:final path):
      navigateToContent(context, path);
    case QuickSwitcherHeaderResult():
      break;
  }
}
