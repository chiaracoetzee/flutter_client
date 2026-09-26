// Fork: tests the fork adds, kept out of upstream's message_dao_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';

import '../../../helpers/open_test_database.dart';
import 'message_dao_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final String idA = forkUpstream.snowflakeForUtc(
    DateTime.utc(2026, 5, 10, 10),
  );
  final String idB = forkUpstream.snowflakeForUtc(
    DateTime.utc(2026, 5, 10, 11),
  );

  test(
    'updatePersonaAttributes updates cached message persona attributes in SQLite',
    () async {
      final db = openTestDatabase();
      final Message msg1 = forkUpstream
          .msg(idA)
          .copyWith(
            personaId: 'p_target',
            personaName: 'Alice Old',
            personaAvatar: 'avatar1',
            personaTag: '[Old]',
          );
      final Message msg2 = forkUpstream
          .msg(idB)
          .copyWith(personaId: 'p_other', personaName: 'Bob');
      await db.messageDao.upsertMessage(msg1.toCompanion());
      await db.messageDao.upsertMessage(msg2.toCompanion());

      await db.messageDao.updatePersonaAttributes(
        personaId: 'p_target',
        personaName: 'Alice New',
        personaAvatar: 'avatar2',
        personaTag: '[New]',
        personaTagIcon: 'icon2',
      );

      final Message row1 = Message.fromRow(
        (await db.messageDao.getMessage('ch', idA))!,
      );
      final Message row2 = Message.fromRow(
        (await db.messageDao.getMessage('ch', idB))!,
      );

      expect(row1.personaName, 'Alice New');
      expect(row1.personaAvatar, 'avatar2');
      expect(row1.personaTag, '[New]');
      expect(row1.personaTagIcon, 'icon2');

      // Untargeted persona should remain untouched
      expect(row2.personaName, 'Bob');
      expect(row2.personaAvatar, isNull);
    },
  );
}
