import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:sqlite3/sqlite3.dart';

const List<String> _personaColumns = <String>[
  'persona_id',
  'persona_name',
  'persona_avatar',
  'persona_tag',
  'persona_tag_icon',
];

const List<String> _themeStudioColumns = <String>[
  'sync_theme_colors_from_theme_studio',
  'sync_theme_colors_to_theme_studio',
];

/// What upstream's step 91 adds, per table.
const Map<String, List<String>> _threadColumns = <String, List<String>>{
  'channels': <String>[
    'owner_id',
    'flags',
    'thread_archived',
    'thread_locked',
    'thread_invitable',
    'thread_auto_archive_duration',
    'thread_archive_timestamp',
    'thread_create_timestamp',
    'message_count',
    'total_message_sent',
    'member_count',
    'applied_tags_json',
    'default_auto_archive_duration',
    'default_thread_rate_limit_per_user',
    'available_tags_json',
    'default_reaction_emoji_json',
    'default_sort_order',
    'default_forum_layout',
    'default_tag_setting',
  ],
  'servers': <String>['thread_channels_active'],
  'messages': <String>['thread_json'],
  'read_states': <String>['flags', 'missing_since'],
};

bool _hasTable(Database raw, String table) => raw.select(
  "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
  <Object?>[table],
).isNotEmpty;

Set<String> _columns(Database raw, String table) => raw
    .select('PRAGMA table_info($table)')
    .map((Row row) => row['name'] as String)
    .toSet();

Future<int> _open(Database raw) async {
  final FluxerDatabase db = FluxerDatabase.forTesting(
    NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
  );
  // Any statement forces the lazy open.
  await db.customSelect('SELECT 1').get();
  final int version = db.schemaVersion;
  await db.close();
  return version;
}

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('fork schema', () {
    test('a new database has the fork columns', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      expect(_columns(raw, 'messages'), containsAll(_personaColumns));
    });

    test(
      'an upstream database at the current version gains the fork columns',
      () async {
        final Database raw = sqlite3.openInMemory();
        addTearDown(raw.close);
        final int version = await _open(raw);
        for (final String column in _personaColumns) {
          raw.execute('ALTER TABLE messages DROP COLUMN $column');
        }
        expect(
          _columns(raw, 'messages').intersection(_personaColumns.toSet()),
          isEmpty,
        );

        // No version change, so onUpgrade does not run.
        await _open(raw);

        expect(_columns(raw, 'messages'), containsAll(_personaColumns));
        expect(
          raw.select('PRAGMA user_version').single['user_version'],
          version,
        );
      },
    );

    test('an earlier fork build that used version 92 for its own column '
        'gains the columns of the upstream step it skipped', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      for (final String column in _themeStudioColumns) {
        raw.execute('ALTER TABLE user_preferences DROP COLUMN $column');
      }
      raw.execute('PRAGMA user_version = 92');

      await _open(raw);

      expect(
        _columns(raw, 'user_preferences'),
        containsAll(_themeStudioColumns),
      );
      expect(_columns(raw, 'messages'), containsAll(_personaColumns));
    });

    test('an earlier fork build that used versions 91 and 92 for its own '
        'columns gains the thread tables of the upstream step it skipped, '
        'and can store a sync', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      // Take the database back to what such a build left: the fork's columns,
      // nothing from upstream's steps 91 and 92, and already at version 92.
      raw
        ..execute('DROP INDEX IF EXISTS idx_channels_guild_parent_type')
        ..execute('DROP TABLE thread_members');
      for (final MapEntry<String, List<String>> entry
          in _threadColumns.entries) {
        for (final String column in entry.value) {
          raw.execute('ALTER TABLE ${entry.key} DROP COLUMN $column');
        }
      }
      for (final String column in _themeStudioColumns) {
        raw.execute('ALTER TABLE user_preferences DROP COLUMN $column');
      }
      raw.execute('PRAGMA user_version = 92');
      expect(_hasTable(raw, 'thread_members'), isFalse);

      final FluxerDatabase db = FluxerDatabase.forTesting(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      addTearDown(db.close);
      // The statement the first sync failed on.
      await db.delete(db.threadMembers).go();

      expect(_hasTable(raw, 'thread_members'), isTrue);
      for (final MapEntry<String, List<String>> entry
          in _threadColumns.entries) {
        expect(_columns(raw, entry.key), containsAll(entry.value));
      }
      expect(
        _columns(raw, 'user_preferences'),
        containsAll(_themeStudioColumns),
      );
      expect(_columns(raw, 'messages'), containsAll(_personaColumns));
      expect(raw.select('PRAGMA user_version').single['user_version'], 92);
    });

    test('an existing database gains the column for the persona a thread '
        'was started as', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      raw.execute('ALTER TABLE channels DROP COLUMN owner_persona_id');

      await _open(raw);

      expect(_columns(raw, 'channels'), contains('owner_persona_id'));
    });

    test('opening twice changes nothing the second time', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      raw.execute('ALTER TABLE messages DROP COLUMN persona_tag_icon');
      await _open(raw);
      final Set<String> afterFirst = _columns(raw, 'messages');
      await _open(raw);
      expect(_columns(raw, 'messages'), afterFirst);
    });
  });
}
