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
