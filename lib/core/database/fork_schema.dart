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

  // Fork builds before the rebase of 9 October 2026 used schema version 92 for
  // `persona_tag_icon`. Upstream then used 92 for the two columns below, so
  // those installs never ran upstream's step.
  final Set<String> preferenceColumns = await _columnsOf(
    database,
    'user_preferences',
  );
  final List<GeneratedColumn<Object>> skippedUpstreamColumns =
      <GeneratedColumn<Object>>[
        database.userPreferencesTable.syncThemeColorsFromThemeStudio,
        database.userPreferencesTable.syncThemeColorsToThemeStudio,
      ];
  for (final GeneratedColumn<Object> column in skippedUpstreamColumns) {
    if (!preferenceColumns.contains(column.name)) {
      await migrator.addColumn(database.userPreferencesTable, column);
    }
  }
}

Future<Set<String>> _columnsOf(FluxerDatabase database, String table) async {
  final List<QueryRow> rows = await database
      .customSelect('PRAGMA table_info($table)')
      .get();
  return rows.map((QueryRow row) => row.read<String>('name')).toSet();
}
