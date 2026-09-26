// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/features/chat/domain/cloud_composer_attachments.dart';
import 'package:fluxer_app/features/chat/providers/upload/cloud_upload_controller.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';

class OutgoingMessageResolution {
  const OutgoingMessageResolution({
    required this.text,
    required this.personaData,
    this.persona,
    this.wasEscaped = false,
    this.clearedLatch = false,
    this.matched = false,
  });

  final String text;
  final Map<String, dynamic>? personaData;
  final Persona? persona;
  final bool wasEscaped;
  final bool clearedLatch;
  final bool matched;
}

Future<OutgoingMessageResolution> resolveOutgoingPersona({
  required WidgetRef ref,
  required String rawText,
  required String channelId,
  bool allowEmptyContent = false,
}) async {
  final personas = ref.read(myPersonasProvider).asData?.value ?? const [];
  final activeState = ref.read(activePersonaProvider);
  final bool hasPendingAttachments = channelId.isNotEmpty &&
      ref.read(
        cloudUploadControllerProvider(channelId).select(
          (CloudComposerAttachments a) => a.items.isNotEmpty,
        ),
      );

  final String? latchedId =
      activeState.isLatched ? activeState.activePersonaId : null;
  final MatchResult matchResult = matchPersona(
    rawText,
    personas,
    latchedId,
    hasPendingAttachments,
    allowEmptyContent: allowEmptyContent,
  );

  if (matchResult.clearedLatch ||
      (matchResult.wasEscaped && activeState.mode == PersonaMode.last)) {
    await ref.read(activePersonaProvider.notifier).unlatch();
  } else if (matchResult.matched && matchResult.persona != null) {
    unawaited(
      ref.read(activePersonaProvider.notifier).recordUsage(matchResult.persona!.id),
    );
    if (activeState.mode == PersonaMode.last &&
        activeState.activePersonaId != matchResult.persona!.id) {
      await ref.read(activePersonaProvider.notifier).setActivePersona(
            matchResult.persona!.id,
            mode: PersonaMode.last,
          );
    }
  }

  final String finalOutgoingText =
      matchResult.matched || matchResult.wasEscaped
          ? matchResult.strippedContent
          : rawText;

  Map<String, dynamic>? personaData;
  if (matchResult.matched && matchResult.persona != null) {
    final systemTag = ref.read(systemDisplayTagProvider);
    personaData = matchResult.persona!.toSubprofilePayload(
      displayTagText: systemTag.text,
      displayTagIcon: systemTag.iconUrl,
    );
  }

  return OutgoingMessageResolution(
    text: finalOutgoingText,
    personaData: personaData,
    persona: matchResult.persona,
    wasEscaped: matchResult.wasEscaped,
    clearedLatch: matchResult.clearedLatch,
    matched: matchResult.matched,
  );
}
