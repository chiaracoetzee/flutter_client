import 'package:drift/drift.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/features/chat/domain/message.dart'
    show MessageDeliveryState;

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
  await ensureForkMessageColumns(database, migrator);

  if (!(await _columnsOf(
    database,
    'channels',
  )).contains(database.channels.ownerPersonaId.name)) {
    await migrator.addColumn(
      database.channels,
      database.channels.ownerPersonaId,
    );
  }

  if (!(await _tableExists(database, database.knownPersonas.actualTableName))) {
    await migrator.createTable(database.knownPersonas);
    await _dropCachedMessagesMentioningPersonas(database);
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

/// Fork: adds the persona columns to `messages` when they are missing. Also run
/// by upstream's step 98 before it rebuilds the table from its definition,
/// which includes these columns (fluxer_database.dart).
Future<void> ensureForkMessageColumns(
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
}

/// Fork: drops the cached messages that mention a persona, once, when the
/// table of known personas is created.
///
/// A message from the server names the personas it mentions, and the device
/// keeps them in `known_personas` as it arrives. Messages cached before that
/// table existed were stored without them, so their persona mentions would show
/// the account's name. Dropping them has the server send them again with their
/// personas: the chat screen shows a channel's cached messages only until the
/// server's page arrives, and older ones only once the server has sent them in
/// this session.
///
/// Only messages the server has are dropped; one still being sent, or that
/// failed to send, stays. A mention in code is dropped too: it costs one more
/// message to fetch, and reading Markdown here is not worth that.
Future<void> _dropCachedMessagesMentioningPersonas(
  FluxerDatabase database,
) async {
  final RegExp personaMention = RegExp(r'<@!?\d+:\d+>');
  const String mayMention = "'%<@%:%>%'";
  final List<QueryRow> candidates = await database
      .customSelect(
        'SELECT rowid, content, embeds_json, message_snapshots_json '
        'FROM messages WHERE delivery_state = ? AND ( '
        'content LIKE $mayMention OR embeds_json LIKE $mayMention '
        'OR message_snapshots_json LIKE $mayMention)',
        variables: <Variable<Object>>[
          Variable<int>(MessageDeliveryState.sent.index),
        ],
      )
      .get();
  final List<int> rowIds = <int>[
    for (final QueryRow row in candidates)
      if (<String>['content', 'embeds_json', 'message_snapshots_json'].any(
        (String column) => personaMention.hasMatch(row.read<String>(column)),
      ))
        row.read<int>('rowid'),
  ];
  const int perStatement = 500;
  for (var start = 0; start < rowIds.length; start += perStatement) {
    final List<int> chunk = rowIds.skip(start).take(perStatement).toList();
    await database.customStatement(
      'DELETE FROM messages WHERE rowid IN '
      '(${List<String>.filled(chunk.length, '?').join(', ')})',
      chunk,
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

Future<bool> _tableExists(FluxerDatabase database, String table) async {
  final List<QueryRow> rows = await database
      .customSelect(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
        variables: <Variable<Object>>[Variable<String>(table)],
      )
      .get();
  return rows.isNotEmpty;
}

Future<Set<String>> _columnsOf(FluxerDatabase database, String table) async {
  final List<QueryRow> rows = await database
      .customSelect('PRAGMA table_info($table)')
      .get();
  return rows.map((QueryRow row) => row.read<String>('name')).toSet();
}
