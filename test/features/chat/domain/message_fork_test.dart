// Fork: tests the fork adds, kept out of upstream's message_test.dart so that file stays as
// upstream has it.

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/constants/user_flags.dart';

import 'message_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Message persona and deleted author resolution', () {
    test(
      'isDeletedAuthor checks user flags without relying on spoofable username strings or synthetic IDs',
      () {
        final normal = forkUpstream.message().copyWith(
          authorName: 'Alice',
          authorPublicFlags: 0,
        );
        expect(normal.isDeletedAuthor, isFalse);

        final staff = forkUpstream.message().copyWith(
          authorName: 'Chiara',
          authorPublicFlags: kUserFlagStaff,
        );
        expect(staff.isDeletedAuthor, isFalse);

        // Users setting their name or nickname to "Deleted User" should not be marked as deleted authors
        final byName = forkUpstream.message().copyWith(
          authorName: 'Deleted User',
          authorPublicFlags: 0,
        );
        expect(byName.isDeletedAuthor, isFalse);

        final byId = forkUpstream.message().copyWith(
          authorId: '1',
          authorName: 'Someone',
          authorPublicFlags: 0,
        );
        expect(byId.isDeletedAuthor, isFalse);

        final byFlagDeleted = forkUpstream.message().copyWith(
          authorName: 'Alice',
          authorPublicFlags: kUserFlagDeleted,
        );
        expect(byFlagDeleted.isDeletedAuthor, isTrue);

        final byFlagSelfDeleted = forkUpstream.message().copyWith(
          authorName: 'Alice',
          authorPublicFlags: kUserFlagSelfDeleted,
        );
        expect(byFlagSelfDeleted.isDeletedAuthor, isTrue);
      },
    );

    test(
      'isPersona returns true only for non-deleted authors with persona attributes',
      () {
        final normalUser = forkUpstream.message().copyWith(authorName: 'Alice');
        expect(normalUser.isPersona, isFalse);

        final personaUser = forkUpstream.message().copyWith(
          authorName: 'Alice',
          personaId: 'p1',
          personaName: 'Subprofile A',
        );
        expect(personaUser.isPersona, isTrue);

        final staffPersonaUser = personaUser.copyWith(
          authorName: 'Chiara',
          authorPublicFlags: kUserFlagStaff,
        );
        expect(staffPersonaUser.isPersona, isTrue);

        // Active user nicknamed "Deleted User" with active persona is not falsely stripped
        final nicknamedPersonaAuthor = personaUser.copyWith(
          authorName: 'Deleted User',
        );
        expect(nicknamedPersonaAuthor.isPersona, isTrue);

        // Truly flagged deleted root author suppresses persona
        final flaggedDeletedAuthor = personaUser.copyWith(
          authorPublicFlags: kUserFlagDeleted,
        );
        expect(flaggedDeletedAuthor.isPersona, isFalse);
      },
    );
  });
}
