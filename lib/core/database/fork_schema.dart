import 'package:drift/drift.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';

/// Fork: brings a database that already exists up to the columns this fork
/// adds, every time it is opened.
///
/// The fork does not take schema version numbers of its own. Upstream owns
/// `schemaVersion` and the `onUpgrade` steps; a fork step numbered alongside
/// them collides with the next step upstream adds, and an install that already
/// reached that number then skips upstream's step. Each check here is one
/// `PRAGMA table_info`, so running them on every open costs nothing that
/// matters, and a column is only ever added once.
Future<void> ensureForkSchema(
  FluxerDatabase database,
  Migrator migrator,
) async {
  final Set<String> messageColumns = await _columnsOf(database, 'messages');
  final List<GeneratedColumn<Object>> personaColumns =
      <GeneratedColumn<Object>>[
        database.messages.personaId,
        database.messages.personaName,
        database.messages.personaAvatar,
        database.messages.personaTag,
        database.messages.personaTagIcon,
      ];
  for (final GeneratedColumn<Object> column in personaColumns) {
    if (!messageColumns.contains(column.name)) {
      await migrator.addColumn(database.messages, column);
    }
  }

  // Fork builds before the rebase of 9 October 2026 numbered their own steps 91
  // and 92. Upstream then used those numbers for its thread tables and for two
  // user_preferences columns, so an install coming from such a build is already
  // "at 92" and never ran upstream's steps: it has no thread_members table and
  // cannot store the first sync.
  //
  // Those builds match upstream up to step 90, and upstream's steps check for
  // each column and table before adding it. So run upstream's own upgrade again
  // from 90 rather than keep a copy of what its steps add.
  if (await _skippedUpstreamSteps(database)) {
    await database.migration.onUpgrade(
      migrator,
      _lastStepSharedWithEarlierForkBuilds,
      database.schemaVersion,
    );
  }
}

const int _lastStepSharedWithEarlierForkBuilds = 90;

Future<bool> _skippedUpstreamSteps(FluxerDatabase database) async {
  final List<QueryRow> threadMembers = await database
      .customSelect(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' "
        "AND name = 'thread_members'",
      )
      .get();
  if (threadMembers.isEmpty) {
    return true;
  }
  final Set<String> preferenceColumns = await _columnsOf(
    database,
    'user_preferences',
  );
  return !preferenceColumns.contains(
    database.userPreferencesTable.syncThemeColorsToThemeStudio.name,
  );
}

Future<Set<String>> _columnsOf(FluxerDatabase database, String table) async {
  final List<QueryRow> rows = await database
      .customSelect('PRAGMA table_info($table)')
      .get();
  return rows.map((QueryRow row) => row.read<String>('name')).toSet();
}
