// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_dart/export.dart';

/// Fork: writes and reads the personas this device knows (`known_personas`),
/// as upstream writes the users a message names into `users` wherever a
/// message arrives (upsertMentionUsersFromSdk) and reads them to show
/// mentions.

KnownPersonasCompanion _companion({
  required String id,
  required String name,
  String? avatar,
  int? avatarColor,
  int? color,
  String? displayTagText,
  String? displayTagIcon,
}) => KnownPersonasCompanion.insert(
  id: id,
  name: name,
  avatar: Value(avatar),
  avatarColor: Value(avatarColor),
  color: Value(color),
  displayTagText: Value(displayTagText),
  displayTagIcon: Value(displayTagIcon),
);

KnownPersonasCompanion? _fromSubprofile(MessageSubprofileResponseSchema? p) {
  if (p == null || p.id.isEmpty || p.name.isEmpty) {
    return null;
  }
  return _companion(
    id: p.id,
    name: p.name,
    avatar: p.avatar,
    avatarColor: p.avatarColor,
    color: p.color,
    displayTagText: p.displayTagText,
    displayTagIcon: p.displayTagIcon,
  );
}

KnownPersonasCompanion? _fromJson(Object? json) {
  if (json is! Map) {
    return null;
  }
  final Object? id = json['id'];
  final Object? name = json['name'];
  if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
    return null;
  }
  // Only what the payload carries is written, as upstream's user upserts do,
  // so a gateway event without the tag keeps the stored one.
  Value<T?> carried<T>(List<String> keys, T? Function(Object?) read) {
    for (final String key in keys) {
      if (json.containsKey(key)) {
        return Value<T?>(read(json[key]));
      }
    }
    return const Value.absent();
  }

  return KnownPersonasCompanion(
    id: Value(id),
    name: Value(name),
    avatar: carried(<String>['avatar', 'avatar_hash'], (v) => v as String?),
    avatarColor: carried(<String>['avatar_color'], (v) => (v as num?)?.toInt()),
    color: carried(<String>['color'], (v) => (v as num?)?.toInt()),
    displayTagText: carried(<String>['display_tag_text'], (v) => v as String?),
    displayTagIcon: carried(<String>['display_tag_icon'], (v) => v as String?),
  );
}

Future<void> _upsertAll(
  FluxerDatabase database,
  Iterable<KnownPersonasCompanion?> rows,
) async {
  final Map<String, KnownPersonasCompanion> byId =
      <String, KnownPersonasCompanion>{
        for (final KnownPersonasCompanion row
            in rows.whereType<KnownPersonasCompanion>())
          row.id.value: row,
      };
  if (byId.isEmpty) {
    return;
  }
  await database.batch((Batch batch) {
    batch.insertAllOnConflictUpdate(database.knownPersonas, byId.values);
  });
}

/// The persona each message was sent as and the personas it mentions.
Future<void> upsertKnownPersonasFromSdk(
  FluxerDatabase database,
  Iterable<MessageResponseSchema> messages,
) => _upsertAll(database, <KnownPersonasCompanion?>[
  for (final MessageResponseSchema message in messages) ...[
    _fromSubprofile(message.subprofile),
    for (final MessageSubprofileResponseSchema persona
        in message.mentionPersonas ?? const <MessageSubprofileResponseSchema>[])
      _fromSubprofile(persona),
  ],
]);

/// The same for a message read as JSON.
Future<void> upsertKnownPersonasFromJson(
  FluxerDatabase database,
  Map<String, dynamic> message,
) => _upsertAll(database, <KnownPersonasCompanion?>[
  _fromJson(message['subprofile']),
  for (final Object? persona
      in message['mention_personas'] as List<dynamic>? ?? const <dynamic>[])
    _fromJson(persona),
]);

/// A persona as a gateway event sends it.
Future<void> upsertKnownPersonaFromJson(
  FluxerDatabase database,
  Object? persona,
) => _upsertAll(database, <KnownPersonasCompanion?>[_fromJson(persona)]);

/// A persona's profile card. The card carries no display tag, so a stored tag
/// is kept.
KnownPersonasCompanion? _fromProfileCard({
  required String id,
  required String name,
  String? avatar,
  int? avatarColor,
  int? color,
}) => id.isEmpty || name.isEmpty
    ? null
    : KnownPersonasCompanion(
        id: Value(id),
        name: Value(name),
        avatar: Value(avatar),
        avatarColor: Value(avatarColor),
        color: Value(color),
      );

/// A persona looked up through its public profile.
Future<void> upsertKnownPersonaFromPublic(
  FluxerDatabase database,
  PublicPersona persona,
) => _upsertAll(database, <KnownPersonasCompanion?>[
  _fromProfileCard(
    id: persona.id,
    name: persona.name,
    avatar: persona.avatarHash,
    avatarColor: persona.avatarColor,
    color: persona.color,
  ),
]);

/// What this device knows about a persona, kept current as rows change.
// The family type is long and says nothing the next line does not.
// ignore: specify_nonobvious_property_types
final knownPersonaProvider = StreamProvider.autoDispose
    .family<KnownPersona?, String>((ref, String personaId) {
      final FluxerDatabase database = ref.watch(fluxerDatabaseProvider);
      return (database.select(
        database.knownPersonas,
      )..where((t) => t.id.equals(personaId))).watchSingleOrNull();
    });
