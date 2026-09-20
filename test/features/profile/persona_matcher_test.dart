// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:test/test.dart';

void main() {
  const alice = Persona(
    id: 'persona_alice',
    name: 'Alice',
    personaTags: [
      PersonaTag(prefix: 'A:'),
    ],
  );

  const bob = Persona(
    id: 'persona_bob',
    name: 'Bob',
    personaTags: [
      PersonaTag(prefix: 'B:'),
      PersonaTag(suffix: '-B'),
    ],
  );

  const bracketMan = Persona(
    id: 'persona_bracket',
    name: 'BracketMan',
    personaTags: [
      PersonaTag(prefix: '[', suffix: ']'),
    ],
  );

  const doubleBracketMan = Persona(
    id: 'persona_double_bracket',
    name: 'DoubleBracketMan',
    personaTags: [
      PersonaTag(prefix: '[[', suffix: ']]'),
    ],
  );

  const longAlice = Persona(
    id: 'persona_alice_long',
    name: 'AliceLong',
    personaTags: [
      PersonaTag(prefix: 'ALICE:'),
    ],
  );

  final List<Persona> personas = [alice, bob, bracketMan, doubleBracketMan, longAlice];

  group('PersonaMatcher', () {
    test('matches prefix persona tag and strips prefix', () {
      final res = matchPersona('A: hello world', personas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, alice.id);
      expect(res.strippedContent, 'hello world');
      expect(res.isFromTag, isTrue);
    });

    test('matches suffix persona tag and strips suffix', () {
      final res = matchPersona('hello there -B', personas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, bob.id);
      expect(res.strippedContent, 'hello there');
      expect(res.isFromTag, isTrue);
    });

    test('matches prefix and suffix tag and strips both', () {
      final res = matchPersona('[in brackets]', personas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, bracketMan.id);
      expect(res.strippedContent, 'in brackets');
      expect(res.isFromTag, isTrue);
    });

    test('prefers longest matching tag when prefixes overlap', () {
      final res = matchPersona('ALICE: test message', personas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, longAlice.id);
      expect(res.strippedContent, 'test message');
    });

    test('falls back to latched persona when no tag is present', () {
      final res = matchPersona('just normal message', personas, bob.id, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, bob.id);
      expect(res.strippedContent, 'just normal message');
      expect(res.isFromTag, isFalse);
    });

    test('tag overrides latched persona', () {
      final res = matchPersona('A: hello', personas, bob.id, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, alice.id);
      expect(res.strippedContent, 'hello');
      expect(res.isFromTag, isTrue);
    });

    test('double backslash clears latch', () {
      final res = matchPersona(r'\\', personas, bob.id, false);
      expect(res.clearedLatch, isTrue);
      expect(res.matched, isFalse);
      expect(res.strippedContent, isEmpty);
    });

    test('double backslash with message clears latch and preserves message', () {
      final res = matchPersona(r'\\ hello unlatched', personas, bob.id, false);
      expect(res.clearedLatch, isTrue);
      expect(res.wasEscaped, isTrue);
      expect(res.matched, isFalse);
      expect(res.strippedContent, 'hello unlatched');
    });

    test('backslash escape disables tag matching and strips escape prefix', () {
      final res = matchPersona(r'\ A: this is escaped', personas, null, false);
      expect(res.wasEscaped, isTrue);
      expect(res.matched, isFalse);
      expect(res.strippedContent, 'A: this is escaped');
    });

    test('returns unmatched for regular message with no latch and no tag', () {
      final res = matchPersona('plain message', personas, null, false);
      expect(res.matched, isFalse);
      expect(res.strippedContent, 'plain message');
    });

    test('matches latched persona for pending attachments even with empty text', () {
      final res = matchPersona('', personas, alice.id, true);
      expect(res.matched, isTrue);
      expect(res.persona?.id, alice.id);
    });

    test('returns unmatched when text is empty and no attachments', () {
      final res = matchPersona('', personas, alice.id, false);
      expect(res.matched, isFalse);
    });

    test('matches tag with attachment when text is only prefix or suffix', () {
      final prefixOnly = matchPersona('A:', personas, null, true);
      expect(prefixOnly.matched, isTrue);
      expect(prefixOnly.persona?.id, alice.id);
      expect(prefixOnly.strippedContent, isEmpty);

      final suffixOnly = matchPersona('-B', personas, null, true);
      expect(suffixOnly.matched, isTrue);
      expect(suffixOnly.persona?.id, bob.id);
      expect(suffixOnly.strippedContent, isEmpty);

      final bracketEmpty = matchPersona('[]', personas, null, true);
      expect(bracketEmpty.matched, isTrue);
      expect(bracketEmpty.persona?.id, bracketMan.id);
      expect(bracketEmpty.strippedContent, isEmpty);

      final bracketSpace = matchPersona('[ ]', personas, null, true);
      expect(bracketSpace.matched, isTrue);
      expect(bracketSpace.persona?.id, bracketMan.id);
      expect(bracketSpace.strippedContent, isEmpty);

      final openBracketOnly = matchPersona('[', personas, null, true);
      expect(openBracketOnly.matched, isFalse);

      final closeBracketOnly = matchPersona(']', personas, null, true);
      expect(closeBracketOnly.matched, isFalse);

      const spacedPrefixPersona = Persona(
        id: 'p_spaced_prefix',
        name: 'SpacedPrefix',
        personaTags: [PersonaTag(prefix: 'D: ')],
      );
      final spacedPrefixMatch = matchPersona('D:', [spacedPrefixPersona], null, true);
      expect(spacedPrefixMatch.matched, isTrue);
      expect(spacedPrefixMatch.persona?.id, spacedPrefixPersona.id);
      expect(spacedPrefixMatch.strippedContent, isEmpty);

      const spacedSuffixPersona = Persona(
        id: 'p_spaced_suffix',
        name: 'SpacedSuffix',
        personaTags: [PersonaTag(suffix: ' -S')],
      );
      final spacedSuffixMatch = matchPersona('-S', [spacedSuffixPersona], null, true);
      expect(spacedSuffixMatch.matched, isTrue);
      expect(spacedSuffixMatch.persona?.id, spacedSuffixPersona.id);
      expect(spacedSuffixMatch.strippedContent, isEmpty);
    });

    test('ignores persona tags when autoTagDisabled is true', () {
      const disabledPersona = Persona(
        id: 'persona_disabled',
        name: 'Disabled',
        autoTagDisabled: true,
        personaTags: [
          PersonaTag(prefix: 'D:'),
        ],
      );
      final res = matchPersona('D: test', [disabledPersona], null, false);
      expect(res.matched, isFalse);
    });
  });

  group('PreviewPersona', () {
    test('previews persona from tag in real-time', () {
      final preview = previewPersona('A: typing...', personas, null, false);
      expect(preview.persona?.id, alice.id);
      expect(preview.isFromTag, isTrue);
    });

    test('previews latched persona when no tag', () {
      final preview = previewPersona('typing...', personas, bob.id, false);
      expect(preview.persona?.id, bob.id);
      expect(preview.isFromTag, isFalse);
    });

    test('previews nothing when escaped', () {
      final preview = previewPersona(r'\ A: typing...', personas, null, false);
      expect(preview.persona, isNull);
    });

    test('previews nothing when latch cleared with double backslash', () {
      final preview = previewPersona(r'\\ typing...', personas, bob.id, false);
      expect(preview.persona, isNull);
    });

    test('previews nothing for regular message with no latch and no tag', () {
      final preview = previewPersona('just typing', personas, null, false);
      expect(preview.persona, isNull);
      expect(preview.isFromTag, isFalse);
    });

    test('prefers DoubleBracketMan over BracketMan in preview and match', () {
      // previewPersona with message
      final previewMsg = previewPersona('[[Hello]]', personas, null, false);
      expect(previewMsg.persona?.id, doubleBracketMan.id);
      expect(previewMsg.isFromTag, isTrue);

      // matchPersona with message
      final matchMsg = matchPersona('[[Hello]]', personas, null, false);
      expect(matchMsg.matched, isTrue);
      expect(matchMsg.persona?.id, doubleBracketMan.id);
      expect(matchMsg.strippedContent, 'Hello');

      // previewPersona with empty tag
      final previewEmpty = previewPersona('[[]]', personas, null, false);
      expect(previewEmpty.persona?.id, doubleBracketMan.id);
      expect(previewEmpty.isFromTag, isTrue);

      // previewPersona with space
      final previewSpace = previewPersona('[[  ]]', personas, null, false);
      expect(previewSpace.persona?.id, doubleBracketMan.id);
      expect(previewSpace.isFromTag, isTrue);

      // matchPersona with attachments and empty tags
      final matchAttach = matchPersona('[[]]', personas, null, true);
      expect(matchAttach.matched, isTrue);
      expect(matchAttach.persona?.id, doubleBracketMan.id);
      expect(matchAttach.strippedContent, isEmpty);
    });

    test('breaks ties by longer prefix when total length is equal', () {
      const p1 = Persona(
        id: 'p_prefix2',
        name: 'PrefixTwo',
        personaTags: [PersonaTag(prefix: '##')], // totalLen = 2, prefixLen = 2
      );
      const p2 = Persona(
        id: 'p_wrap1',
        name: 'WrapOne',
        personaTags: [PersonaTag(prefix: '#', suffix: '#')], // totalLen = 2, prefixLen = 1
      );
      final tiePersonas = [p2, p1];

      // Input '##hello#' could match p1 (prefix '##') with remainder 'hello#'
      // or p2 (prefix '#', suffix '#') with remainder '#hello'
      // Both have totalLen = 2, but p1 has prefixLen = 2 vs p2's prefixLen = 1
      final res = matchPersona('##hello#', tiePersonas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, p1.id);
      expect(res.strippedContent, 'hello#');
    });
  });

  group('matchEditMessage', () {
    test('root message edited with persona tag prepended switches to persona', () {
      final res = matchEditMessage(
        content: '[Hello Alice!]',
        personas: personas,
        currentPersonaId: null,
      );
      expect(res.finalContent, 'Hello Alice!');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.isRootAccount, isFalse);
      expect(res.persona?.id, bracketMan.id);
    });

    test('persona message edited with another persona tag prepended switches persona', () {
      final res = matchEditMessage(
        content: 'B: Hello Bob!',
        personas: personas,
        currentPersonaId: alice.id,
      );
      expect(res.finalContent, 'Hello Bob!');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.isRootAccount, isFalse);
      expect(res.persona?.id, bob.id);
    });

    test('persona message edited without tags preserves persona', () {
      final res = matchEditMessage(
        content: 'Plain edit with no tags',
        personas: personas,
        currentPersonaId: alice.id,
      );
      expect(res.finalContent, 'Plain edit with no tags');
      expect(res.shouldUpdatePersona, isFalse);
    });

    test('persona message edited with leading backslash unproxies to root', () {
      final res1 = matchEditMessage(
        content: r'\Plain edit meant for root',
        personas: personas,
        currentPersonaId: alice.id,
      );
      expect(res1.finalContent, 'Plain edit meant for root');
      expect(res1.shouldUpdatePersona, isTrue);
      expect(res1.isRootAccount, isTrue);
      expect(res1.persona, isNull);

      final res2 = matchEditMessage(
        content: r'\\ Plain edit meant for root',
        personas: personas,
        currentPersonaId: alice.id,
      );
      expect(res2.finalContent, 'Plain edit meant for root');
      expect(res2.shouldUpdatePersona, isTrue);
      expect(res2.isRootAccount, isTrue);
      expect(res2.persona, isNull);
    });

    test('root message edited without tags remains root', () {
      final res = matchEditMessage(
        content: 'Plain root edit',
        personas: personas,
        currentPersonaId: null,
      );
      expect(res.finalContent, 'Plain root edit');
      expect(res.shouldUpdatePersona, isFalse);
    });

    test('attachment message edited with tag only sets persona with empty content', () {
      final res = matchEditMessage(
        content: 'B:',
        personas: personas,
        currentPersonaId: null,
        hasAttachments: true,
      );
      expect(res.finalContent, '');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.persona?.id, bob.id);
    });

    test('attachment message edited with backslash only unproxies to root with empty content', () {
      final res = matchEditMessage(
        content: r'\\',
        personas: personas,
        currentPersonaId: alice.id,
        hasAttachments: true,
      );
      expect(res.finalContent, '');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.isRootAccount, isTrue);
    });

    test('text message edited with tag only sets persona and empty content', () {
      final res = matchEditMessage(
        content: 'B:',
        personas: personas,
        currentPersonaId: alice.id,
        hasAttachments: false,
      );
      expect(res.finalContent, '');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.persona?.id, bob.id);
    });

    test('text message edited with backslash only unproxies to root and empty content', () {
      final res = matchEditMessage(
        content: r'\',
        personas: personas,
        currentPersonaId: alice.id,
        hasAttachments: false,
      );
      expect(res.finalContent, '');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.isRootAccount, isTrue);
    });

    test('captioned attachment message edited with prepended tag sets persona and preserves caption', () {
      final res = matchEditMessage(
        content: 'B: Look at my dog',
        personas: personas,
        currentPersonaId: alice.id,
        hasAttachments: true,
      );
      expect(res.finalContent, 'Look at my dog');
      expect(res.shouldUpdatePersona, isTrue);
      expect(res.persona?.id, bob.id);
    });
  });
}
