// Persona suggestions for `from:` and `mentions:` in the header search field
// of the wide layout (tyne#46). A personas section follows the accounts
// section. A picked persona is inserted like an account, with its search id
// (`persona:<id>`) as the id the field remembers for its name.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/chat/data/persona_search_ids.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/header/channel_header_search_autocomplete.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/header/channel_header_search_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The personas section of the header field's suggestions: a header, then one
/// entry per persona. Empty when there are no personas.
List<ChannelSearchAutocompleteEntry> personaSuggestionEntries(
  List<PersonaSearchSuggestion> personas, {
  required String title,
}) {
  if (personas.isEmpty) {
    return const <ChannelSearchAutocompleteEntry>[];
  }
  return <ChannelSearchAutocompleteEntry>[
    ChannelSearchAutocompleteEntry(
      section: ChannelSearchAutocompleteSection.users,
      label: title,
      icon: PhosphorIconsBold.magnifyingGlass,
      selectable: false,
      isSectionHeader: true,
    ),
    for (final PersonaSearchSuggestion persona in personas)
      ChannelSearchAutocompleteEntry(
        section: ChannelSearchAutocompleteSection.users,
        label: persona.name,
        subtitle: persona.ownerTag,
        userId: persona.searchId,
        avatarImageUrl: persona.avatarUrl,
        avatarColor: persona.avatarColor,
        value: persona.name,
      ),
  ];
}

mixin ChannelHeaderPersonaSuggestions
    on ConsumerState<ChannelHeaderSearchField> {
  static const Duration _debounce = Duration(milliseconds: 300);

  Timer? _personaDebounce;
  String _personaQuery = '';
  List<PersonaSearchSuggestion> _personas = const <PersonaSearchSuggestion>[];

  /// Called where the field searches accounts for a `from:` or `mentions:`
  /// value; [onLoaded] runs once the personas for it have arrived.
  void schedulePersonaSuggestions(
    String query, {
    required VoidCallback onLoaded,
  }) {
    _personaDebounce?.cancel();
    final String trimmed = query.trim();
    _personaQuery = trimmed;
    if (trimmed.isEmpty) {
      _personas = const <PersonaSearchSuggestion>[];
      return;
    }
    _personaDebounce = Timer(_debounce, () {
      unawaited(_loadPersonas(trimmed, onLoaded));
    });
  }

  Future<void> _loadPersonas(String query, VoidCallback onLoaded) async {
    final List<PersonaSearchSuggestion> personas =
        await fetchPersonaSearchSuggestions(
          dio: ref.read(fluxerDioProvider),
          channelId: widget.channelId,
          guildId: widget.guildId,
          query: query,
        );
    if (!mounted || query != _personaQuery) {
      return;
    }
    setState(() => _personas = personas);
    onLoaded();
  }

  /// The personas section that follows the accounts section.
  List<ChannelSearchAutocompleteEntry> personaSectionEntries(String title) =>
      personaSuggestionEntries(
        _personaQuery.isEmpty ? const <PersonaSearchSuggestion>[] : _personas,
        title: title,
      );

  @override
  void dispose() {
    _personaDebounce?.cancel();
    super.dispose();
  }
}
