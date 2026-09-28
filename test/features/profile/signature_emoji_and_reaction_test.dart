import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/chat/data/persona_emoji_usage_store.dart';
import 'package:fluxer_app/features/chat/data/reaction_delta_utils.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/providers/pickers/emoji_picker_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_dart/export.dart';
import 'package:fluxer_dart/gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/open_test_database.dart';

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._personas);
  final List<Persona> _personas;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_personas);

  @override
  Future<void> reloadSilently() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SignatureEmoji', () {
    test('creates and serializes Unicode signature emoji', () {
      const emoji = SignatureEmoji(name: '🌟');
      expect(emoji.id, isNull);
      expect(emoji.name, '🌟');
      expect(emoji.isCustom, isFalse);

      final json = emoji.toJson();
      expect(json['id'], isNull);
      expect(json['name'], '🌟');
      expect(json.containsKey('animated'), isFalse);

      final deserialized = SignatureEmoji.fromJson(json);
      expect(deserialized.name, '🌟');
      expect(deserialized.id, isNull);
      expect(deserialized.isCustom, isFalse);
    });

    test('creates and serializes custom signature emoji', () {
      const emoji = SignatureEmoji(
        id: '1234567890',
        name: 'cat_vibing',
        animated: true,
      );
      expect(emoji.id, '1234567890');
      expect(emoji.name, 'cat_vibing');
      expect(emoji.animated, isTrue);
      expect(emoji.isCustom, isTrue);

      final json = emoji.toJson();
      expect(json['id'], '1234567890');
      expect(json['name'], 'cat_vibing');
      expect(json['animated'], isTrue);

      final deserialized = SignatureEmoji.fromJson(json);
      expect(deserialized.id, '1234567890');
      expect(deserialized.name, 'cat_vibing');
      expect(deserialized.animated, isTrue);
      expect(deserialized.isCustom, isTrue);
    });

    test('matches matches custom emoji by id', () {
      const emoji = SignatureEmoji(id: '12345', name: 'cool_cat');
      expect(
        emoji.matches(emojiId: '12345', emojiName: 'other_name'),
        isTrue,
      );
      expect(
        emoji.matches(emojiId: '99999', emojiName: 'cool_cat'),
        isFalse,
      );
      expect(
        emoji.matches(emojiName: 'cool_cat'),
        isFalse,
      );
    });

    test('matches matches Unicode emoji by name or surrogates', () {
      const emoji = SignatureEmoji(name: '👍');
      expect(
        emoji.matches(emojiName: '👍'),
        isTrue,
      );
      expect(
        emoji.matches(emojiName: '+1', surrogates: '👍'),
        isTrue,
      );
      expect(
        emoji.matches(emojiName: '👎'),
        isFalse,
      );
    });

    test('equality and hashCode support', () {
      const a1 = SignatureEmoji(id: '123', name: 'custom');
      const a2 = SignatureEmoji(id: '123', name: 'custom');
      const b = SignatureEmoji(id: '456', name: 'custom');
      const c = SignatureEmoji(name: '🌟');

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1 == b, isFalse);
      expect(a1 == c, isFalse);
    });
  });

  group('Persona & PublicPersona Signature Emojis', () {
    test('Persona parses signature_emojis and serializes correctly', () {
      final json = {
        'id': 'p1',
        'name': 'Persona 1',
        'signature_emojis': [
          {'name': '🔥'},
          {'id': 'custom_1', 'name': 'sparkle', 'animated': false},
        ],
      };

      final persona = Persona.fromJson(json);
      expect(persona.signatureEmojis.length, 2);
      expect(persona.signatureEmojis[0].name, '🔥');
      expect(persona.signatureEmojis[0].isCustom, isFalse);
      expect(persona.signatureEmojis[1].id, 'custom_1');
      expect(persona.signatureEmojis[1].name, 'sparkle');
      expect(persona.signatureEmojis[1].isCustom, isTrue);

      final serialized = persona.toJson();
      expect(serialized['signature_emojis'], isA<List<dynamic>>());
      final list = (serialized['signature_emojis'] as List<dynamic>?) ?? <dynamic>[];
      expect(list.length, 2);
      expect((list[0] as Map<String, dynamic>)['name'], '🔥');
      expect((list[1] as Map<String, dynamic>)['id'], 'custom_1');
    });

    test('PublicPersona converts to Persona preserving signature_emojis', () {
      const public = PublicPersona(
        id: 'p_pub',
        name: 'Public P',
        signatureEmojis: [
          SignatureEmoji(name: '💜'),
          SignatureEmoji(id: 'c2', name: 'wave'),
        ],
      );

      final persona = public.toPersona();
      expect(persona.signatureEmojis.length, 2);
      expect(persona.signatureEmojis[0].name, '💜');
      expect(persona.signatureEmojis[1].id, 'c2');

      final backToPub = persona.toPublicPersona();
      expect(backToPub.signatureEmojis.length, 2);
      expect(backToPub.signatureEmojis[0].name, '💜');
      expect(backToPub.signatureEmojis[1].id, 'c2');
    });

    test('copyWith updates signatureEmojis', () {
      const p = Persona(
        id: 'p_copy',
        name: 'Persona',
        signatureEmojis: [SignatureEmoji(name: '⭐')],
      );

      final updated = p.copyWith(
        signatureEmojis: const [
          SignatureEmoji(name: '⭐'),
          SignatureEmoji(name: '✨'),
        ],
      );

      expect(updated.signatureEmojis.length, 2);
      expect(updated.signatureEmojis[1].name, '✨');
    });

    test('PublicPersona parses signature_emojis, serializes, and supports copyWith', () {
      final json = {
        'id': 'pub1',
        'name': 'Public Persona 1',
        'avatar_hash': 'hash1',
        'banner_hash': 'banner1',
        'display_tag_text': 'TAG',
        'display_tag_icon': 'icon',
        'pronouns': 'they/them',
        'color': 0xFF0000,
        'avatar_color': 0x00FF00,
        'bio': 'bio here',
        'visibility': 'public',
        'auto_tag_disabled': true,
        'persona_tags': [
          {'prefix': '[', 'suffix': ']'},
        ],
        'signature_emojis': [
          {'name': '🌟'},
          {'id': 'custom_star', 'name': 'star', 'animated': true},
        ],
      };

      final publicPersona = PublicPersona.fromJson(json);
      expect(publicPersona.id, 'pub1');
      expect(publicPersona.name, 'Public Persona 1');
      expect(publicPersona.avatarHash, 'hash1');
      expect(publicPersona.bannerHash, 'banner1');
      expect(publicPersona.displayTagText, 'TAG');
      expect(publicPersona.displayTagIcon, 'icon');
      expect(publicPersona.pronouns, 'they/them');
      expect(publicPersona.color, 0xFF0000);
      expect(publicPersona.avatarColor, 0x00FF00);
      expect(publicPersona.bio, 'bio here');
      expect(publicPersona.visibility, 'public');
      expect(publicPersona.autoTagDisabled, isTrue);
      expect(publicPersona.personaTags.length, 1);
      expect(publicPersona.signatureEmojis.length, 2);
      expect(publicPersona.signatureEmojis[0].name, '🌟');
      expect(publicPersona.signatureEmojis[1].id, 'custom_star');
      expect(publicPersona.signatureEmojis[1].animated, isTrue);

      final serialized = publicPersona.toJson();
      expect(serialized['id'], 'pub1');
      expect(serialized['signature_emojis'], isA<List<dynamic>>());
      final list = (serialized['signature_emojis'] as List<dynamic>?) ?? <dynamic>[];
      expect(list.length, 2);
      expect((list[0] as Map<String, dynamic>)['name'], '🌟');
      expect((list[1] as Map<String, dynamic>)['id'], 'custom_star');

      final copied = publicPersona.copyWith(
        name: 'New Name',
        signatureEmojis: const [SignatureEmoji(name: '🔥')],
      );
      expect(copied.name, 'New Name');
      expect(copied.signatureEmojis.length, 1);
      expect(copied.signatureEmojis[0].name, '🔥');
    });
  });

  group('Reaction Model with Persona Support', () {
    test('handles meRoot and personaReactions correctly', () {
      const reaction = Reaction(
        emoji: '👍',
        count: 3,
        hasReacted: true,
        meRoot: true,
        personaReactions: ['p1', 'p2'],
      );

      expect(reaction.hasPersonaReacted(null), isTrue);
      expect(reaction.hasPersonaReacted('p1'), isTrue);
      expect(reaction.hasPersonaReacted('p2'), isTrue);
      expect(reaction.hasPersonaReacted('p3'), isFalse);
    });

    test('fromSdk parses meRoot and personaReactions', () {
      const sdk = MessageReactionResponse(
        count: 2,
        me: true,
        meRoot: false,
        personaReactions: [
          MessageReactionPersonaEntry(
            personaId: 'persona_abc',
            count: 1,
            me: true,
          ),
        ],
        emoji: MessageReactionResponseEmoji(
          name: 'heart',
          id: '112233',
          animated: true,
        ),
      );

      final r = Reaction.fromSdk(sdk);
      expect(r.emoji, 'heart');
      expect(r.emojiId, '112233');
      expect(r.animated, isTrue);
      expect(r.count, 2);
      expect(r.hasReacted, isTrue);
      expect(r.meRoot, isFalse);
      expect(r.hasPersonaReacted(null), isFalse);
      expect(r.hasPersonaReacted('persona_abc'), isTrue);

      final apiJson = {
        'count': 2,
        'me': true,
        'me_root': false,
        'persona_reactions': [
          {'persona_id': 'persona_abc', 'count': 1, 'me': true},
          {'persona_id': 'persona_xyz', 'count': 1, 'me': false},
        ],
        'emoji': {
          'name': 'heart',
          'id': '112233',
          'animated': true,
        },
      };
      final fromJsonSdk = MessageReactionResponse.fromJson(apiJson);
      final r2 = Reaction.fromSdk(fromJsonSdk);
      expect(r2.hasPersonaReacted('persona_abc'), isTrue);
      expect(r2.hasPersonaReacted('persona_xyz'), isFalse);
    });

    test('fromJson and toJson roundtrip persona reactions', () {
      final json = {
        'emoji': '🎉',
        'emojiId': null,
        'animated': false,
        'count': 5,
        'hasReacted': true,
        'meRoot': true,
        'personaReactions': ['p1'],
      };

      final r = Reaction.fromJson(json);
      expect(r.emoji, '🎉');
      expect(r.count, 5);
      expect(r.meRoot, isTrue);
      expect(r.hasPersonaReacted(null), isTrue);
      expect(r.hasPersonaReacted('p1'), isTrue);

      final out = r.toJson();
      expect(out['emoji'], '🎉');
      expect(out['count'], 5);
      expect(out['meRoot'], isTrue);
      expect(out['personaReactions'], ['p1']);
    });

    test('parses persona reactions from backend map format with item["me"] == true', () {
      final json = {
        'emoji': '🦊',
        'emojiId': null,
        'count': 2,
        'me': true,
        'hasReacted': true,
        'meRoot': false,
        'persona_reactions': [
          {'persona_id': 'p1', 'me': true},
          {'persona_id': 'p2', 'me': false},
        ],
      };

      final reaction = Reaction.fromJson(json);
      expect(reaction.meRoot, isFalse);
      expect(reaction.hasReacted, isTrue);
      expect(reaction.personaReactions, ['p1']);
      expect(reaction.hasPersonaReacted('p1'), isTrue);
      expect(reaction.hasPersonaReacted('p2'), isFalse);
      expect(reaction.hasPersonaReacted(null), isFalse);
    });
  });

  group('applyMessageReactionDelta', () {
    test('adds root reaction to existing reaction', () {
      final reactions = <Map<String, dynamic>>[
        {
          'emoji': '👍',
          'emojiId': null,
          'count': 1,
          'me': false,
          'meRoot': false,
          'personaReactions': <String>[],
        },
      ];

      final changed = applyMessageReactionDelta(
        reactions,
        const ReactionEmoji(name: '👍'),
        isAdd: true,
        isCurrentUser: true,
      );

      expect(changed, isTrue);
      expect(reactions.length, 1);
      expect(reactions[0]['count'], 2);
      expect(reactions[0]['me'], isTrue);
      expect(reactions[0]['meRoot'], isTrue);
      expect(reactions[0]['personaReactions'], isEmpty);
    });

    test('adds persona reaction without setting meRoot', () {
      final reactions = <Map<String, dynamic>>[
        {
          'emoji': '👍',
          'emojiId': null,
          'count': 1,
          'me': true,
          'meRoot': true,
          'personaReactions': <String>[],
        },
      ];

      final changed = applyMessageReactionDelta(
        reactions,
        const ReactionEmoji(name: '👍'),
        isAdd: true,
        isCurrentUser: true,
        personaId: 'persona_x',
      );

      expect(changed, isTrue);
      expect(reactions.length, 1);
      expect(reactions[0]['count'], 2);
      expect(reactions[0]['me'], isTrue);
      expect(reactions[0]['meRoot'], isTrue);
      expect(reactions[0]['personaReactions'], ['persona_x']);
    });

    test('removes persona reaction preserving root reaction', () {
      final reactions = <Map<String, dynamic>>[
        {
          'emoji': '👍',
          'emojiId': null,
          'count': 2,
          'me': true,
          'meRoot': true,
          'personaReactions': ['persona_x'],
        },
      ];

      final changed = applyMessageReactionDelta(
        reactions,
        const ReactionEmoji(name: '👍'),
        isAdd: false,
        isCurrentUser: true,
        personaId: 'persona_x',
      );

      expect(changed, isTrue);
      expect(reactions.length, 1);
      expect(reactions[0]['count'], 1);
      expect(reactions[0]['me'], isTrue);
      expect(reactions[0]['meRoot'], isTrue);
      expect(reactions[0]['personaReactions'], isEmpty);
    });

    test('removes root reaction preserving other personas', () {
      final reactions = <Map<String, dynamic>>[
        {
          'emoji': '👍',
          'emojiId': null,
          'count': 2,
          'me': true,
          'meRoot': true,
          'personaReactions': ['persona_y'],
        },
      ];

      final changed = applyMessageReactionDelta(
        reactions,
        const ReactionEmoji(name: '👍'),
        isAdd: false,
        isCurrentUser: true,
      );

      expect(changed, isTrue);
      expect(reactions.length, 1);
      expect(reactions[0]['count'], 1);
      expect(reactions[0]['me'], isTrue);
      expect(reactions[0]['meRoot'], isFalse);
      expect(reactions[0]['personaReactions'], ['persona_y']);
    });

    test(
      'duplicate root removal (e.g. gateway echo after optimistic unreact) returns false and does not decrement count',
      () {
        final reactions = <Map<String, dynamic>>[
          {
            'emoji': '👍',
            'emojiId': null,
            'count': 1,
            'me': true,
            'hasReacted': true,
            'meRoot': false,
            'personaReactions': ['persona_y'],
          },
        ];

        final changed = applyMessageReactionDelta(
          reactions,
          const ReactionEmoji(name: '👍'),
          isAdd: false,
          isCurrentUser: true,
        );

        expect(changed, isFalse);
        expect(reactions.length, 1);
        expect(reactions[0]['count'], 1);
        expect(reactions[0]['me'], isTrue);
        expect(reactions[0]['meRoot'], isFalse);
        expect(reactions[0]['personaReactions'], ['persona_y']);
      },
    );

    test(
      'duplicate persona removal returns false and does not decrement count',
      () {
        final reactions = <Map<String, dynamic>>[
          {
            'emoji': '👍',
            'emojiId': null,
            'count': 1,
            'me': true,
            'hasReacted': true,
            'meRoot': true,
            'personaReactions': <String>[],
          },
        ];

        final changed = applyMessageReactionDelta(
          reactions,
          const ReactionEmoji(name: '👍'),
          isAdd: false,
          isCurrentUser: true,
          personaId: 'already_removed_persona',
        );

        expect(changed, isFalse);
        expect(reactions.length, 1);
        expect(reactions[0]['count'], 1);
        expect(reactions[0]['me'], isTrue);
        expect(reactions[0]['meRoot'], isTrue);
      },
    );

    test('removing non-existent reaction returns false', () {
      final reactions = <Map<String, dynamic>>[];

      final changed = applyMessageReactionDelta(
        reactions,
        const ReactionEmoji(name: '❤️'),
        isAdd: false,
        isCurrentUser: true,
      );

      expect(changed, isFalse);
      expect(reactions, isEmpty);
    });
  });

  group('rankedEmojiUsageKeysForPersonaProvider', () {
    test('merges signature emojis at top, then persona frecency, then global frecency', () async {
      SharedPreferences.setMockInitialValues({});
      await PersonaEmojiUsageStore.trackUsage('unicode:party', 'p_fox');

      const foxPersona = Persona(
        id: 'p_fox',
        name: 'Fox',
        signatureEmojis: [
          SignatureEmoji(name: '🦊'),
          SignatureEmoji(id: 'custom_fox', name: 'fox_dance'),
        ],
      );

      final db = openTestDatabase();
      final container = ProviderContainer(
        overrides: [
          fluxerDatabaseProvider.overrideWithValue(db),
          myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier([foxPersona])),
          rankedEmojiUsageKeysProvider.overrideWithValue(
            const AsyncData(['unicode:thumbsup', 'unicode:party', 'unicode:heart']),
          ),
        ],
      );
      addTearDown(container.dispose);

      final keys = await container.read(rankedEmojiUsageKeysForPersonaProvider('p_fox').future);

      expect(keys.first, anyOf(contains('fox'), 'unicode:🦊'));
      expect(keys, contains('unicode:party'));
      expect(keys, contains('unicode:thumbsup'));
      expect(keys, contains('unicode:heart'));
    });
  });
}
