import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/threads/domain/fork_original_poster.dart';

void main() {
  group('forkOriginalPosterTagApplies', () {
    test(
      'the account is the original poster of a post it started as itself',
      () {
        expect(
          forkOriginalPosterTagApplies(
            messagePersonaId: null,
            threadOwnerPersonaId: null,
          ),
          isTrue,
        );
      },
    );

    test('the account is not, on a post it started as a persona', () {
      expect(
        forkOriginalPosterTagApplies(
          messagePersonaId: null,
          threadOwnerPersonaId: 'fox',
        ),
        isFalse,
      );
    });

    test('the persona that started the post is the original poster', () {
      expect(
        forkOriginalPosterTagApplies(
          messagePersonaId: 'fox',
          threadOwnerPersonaId: 'fox',
        ),
        isTrue,
      );
    });

    test('another persona of the same account is not', () {
      expect(
        forkOriginalPosterTagApplies(
          messagePersonaId: 'owl',
          threadOwnerPersonaId: 'fox',
        ),
        isFalse,
      );
    });

    test('a persona is not when the post was started as the account', () {
      expect(
        forkOriginalPosterTagApplies(
          messagePersonaId: 'fox',
          threadOwnerPersonaId: '',
        ),
        isFalse,
      );
    });
  });
}
