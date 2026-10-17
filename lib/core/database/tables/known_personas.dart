// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/drift.dart';

/// Fork: the personas this device has been told about, kept as upstream keeps
/// the accounts it has been told about in `users`: written from every message
/// that names a persona (the persona it was sent as, the personas it mentions)
/// and from the persona gateway events, and read to show persona mentions
/// without asking the server. A deleted persona keeps its row, as the server
/// keeps showing it as it was.
class KnownPersonas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatar => text().nullable()();
  IntColumn get avatarColor => integer().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get displayTagText => text().nullable()();
  TextColumn get displayTagIcon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
