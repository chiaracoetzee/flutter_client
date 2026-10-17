import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/features/chat/domain/message.dart'
    show MessageDeliveryState;
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

/// Caches messages as the app does, keyed by id, in channel `c1` unless told.
Future<void> _cache(
  Database raw,
  Map<String, String> contentById, {
  String channelId = 'c1',
  String embedsJson = '[]',
  String snapshotsJson = '[]',
  MessageDeliveryState state = MessageDeliveryState.sent,
}) async {
  final FluxerDatabase db = FluxerDatabase.forTesting(
    NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
  );
  await db.batch((drift.Batch batch) {
    batch.insertAll(db.messages, <MessagesCompanion>[
      for (final MapEntry<String, String> entry in contentById.entries)
        MessagesCompanion.insert(
          id: entry.key,
          channelId: channelId,
          authorId: 'u1',
          content: entry.value,
          timestamp: DateTime.utc(2026, 10, 16),
          embedsJson: drift.Value(embedsJson),
          messageSnapshotsJson: drift.Value(snapshotsJson),
          deliveryState: drift.Value(state.index),
        ),
    ]);
  });
  await db.close();
}

Set<String> _cachedIds(Database raw) => raw
    .select('SELECT id FROM messages')
    .map((Row row) => row['id'] as String)
    .toSet();

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
      // Opening also runs any step upstream has added since.
      expect(
        raw.select('PRAGMA user_version').single['user_version'],
        db.schemaVersion,
      );
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

    test('an existing database gains the table of known personas', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      raw.execute('DROP TABLE known_personas');

      await _open(raw);

      expect(_columns(raw, 'known_personas'), contains('name'));
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

  group('cached messages from before the table of known personas', () {
    // A database with messages cached, as the app caches them.
    Future<Database> cachedDatabase() async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      return raw;
    }

    // What a build without the table left. Run after caching: opening the
    // database to cache creates the table again.
    void withoutKnownPersonas(Database raw) =>
        raw.execute('DROP TABLE known_personas');

    test('lose the messages that mention a persona, so the server sends them '
        'again with the persona named', () async {
      final Database raw = await cachedDatabase();
      await _cache(raw, <String, String>{
        'content': 'hi <@1:2>',
        'nick-form': 'hi <@!1:2>',
        'account': 'hi <@1>',
        'plain': 'hello',
        'zero-width': 'hi <@1:> or <@:2>',
      });
      await _cache(raw, <String, String>{
        'embed': 'link',
      }, embedsJson: '[{"description":"by <@3:4>"}]');
      await _cache(raw, <String, String>{
        'forward': '',
      }, snapshotsJson: '[{"content":"<@5:6> said"}]');
      await _cache(raw, <String, String>{
        'other-channel': '<@7:8>',
      }, channelId: 'c2');

      withoutKnownPersonas(raw);
      await _open(raw);

      expect(_columns(raw, 'known_personas'), contains('name'));
      expect(_cachedIds(raw), <String>{'account', 'plain', 'zero-width'});
    });

    test('keep a message still being sent or that failed to send', () async {
      final Database raw = await cachedDatabase();
      await _cache(raw, <String, String>{
        'sending': 'hi <@1:2>',
      }, state: MessageDeliveryState.sending);
      await _cache(raw, <String, String>{
        'failed': 'hi <@1:2>',
      }, state: MessageDeliveryState.failed);

      await _cache(raw, <String, String>{'sent': 'hi <@1:2>'});
      withoutKnownPersonas(raw);
      await _open(raw);

      expect(_cachedIds(raw), <String>{'sending', 'failed'});
    });

    test('are all dropped, however many there are', () async {
      final Database raw = await cachedDatabase();
      await _cache(raw, <String, String>{
        for (var i = 0; i < 1201; i++) '$i': '<@1:$i>',
        'kept': 'hello',
      });

      withoutKnownPersonas(raw);
      await _open(raw);

      expect(_cachedIds(raw), <String>{'kept'});
    });

    test(
      'are dropped once: later messages that mention a persona stay',
      () async {
        final Database raw = await cachedDatabase();
        await _cache(raw, <String, String>{'earlier': 'hi <@1:2>'});
        withoutKnownPersonas(raw);
        await _open(raw);
        await _cache(raw, <String, String>{'later': 'hi <@1:2>'});

        await _open(raw);

        expect(_cachedIds(raw), <String>{'later'});
      },
    );

    test('are dropped by an install that also takes upstream steps', () async {
      final Database raw = await cachedDatabase();
      await _cache(raw, <String, String>{
        'persona': 'hi <@1:2>',
        'plain': 'hello',
      });
      withoutKnownPersonas(raw);
      raw.execute('PRAGMA user_version = 97');

      await _open(raw);

      expect(_cachedIds(raw), <String>{'plain'});
      expect(_columns(raw, 'known_personas'), contains('name'));
    });

    test('are not touched in a new database', () async {
      final Database raw = sqlite3.openInMemory();
      addTearDown(raw.close);
      await _open(raw);
      await _cache(raw, <String, String>{'new': 'hi <@1:2>'});

      await _open(raw);

      expect(_cachedIds(raw), <String>{'new'});
    });
  });
}
