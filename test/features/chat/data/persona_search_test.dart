import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';
import 'package:fluxer_app/features/chat/data/channel_search_query_parser.dart';
import 'package:fluxer_app/features/chat/data/message_search_repository.dart';
import 'package:fluxer_app/features/chat/data/persona_search_ids.dart';
import 'package:fluxer_app/features/chat/domain/channel_search_token.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/header/channel_header_persona_suggestions.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/header/channel_header_search_autocomplete.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/search/channel_search_persona_suggestions.dart';
import 'package:fluxer_app/features/chat/utils/search/channel_search_autocomplete.dart';
import 'package:fluxer_dart/export.dart';

Map<String, dynamic> _persona(String id, String name, {String owner = '700'}) =>
    <String, dynamic>{
      'id': id,
      'name': name,
      'visibility': 'public',
      'use_count': 0,
      'owner_user_id': owner,
      'owner_username': 'owner$owner',
    };

GlobalSearchMessagesRequest _request({
  required String query,
  ChannelSearchParseHints hints = const ChannelSearchParseHints(),
  ChannelSearchParseContext context = const ChannelSearchParseContext(),
  List<ChannelSearchToken> tokens = const <ChannelSearchToken>[],
}) => buildGlobalSearchMessagesRequest(
  MessageSearchQuery.build(
    channelId: 'c1',
    rawQuery: query,
    hints: hints,
    context: context,
    chipFilters: channelSearchChipFiltersForTokens(tokens),
  ),
);

void main() {
  tearDown(ChannelPersonaMentionCache.instance.clear);

  group('persona search ids', () {
    test('are told apart from account ids', () {
      final List<String> ids = <String>['900', 'persona:501', '901'];

      expect(accountSearchIds(ids), <String>['900', '901']);
      expect(personaSearchIds(ids), <String>['501']);
      expect(isPersonaSearchId('persona:501'), isTrue);
      expect(isPersonaSearchId('900'), isFalse);
      expect(isPersonaSearchId(null), isFalse);
    });
  });

  group('resolvePersonaSearchName', () {
    test('finds the one known persona with a name, in any case', () {
      expect(
        resolvePersonaSearchName(
          'ash',
          known: <Map<String, dynamic>>[
            _persona('501', 'Ash'),
            _persona('502', 'Bo'),
          ],
        ),
        'persona:501',
      );
    });

    test('finds nobody for a name two personas share, or none has', () {
      final List<Map<String, dynamic>> known = <Map<String, dynamic>>[
        _persona('501', 'Ash'),
        _persona('601', 'ash', owner: '701'),
      ];

      expect(resolvePersonaSearchName('Ash', known: known), isNull);
      expect(resolvePersonaSearchName('Cy', known: known), isNull);
      expect(resolvePersonaSearchName('  ', known: known), isNull);
    });
  });

  group('PersonaSearchSuggestion.fromItem', () {
    test(
      'shows the owner tag with a discriminator only when it means something',
      () {
        final PersonaSearchSuggestion? plain = PersonaSearchSuggestion.fromItem(
          <String, dynamic>{
            ..._persona('501', 'Ash'),
            'owner_discriminator': '0000',
          },
        );
        final PersonaSearchSuggestion? tagged =
            PersonaSearchSuggestion.fromItem(<String, dynamic>{
              ..._persona('501', 'Ash'),
              'owner_discriminator': '0042',
            });

        expect(plain?.ownerTag, 'owner700');
        expect(tagged?.ownerTag, 'owner700#0042');
        expect(plain?.searchId, 'persona:501');
      },
    );

    test('skips an item without an id, owner or name', () {
      expect(
        PersonaSearchSuggestion.fromItem(<String, dynamic>{'name': 'Ash'}),
        isNull,
      );
    });
  });

  group('the search request', () {
    test('sends a persona the header field remembered under its name', () {
      final GlobalSearchMessagesRequest request = _request(
        query: 'from:Ash -mentions:Bo',
        hints: const ChannelSearchParseHints(
          usersByTag: <String, String>{
            'Ash': 'persona:501',
            'Bo': 'persona:502',
          },
        ),
      );

      expect(request.personaId, <String>['501']);
      expect(request.excludePersonaMentions, <String>['502']);
      expect(request.authorId, isNull);
      expect(request.excludeMentions, isNull);
    });

    test('sends accounts and personas named together in their own fields', () {
      final GlobalSearchMessagesRequest request = _request(
        query: 'from:Ash from:alice',
        hints: const ChannelSearchParseHints(
          usersByTag: <String, String>{'Ash': 'persona:501', 'alice': '900'},
        ),
      );

      expect(request.authorId, <String>['900']);
      expect(request.personaId, <String>['501']);
    });

    test('sends the personas of picked search tokens', () {
      final PersonaSearchSuggestion ash = PersonaSearchSuggestion.fromItem(
        _persona('501', 'Ash'),
      )!;
      final GlobalSearchMessagesRequest request = _request(
        query: '',
        tokens: <ChannelSearchToken>[
          personaSearchToken(ChannelSearchTokenKind.from, ash),
          personaSearchToken(ChannelSearchTokenKind.mentions, ash),
          const ChannelSearchToken(
            kind: ChannelSearchTokenKind.from,
            value: '900',
          ),
        ],
      );

      expect(request.authorId, <String>['900']);
      expect(request.personaId, <String>['501']);
      expect(request.personaMentions, <String>['501']);
      expect(request.mentions, isNull);
    });

    test('takes a typed name for a persona only when no account has it', () {
      ChannelPersonaMentionCache.instance.setChannelPersonas(
        'c1',
        <Map<String, dynamic>>[_persona('501', 'ash')],
      );

      expect(_request(query: 'from:ash').personaId, <String>['501']);

      final GlobalSearchMessagesRequest account = _request(
        query: 'from:ash',
        context: ChannelSearchParseContext(
          resolveUserByTag: (String tag) => tag == 'ash' ? '900' : null,
        ),
      );
      expect(account.authorId, <String>['900']);
      expect(account.personaId, isNull);
    });
  });

  group('personaSuggestionEntries', () {
    test('puts a personas header before the personas, picked as users', () {
      final PersonaSearchSuggestion ash = PersonaSearchSuggestion.fromItem(
        _persona('501', 'Ash'),
      )!;
      final List<ChannelSearchAutocompleteEntry> entries =
          personaSuggestionEntries(<PersonaSearchSuggestion>[
            ash,
          ], title: 'Personas');

      expect(entries, hasLength(2));
      expect(entries.first.isSectionHeader, isTrue);
      expect(entries.first.label, 'Personas');
      expect(entries.last.section, ChannelSearchAutocompleteSection.users);
      expect(entries.last.userId, 'persona:501');
      expect(entries.last.value, 'Ash');
      expect(
        personaSuggestionEntries(
          const <PersonaSearchSuggestion>[],
          title: 'Personas',
        ),
        isEmpty,
      );
    });
  });
}
