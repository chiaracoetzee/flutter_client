// Personas in message search (tyne#46).
//
// `from:` and `mentions:` accept a persona as well as an account. An account
// keeps matching all of its messages and mentions, whichever persona they were
// sent as or name; a persona narrows to that persona.
//
// Search on this client keeps the people it filters on as lists of ids (search
// tokens, the header field's hints, search history, the parsed query). A
// persona travels through those lists as `persona:<id>`, and only the request
// sent to the server splits them into its account and persona fields.

import 'package:dio/dio.dart';
import 'package:fluxer_app/core/media/fluxer_media_url.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';

const String kPersonaSearchIdPrefix = 'persona:';

/// At most this many personas follow the accounts suggested for a filter.
const int kPersonaSearchSuggestionLimit = 8;

String personaSearchId(String personaId) => '$kPersonaSearchIdPrefix$personaId';

bool isPersonaSearchId(String? id) =>
    id != null && id.startsWith(kPersonaSearchIdPrefix);

/// The account ids of a list that may also hold personas.
List<String> accountSearchIds(List<String> ids) => <String>[
  for (final String id in ids)
    if (!isPersonaSearchId(id)) id,
];

/// The persona ids (without the prefix) of a list that may also hold accounts.
List<String> personaSearchIds(List<String> ids) => <String>[
  for (final String id in ids)
    if (isPersonaSearchId(id)) id.substring(kPersonaSearchIdPrefix.length),
];

/// The persona a name typed without picking it stands for: the one known
/// persona with that name (any case), or null when there is none or more than
/// one. The parser asks this only after no account matched the name.
String? resolvePersonaSearchName(
  String name, {
  Iterable<Map<String, dynamic>>? known,
}) {
  final String wanted = name.trim().toLowerCase();
  if (wanted.isEmpty) {
    return null;
  }
  final Set<String> ids = <String>{
    for (final Map<String, dynamic> item
        in known ?? ChannelPersonaMentionCache.instance.cachedItems)
      if ((item['name'] as String? ?? '').trim().toLowerCase() == wanted)
        ?item['id'] as String?,
  };
  return ids.length == 1 ? personaSearchId(ids.single) : null;
}

/// A persona as the search suggestions show it.
class PersonaSearchSuggestion {
  const PersonaSearchSuggestion({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.ownerTag,
    this.avatarUrl,
    this.avatarColor,
  });

  /// Reads one item of `GET /channels/{id}/persona-mentions`.
  static PersonaSearchSuggestion? fromItem(Map<String, dynamic> item) {
    final String? id = item['id'] as String?;
    final String? ownerUserId = item['owner_user_id'] as String?;
    final String name = (item['name'] as String? ?? '').trim();
    if (id == null || id.isEmpty || ownerUserId == null || name.isEmpty) {
      return null;
    }
    final String owner = item['owner_username'] as String? ?? '';
    final String? discriminator = item['owner_discriminator'] as String?;
    final bool showDiscriminator =
        discriminator != null &&
        discriminator.isNotEmpty &&
        int.tryParse(discriminator) != 0;
    final String? avatar = item['avatar_hash'] as String?;
    return PersonaSearchSuggestion(
      id: id,
      name: name,
      ownerUserId: ownerUserId,
      ownerTag: showDiscriminator ? '$owner#$discriminator' : owner,
      avatarUrl: avatar == null || avatar.isEmpty
          ? null
          : avatar.startsWith('http://') ||
                avatar.startsWith('https://') ||
                avatar.startsWith('data:')
          ? avatar
          : FluxerMediaUrl.userAvatar(userId: ownerUserId, hash: avatar),
      avatarColor:
          (item['avatar_color'] as num?)?.toInt() ??
          (item['color'] as num?)?.toInt(),
    );
  }

  final String id;
  final String name;
  final String ownerUserId;
  final String ownerTag;
  final String? avatarUrl;
  final int? avatarColor;

  /// How the persona is carried in the search's lists of ids.
  String get searchId => personaSearchId(id);
}

/// The personas to suggest for [query] in a channel: the same ones the
/// composer suggests for an @-mention there (every persona of the user's own,
/// and the public and unlisted personas of the channel's other members).
Future<List<PersonaSearchSuggestion>> fetchPersonaSearchSuggestions({
  required Dio dio,
  required String channelId,
  required String? guildId,
  required String query,
  int limit = kPersonaSearchSuggestionLimit,
}) async {
  if (query.trim().isEmpty) {
    return const <PersonaSearchSuggestion>[];
  }
  final List<Map<String, dynamic>> items = await ChannelPersonaMentionCache
      .instance
      .getChannelPersonas(
        dio: dio,
        channelId: channelId,
        guildId: guildId,
        query: query.trim(),
      );
  return <PersonaSearchSuggestion>[
    for (final Map<String, dynamic> item in items)
      ?PersonaSearchSuggestion.fromItem(item),
  ].take(limit).toList();
}
