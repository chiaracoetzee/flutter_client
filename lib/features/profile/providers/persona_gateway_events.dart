// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';

/// Fork: what the app does with the persona gateway events: the account's own
/// persona list and settings, the persona it selected in a channel from
/// another session, and a community member's personas changing.
/// [sessionUserId] is the account the gateway session belongs to.
void handlePersonaGatewayEvent(
  Ref ref,
  String eventType,
  dynamic data, {
  String? sessionUserId,
}) {
  talker.info('[Gateway] Received $eventType');
  final String? guildId = (data is Map && data['guild_id'] != null)
      ? data['guild_id'].toString()
      : null;
  ChannelPersonaMentionCache.instance.invalidate(guildId);

  if (eventType == 'GUILD_PERSONAS_DIRTY') {
    if (data is Map) {
      final persona = data['persona'];
      final action = data['action']?.toString() ?? 'sync';
      final userId = data['user_id']?.toString();
      final personaId =
          (persona is Map ? persona['id'] : data['persona_id'] ?? data['id'])
              ?.toString();

      if (personaId != null && personaId.isNotEmpty) {
        if (userId != null && userId.isNotEmpty) {
          ref.invalidate(
            publicPersonaProvider((userId: userId, personaId: personaId)),
          );
        }

        // A deleted persona keeps showing on its messages as it was (the server
        // keeps it as a tombstone), so only an edit renames them.
        if (action != 'delete' && persona is Map) {
          final String? name = persona['name']?.toString();
          final String? avatar = (persona['avatar_hash'] ?? persona['avatar'])
              ?.toString();
          final String? tag = persona['display_tag_text']?.toString();
          final String? tagIcon = persona['display_tag_icon']?.toString();

          ref
              .read(chatViewModelProvider.notifier)
              .onPersonaUpdated(
                personaId: personaId,
                name: name,
                avatar: avatar,
                tag: tag,
                tagIcon: tagIcon,
              );
        }
      }
    }
    return;
  }

  if (eventType == 'USER_PERSONA_CHANNEL_STATE_UPDATE') {
    // Another session of this account selected a persona in a channel,
    // or the server cleared one.
    if (data is Map) {
      final Object? channelId = data['channel_id'];
      final Object? personaId = data['persona_id'];
      if (channelId is String) {
        ref
            .read(activePersonaProvider.notifier)
            .applyChannelState(
              channelId,
              personaId is String ? personaId : null,
            );
      }
    }
    return;
  }

  if (eventType == 'USER_PERSONA_SETTINGS_UPDATE') {
    final Map<String, dynamic> payload = data is Map<String, dynamic>
        ? data
        : (data is Map
              ? Map<String, dynamic>.from(data)
              : const <String, dynamic>{});
    ref.read(personaSettingsProvider.notifier).updateFromGateway(payload);
    final String? uid =
        (payload['user_id'] ??
                ref.read(currentUserIdProvider) ??
                sessionUserId ??
                ref.read(userSettingsViewModelProvider).userId)
            ?.toString();
    if (uid != null && uid.isNotEmpty) {
      final String? tag = payload['display_tag_text']?.toString();
      final String? tagIcon = payload['display_tag_icon']?.toString();
      ref
          .read(chatViewModelProvider.notifier)
          .onAuthorDisplayTagUpdated(authorId: uid, tag: tag, tagIcon: tagIcon);
    }
    return;
  }
  unawaited(ref.read(myPersonasProvider.notifier).reloadSilently());
  if (data is Map) {
    final persona = data['persona'];
    final id =
        data['persona_id'] ?? (persona is Map ? persona['id'] : data['id']);
    final currentUid =
        ref.read(currentUserIdProvider) ??
        sessionUserId ??
        ref.read(userSettingsViewModelProvider).userId;
    final ownerId =
        (persona is Map &&
            persona['user_id'] != null &&
            persona['user_id'].toString().isNotEmpty)
        ? persona['user_id'].toString()
        : currentUid;

    if (id is String && id.isNotEmpty) {
      if (ownerId.isNotEmpty) {
        ref.invalidate(publicPersonaProvider((userId: ownerId, personaId: id)));
      }
      if (currentUid.isNotEmpty && currentUid != ownerId) {
        ref.invalidate(
          publicPersonaProvider((userId: currentUid, personaId: id)),
        );
      }

      if (eventType == 'USER_PERSONA_DELETE') {
        // Gone from the account's own list; its messages keep showing it as
        // it was.
        ref.read(myPersonasProvider.notifier).removePersona(id);
      }
    }

    if (persona is Map) {
      try {
        final map = persona is Map<String, dynamic>
            ? persona
            : Map<String, dynamic>.from(persona);
        final p = Persona.fromJson(map);
        ref.read(myPersonasProvider.notifier).upsertPersona(p);

        final userPersonaSettings = ref
            .read(personaSettingsProvider)
            .asData
            ?.value;
        ref
            .read(chatViewModelProvider.notifier)
            .onPersonaUpdated(
              personaId: p.id,
              name: p.name,
              avatar: p.avatarHash,
              tag: userPersonaSettings?.displayTagText,
              tagIcon: userPersonaSettings?.displayTagIcon,
            );
      } on Object catch (e, st) {
        talker.warning(
          '[Gateway] Failed to parse persona from gateway: $e',
          e,
          st,
        );
      }
    }
  }
}
