// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:test/test.dart';

void main() {
  const alice = Persona(
    id: 'persona_alice',
    name: 'Alice',
    personaTags: [
      PersonaTag(prefix: 'A:', suffix: null),
    ],
  );

  const bob = Persona(
    id: 'persona_bob',
    name: 'Bob',
    personaTags: [
      PersonaTag(prefix: 'B:', suffix: null),
      PersonaTag(prefix: null, suffix: '-B'),
    ],
  );

  const bracketMan = Persona(
    id: 'persona_bracket',
    name: 'BracketMan',
    personaTags: [
      PersonaTag(prefix: '[', suffix: ']'),
    ],
  );

  const longAlice = Persona(
    id: 'persona_alice_long',
    name: 'AliceLong',
    personaTags: [
      PersonaTag(prefix: 'ALICE:', suffix: null),
    ],
  );

  final List<Persona> personas = [alice, bob, bracketMan, longAlice];

  group('PersonaMatcher', () {
    test('matches prefix proxy tag and strips prefix', () {
      final res = matchPersona('A: hello world', personas, null, false);
      expect(res.matched, isTrue);
      expect(res.persona?.id, alice.id);
      expect(res.strippedContent, 'hello world');
      expect(res.isFromTag, isTrue);
    });

    test('matches suffix proxy tag and strips suffix', () {
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

    test('backslash escape disables tag matching and strips escape prefix', () {
      final res = matchPersona(r'\ A: this is escaped', personas, null, false);
      expect(res.wasEscaped, isTrue);
      expect(res.matched, isFalse);
      expect(res.strippedContent, 'A: this is escaped');
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
  });
}
