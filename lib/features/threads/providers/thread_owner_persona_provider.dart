// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';

/// Fork: the ID of the persona a thread or forum post was started as, or null
/// when it was started as the account.
///
/// The server sends it on the thread as `owner_persona_id`. It is kept in the
/// fork's own column of the channels table and read here, so upstream's
/// `Channel` model is not involved.
// The family type is long and says nothing the next line does not.
// ignore: specify_nonobvious_property_types
final threadOwnerPersonaIdProvider = StreamProvider.autoDispose
    .family<String?, String>((ref, String threadId) {
      final FluxerDatabase db = ref.watch(fluxerDatabaseProvider);
      return db
          .customSelect(
            'SELECT owner_persona_id FROM channels WHERE id = ?',
            variables: <Variable<Object>>[Variable<String>(threadId)],
            readsFrom: <ResultSetImplementation<dynamic, dynamic>>{db.channels},
          )
          .watchSingleOrNull()
          .map(
            (QueryRow? row) => row?.readNullable<String>('owner_persona_id'),
          );
    });

/// Fork: the name of the persona a thread or forum post was started as. Null
/// when it was started as the account, and when the persona cannot be named,
/// so callers fall back to the account's name.
///
/// A thread carries only the persona's ID. The name comes from what this
/// device already knows: the user's own personas, then any stored message the
/// owner sent as that persona (which is how a private persona gets its name),
/// and failing that one lookup.
// ignore: specify_nonobvious_property_types
final threadOwnerPersonaNameProvider = FutureProvider.autoDispose
    .family<String?, ({String threadId, String ownerId})>((ref, arg) async {
      final String? personaId = await ref.watch(
        threadOwnerPersonaIdProvider(arg.threadId).future,
      );
      if (personaId == null || personaId.isEmpty) {
        return null;
      }
      final List<Persona> own =
          ref.watch(myPersonasProvider).asData?.value ?? const <Persona>[];
      for (final Persona persona in own) {
        if (persona.id == personaId) {
          return persona.name;
        }
      }
      final FluxerDatabase db = ref.watch(fluxerDatabaseProvider);
      final QueryRow? sent = await db
          .customSelect(
            'SELECT persona_name FROM messages '
            'WHERE author_id = ? AND persona_id = ? '
            "AND persona_name IS NOT NULL AND persona_name != '' LIMIT 1",
            variables: <Variable<Object>>[
              Variable<String>(arg.ownerId),
              Variable<String>(personaId),
            ],
          )
          .getSingleOrNull();
      final String? sentName = sent?.readNullable<String>('persona_name');
      if (sentName != null) {
        return sentName;
      }
      final PublicPersona? looked = await ref.watch(
        publicPersonaProvider((
          userId: arg.ownerId,
          personaId: personaId,
        )).future,
      );
      final String name = looked?.name ?? '';
      return name.isEmpty ? null : name;
    });
