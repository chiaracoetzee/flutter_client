import 'dart:convert';

import 'package:fluxer_dart/gateway.dart';

List<Map<String, dynamic>> decodeMessageReactionsJson(String json) {
  try {
    return (jsonDecode(json) as List<dynamic>).cast<Map<String, dynamic>>();
  } on Object {
    return <Map<String, dynamic>>[];
  }
}

bool applyMessageReactionDelta(
  List<Map<String, dynamic>> reactions,
  ReactionEmoji emoji, {
  required bool isAdd,
  required bool isCurrentUser,
  String? personaId,
}) {
  final int idx = reactions.indexWhere(
    (Map<String, dynamic> reaction) =>
        (reaction['emoji'] as String?) == emoji.name &&
        (reaction['emojiId'] as String?) == emoji.id,
  );
  if (isAdd) {
    if (idx != -1) {
      final Map<String, dynamic> existing = reactions[idx];
      final List<String> personaReactions = List<String>.from(
        (existing['personaReactions'] as List<dynamic>?) ??
            (existing['persona_reactions'] as List<dynamic>?) ??
            const <String>[],
      );
      final bool hasReacted = (existing['hasReacted'] as bool?) ??
          (existing['me'] as bool?) ??
          false;
      bool meRoot = (existing['meRoot'] as bool?) ??
          (existing['me_root'] as bool?) ??
          false;
      if (hasReacted && personaReactions.isEmpty) {
        meRoot = true;
      }

      final bool isRoot = personaId == null || personaId == '0';
      if (isCurrentUser) {
        if (isRoot) {
          if (meRoot) return false;
          meRoot = true;
        } else {
          if (personaReactions.contains(personaId)) return false;
          personaReactions.add(personaId);
        }
      }

      existing['count'] = ((existing['count'] as int?) ?? 0) + 1;
      if (isCurrentUser) {
        existing['meRoot'] = meRoot;
        existing['personaReactions'] = personaReactions;
        existing['hasReacted'] = true;
        existing['me'] = true;
      }
    } else {
      final bool isRoot = personaId == null || personaId == '0';
      final List<String> personaReactions =
          isCurrentUser && !isRoot ? [personaId] : [];
      final bool meRoot = isCurrentUser && isRoot;
      reactions.add(<String, dynamic>{
        'emoji': emoji.name,
        'emojiId': emoji.id,
        'animated': emoji.animated,
        'count': 1,
        'hasReacted': isCurrentUser,
        'me': isCurrentUser,
        'meRoot': meRoot,
        'personaReactions': personaReactions,
      });
    }
  } else if (idx != -1) {
    final Map<String, dynamic> existing = reactions[idx];
    final List<String> personaReactions = List<String>.from(
      (existing['personaReactions'] as List<dynamic>?) ??
          (existing['persona_reactions'] as List<dynamic>?) ??
          const <String>[],
    );
    final bool hasReacted = (existing['hasReacted'] as bool?) ??
        (existing['me'] as bool?) ??
        false;
    bool meRoot = (existing['meRoot'] as bool?) ??
        (existing['me_root'] as bool?) ??
        false;
    if (hasReacted && personaReactions.isEmpty) {
      meRoot = true;
    }

    final bool isRoot = personaId == null || personaId == '0';
    if (isCurrentUser) {
      if (isRoot) {
        if (!meRoot) {
          return false;
        }
        meRoot = false;
      } else {
        if (!personaReactions.contains(personaId)) return false;
        personaReactions.remove(personaId);
      }
    }

    final int count = ((existing['count'] as int?) ?? 1) - 1;
    if (count <= 0) {
      reactions.removeAt(idx);
    } else {
      existing['count'] = count;
      if (isCurrentUser) {
        final bool stillReacted = meRoot || personaReactions.isNotEmpty;
        existing['meRoot'] = meRoot;
        existing['personaReactions'] = personaReactions;
        existing['hasReacted'] = stillReacted;
        existing['me'] = stillReacted;
      }
    }
  } else {
    return false;
  }
  return true;
}
