// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:test/test.dart';

void main() {
  group('PersonaTag', () {
    test('serializes to and deserializes from JSON', () {
      final tag = PersonaTag.fromJson(const {
        'prefix': '[',
        'suffix': ']',
      });
      expect(tag.prefix, '[');
      expect(tag.suffix, ']');

      final json = tag.toJson();
      expect(json['prefix'], '[');
      expect(json['suffix'], ']');
    });

    test('displayPattern formats correctly', () {
      const tagBoth = PersonaTag(prefix: '[', suffix: ']');
      expect(tagBoth.displayPattern, '[text]');

      const tagPrefixOnly = PersonaTag(prefix: 'A:');
      expect(tagPrefixOnly.displayPattern, 'A:text');

      const tagSuffixOnly = PersonaTag(suffix: '-B');
      expect(tagSuffixOnly.displayPattern, 'text-B');

      const tagEmpty = PersonaTag();
      expect(tagEmpty.displayPattern, '');
    });
  });

  group('Persona', () {
    test('serializes to and deserializes from JSON', () {
      final jsonInput = {
        'id': 'persona_1',
        'name': 'Test Persona',
        'avatar_url': 'https://example.com/avatar.png',
        'system_name': 'System Tag',
        'pronouns': 'they/them',
        'color': 0xFF00FF,
        'bio': 'A test bio',
        'auto_tag_disabled': true,
        'persona_tags': [
          {'prefix': 'T:', 'suffix': null},
        ],
        'use_count': 42,
        'last_used_at_ms': 123456789,
        'visibility': 'public',
        'external_uuid': 'ext-uuid-1',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
      };

      final persona = Persona.fromJson(jsonInput);
      expect(persona.id, 'persona_1');
      expect(persona.name, 'Test Persona');
      expect(persona.avatarUrl, 'https://example.com/avatar.png');
      expect(persona.systemName, 'System Tag');
      expect(persona.pronouns, 'they/them');
      expect(persona.color, 0xFF00FF);
      expect(persona.bio, 'A test bio');
      expect(persona.autoTagDisabled, isTrue);
      expect(persona.personaTags.length, 1);
      expect(persona.personaTags.first.prefix, 'T:');
      expect(persona.useCount, 42);
      expect(persona.lastUsedAtMs, 123456789);
      expect(persona.visibility, 'public');
      expect(persona.externalUuid, 'ext-uuid-1');

      final serialized = persona.toJson();
      expect(serialized['id'], 'persona_1');
      expect(serialized['name'], 'Test Persona');
      expect(serialized['avatar_url'], 'https://example.com/avatar.png');
      expect(serialized['use_count'], 42);
      expect(serialized['last_used_at_ms'], '123456789');
    });

    test('handles fallback camelCase and alias field names in fromJson', () {
      final persona = Persona.fromJson(const {
        'id': 'p2',
        'name': 'Fallback',
        'avatar': 'https://example.com/p2.png',
        'display_tag_text': 'Fallback Tag',
        'accent_color': 12345,
        'autoTagDisabled': false,
        'personaTags': [
          {'prefix': 'F:'},
        ],
        'useCount': 5,
        'lastUsedAtMs': '987654321',
        'externalUuid': 'ext-uuid-2',
      });

      expect(persona.avatarUrl, 'https://example.com/p2.png');
      expect(persona.systemName, 'Fallback Tag');
      expect(persona.color, 12345);
      expect(persona.lastUsedAtMs, 987654321);
      expect(persona.personaTags.length, 1);
    });

    test('copyWith updates fields while preserving existing values', () {
      const original = Persona(
        id: 'orig_id',
        name: 'Original',
        bio: 'Old bio',
        useCount: 1,
      );

      final updated = original.copyWith(
        name: 'New Name',
        bio: 'New bio',
        useCount: 2,
      );

      expect(updated.id, 'orig_id');
      expect(updated.name, 'New Name');
      expect(updated.bio, 'New bio');
      expect(updated.useCount, 2);

      final untouched = original.copyWith();
      expect(untouched.id, original.id);
      expect(untouched.name, original.name);
      expect(untouched.bio, original.bio);
      expect(untouched.useCount, original.useCount);
    });
  });
}
