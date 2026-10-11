import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/chat/domain/cloud_composer_attachments.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/chat/providers/upload/cloud_upload_controller.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_bar_providers.dart';

// The places outside the signal bar that tell it who the account is acting as
// in a channel. Each one is something the person did in that channel; see
// [ChannelSignalsNotifier.affirmPersona] for why nothing else may.

/// `ref.read` of a widget or of a notifier.
typedef SignalProviderReader = T Function<T>(ProviderListenable<T> provider);

/// The account's lit signals in [channelId] now name [persona], or the
/// account itself when it is null.
void affirmSignalPersona(
  SignalProviderReader read,
  String channelId,
  Persona? persona,
) {
  _affirm(
    read,
    channelId,
    persona == null
        ? null
        : SignalPersona(
            id: persona.id,
            name: persona.name,
            avatar: persona.avatarHash,
          ),
  );
}

/// As [affirmSignalPersona], for callers that hold the persona as the payload
/// they send with a message or a typing notice.
void affirmSignalPersonaData(
  SignalProviderReader read,
  String channelId,
  Map<String, dynamic>? personaData,
) {
  final Object? id = personaData?['id'];
  final Object? name = personaData?['name'];
  final Object? avatar = personaData?['avatar'];
  _affirm(
    read,
    channelId,
    id is String && name is String
        ? SignalPersona(
            id: id,
            name: name,
            avatar: avatar is String ? avatar : null,
          )
        : null,
  );
}

void _affirm(
  SignalProviderReader read,
  String channelId,
  SignalPersona? persona,
) {
  if (channelId.isEmpty) {
    return;
  }
  final String? userId = read(currentUserIdProvider);
  if (userId == null) {
    return;
  }
  read(
    channelSignalsProvider.notifier,
  ).affirmPersona(channelId, userId: userId, persona: persona);
}

/// Who the composer of [channelId] is writing as right now: the persona its
/// text is tagged for, or else the one in [latchedPersonaId].
Persona? composerSignalPersona(
  SignalProviderReader read,
  String channelId, {
  required String? latchedPersonaId,
}) {
  final List<Persona> personas =
      read(myPersonasProvider).asData?.value ?? const <Persona>[];
  if (personas.isEmpty) {
    return null;
  }
  final String text = read(chatViewModelProvider).messageText;
  final bool hasAttachments = read(
    cloudUploadControllerProvider(channelId).select(
      (CloudComposerAttachments attachments) => attachments.items.isNotEmpty,
    ),
  );
  return previewPersona(
    text,
    personas,
    latchedPersonaId,
    hasAttachments,
  ).persona;
}

/// The persona latched for the composer, if any.
String? latchedSignalPersonaId(SignalProviderReader read) {
  final ActivePersonaState active = read(activePersonaProvider);
  return active.isLatched ? active.activePersonaId : null;
}
