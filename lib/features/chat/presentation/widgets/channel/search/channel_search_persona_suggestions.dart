// Persona suggestions for `from:` and `mentions:` on the search page
// (tyne#46). They follow the account suggestions; picking one adds a search
// token whose value is the persona's search id (`persona:<id>`).

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/chat/data/persona_search_ids.dart';
import 'package:fluxer_app/features/chat/domain/channel_search_token.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/search/channel_search_suggestions.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';

/// The search token a picked persona becomes.
ChannelSearchToken personaSearchToken(
  ChannelSearchTokenKind kind,
  PersonaSearchSuggestion persona,
) => ChannelSearchToken(
  kind: kind,
  value: persona.searchId,
  label: persona.name,
);

class ChannelSearchPersonaSuggestions extends ConsumerStatefulWidget {
  const ChannelSearchPersonaSuggestions({
    required this.channelId,
    required this.guildId,
    required this.kind,
    required this.query,
    required this.onPick,
    super.key,
  });

  final String channelId;
  final String? guildId;
  final ChannelSearchTokenKind kind;

  /// The value typed after `from:` or `mentions:`, already debounced.
  final String query;
  final ValueChanged<ChannelSearchToken> onPick;

  @override
  ConsumerState<ChannelSearchPersonaSuggestions> createState() =>
      _ChannelSearchPersonaSuggestionsState();
}

class _ChannelSearchPersonaSuggestionsState
    extends ConsumerState<ChannelSearchPersonaSuggestions> {
  List<PersonaSearchSuggestion> _personas = const <PersonaSearchSuggestion>[];
  String _loadedQuery = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(ChannelSearchPersonaSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.channelId != widget.channelId) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final String query = widget.query.trim();
    final List<PersonaSearchSuggestion> personas =
        await fetchPersonaSearchSuggestions(
          dio: ref.read(fluxerDioProvider),
          channelId: widget.channelId,
          guildId: widget.guildId,
          query: query,
        );
    if (!mounted || query != widget.query.trim()) {
      return;
    }
    setState(() {
      _personas = personas;
      _loadedQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_personas.isEmpty || _loadedQuery != widget.query.trim()) {
      return const SizedBox.shrink();
    }
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ChannelSearchSectionHeader(title: l10n.fork.personaSectionTitle),
        for (final PersonaSearchSuggestion persona in _personas)
          ChannelSearchSuggestionRow(
            key: ValueKey<String>('search-persona-${persona.id}'),
            leading: FluxerAvatar.user(
              imageUrl: persona.avatarUrl,
              fallbackText: persona.name,
              avatarColor: persona.avatarColor,
              size: 32,
              showStatus: false,
              userId: persona.ownerUserId,
            ),
            title: persona.name,
            subtitle: persona.ownerTag,
            onTap: () =>
                widget.onPick(personaSearchToken(widget.kind, persona)),
          ),
      ],
    );
  }
}
