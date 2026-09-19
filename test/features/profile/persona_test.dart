import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
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

  group('PersonaSettings', () {
    test('default constructor sets fallback values', () {
      const settings = PersonaSettings();
      expect(settings.userId, '');
      expect(settings.activePersonaMode, 'off');
      expect(settings.activePersonaId, isNull);
      expect(settings.isLatched, isFalse);
      expect(settings.displayTagText, '');
      expect(settings.displayTagIcon, isNull);
    });

    test('serializes to and deserializes from JSON', () {
      final json = <String, dynamic>{
        'user_id': 'user_123',
        'active_persona_mode': 'last_used',
        'active_persona_id': 'persona_abc',
        'is_latched': true,
        'display_tag_text': 'Wonderland',
        'display_tag_icon': 'icon_hash_xyz',
      };

      final settings = PersonaSettings.fromJson(json);
      expect(settings.userId, 'user_123');
      expect(settings.activePersonaMode, 'last_used');
      expect(settings.activePersonaId, 'persona_abc');
      expect(settings.isLatched, isTrue);
      expect(settings.displayTagText, 'Wonderland');
      expect(settings.displayTagIcon, 'icon_hash_xyz');

      final serialized = settings.toJson();
      expect(serialized['user_id'], 'user_123');
      expect(serialized['active_persona_mode'], 'last_used');
      expect(serialized['active_persona_id'], 'persona_abc');
      expect(serialized['is_latched'], isTrue);
      expect(serialized['display_tag_text'], 'Wonderland');
      expect(serialized['display_tag_icon'], 'icon_hash_xyz');
    });

    test('copyWith updates fields and clears with callback', () {
      const settings = PersonaSettings(
        userId: 'u1',
        activePersonaMode: 'last_used',
        activePersonaId: 'p1',
        isLatched: true,
        displayTagText: 'Tag',
      );

      final updated = settings.copyWith(
        activePersonaMode: 'forced',
        activePersonaId: () => 'p2',
        isLatched: false,
      );

      expect(updated.activePersonaMode, 'forced');
      expect(updated.activePersonaId, 'p2');
      expect(updated.isLatched, isFalse);
      expect(updated.userId, 'u1');

      final cleared = settings.copyWith(activePersonaId: () => null);
      expect(cleared.activePersonaId, isNull);
    });

    test('implements value equality and hashCode', () {
      const s1 = PersonaSettings(userId: 'u1', activePersonaMode: 'off');
      const s2 = PersonaSettings(userId: 'u1', activePersonaMode: 'off');
      const s3 = PersonaSettings(userId: 'u1', activePersonaMode: 'forced');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });

  group('PublicPersona', () {
    test('serializes to and deserializes from JSON with tags', () {
      final json = <String, dynamic>{
        'id': 'pub_1',
        'name': 'Public Alice',
        'avatar_url': 'https://example.com/alice.png',
        'system_name': 'Alice System',
        'pronouns': 'she/her',
        'color': 0x00FF00,
        'bio': 'A public bio',
        'visibility': 'public',
        'auto_tag_disabled': true,
        'persona_tags': [
          {'prefix': '[A]', 'suffix': null},
        ],
      };

      final persona = PublicPersona.fromJson(json);
      expect(persona.id, 'pub_1');
      expect(persona.name, 'Public Alice');
      expect(persona.avatarUrl, 'https://example.com/alice.png');
      expect(persona.systemName, 'Alice System');
      expect(persona.pronouns, 'she/her');
      expect(persona.color, 0x00FF00);
      expect(persona.bio, 'A public bio');
      expect(persona.visibility, 'public');
      expect(persona.autoTagDisabled, isTrue);
      expect(persona.personaTags.length, 1);
      expect(persona.personaTags.first.prefix, '[A]');

      final serialized = persona.toJson();
      expect(serialized['id'], 'pub_1');
      expect(serialized['name'], 'Public Alice');
      expect(serialized['avatar_url'], 'https://example.com/alice.png');
      expect(serialized['auto_tag_disabled'], isTrue);
    });

    test('handles fallback camelCase and alias field names in fromJson', () {
      final json = <String, dynamic>{
        'id': 'pub_2',
        'name': 'Bob',
        'avatar': 'hash_123',
        'display_tag_text': 'Bob Tag',
        'personaTags': [
          {'prefix': null, 'suffix': '-B'},
        ],
      };

      final persona = PublicPersona.fromJson(json);
      expect(persona.id, 'pub_2');
      expect(persona.name, 'Bob');
      expect(persona.avatarUrl, 'hash_123');
      expect(persona.systemName, 'Bob Tag');
      expect(persona.personaTags.length, 1);
      expect(persona.personaTags.first.suffix, '-B');
      expect(persona.autoTagDisabled, isFalse);
    });

    test('copyWith updates fields while preserving existing values', () {
      const original = PublicPersona(
        id: 'p1',
        name: 'Original',
        bio: 'Old bio',
      );

      final updated = original.copyWith(
        name: 'New Name',
        bio: 'New bio',
        color: 0xFFFFFF,
      );

      expect(updated.id, 'p1');
      expect(updated.name, 'New Name');
      expect(updated.bio, 'New bio');
      expect(updated.color, 0xFFFFFF);

      final untouched = original.copyWith();
      expect(untouched.id, original.id);
      expect(untouched.name, original.name);
      expect(untouched.bio, original.bio);
    });
  });
}
