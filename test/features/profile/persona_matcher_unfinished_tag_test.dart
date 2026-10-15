import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/shared/utils/emoji_registry.dart';

// The web client's copy of this function is `isUnfinishedPersonaTag` in the
// monorepo's `PersonaMatcher.ts`. Its test runs the same table: change both
// together.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EmojiRegistry.preload();
  });

  const List<Persona> personas = <Persona>[
    Persona(
      id: 'caly',
      name: 'Caly',
      personaTags: [PersonaTag(prefix: 'c:')],
    ),
    Persona(
      id: 'alex',
      name: 'Alex',
      personaTags: [PersonaTag(prefix: 'alex> ')],
    ),
    Persona(
      id: 'long',
      name: 'Long',
      personaTags: [PersonaTag(prefix: 'c:c:')],
    ),
    Persona(
      id: 'box',
      name: 'Box',
      personaTags: [PersonaTag(prefix: '[', suffix: ']')],
    ),
    Persona(
      id: 'dash',
      name: 'Dash',
      personaTags: [PersonaTag(suffix: ' -d')],
    ),
    Persona(
      id: 'off',
      name: 'Off',
      personaTags: [PersonaTag(prefix: 'off:')],
      autoTagDisabled: true,
    ),
  ];

  const List<(String, String?, bool, String)>
  cases = <(String, String?, bool, String)>[
    ('c', null, true, "the start of Caly's tag"),
    ('c', 'caly', true, "Caly is latched, but it could still be Long's tag"),
    ('c:', 'caly', true, "all of Caly's tag, and still the start of Long's"),
    ('c:c', 'caly', true, "one character short of Long's tag"),
    ('c:c:', 'long', false, "all of Long's tag"),
    ('c: hi', 'caly', false, 'past every tag'),
    ('ca', null, false, 'not the start of any tag'),
    ('a', null, true, "the start of Alex's tag"),
    ('alex', null, true, "most of Alex's tag"),
    ('alex>', 'alex', false, "all of Alex's tag but its trailing space"),
    ('al', 'alex', false, 'the tag of the persona it already resolves to'),
    ('alexa', null, false, "ran past Alex's tag"),
    ('[', null, false, 'a tag with a suffix is not held back'),
    ('[hello', null, false, 'a tag with a suffix is not held back'),
    ('hello -', null, false, 'a suffix cannot be seen coming'),
    ('o', null, false, "that persona's tags are switched off"),
    ('off', null, false, "that persona's tags are switched off"),
    ('', null, false, 'nothing typed'),
    ('   ', null, false, 'only spaces'),
    (' c', null, true, 'leading space is ignored, as the matcher does'),
    ('C', null, false, 'tags are case-sensitive'),
  ];

  for (final (String text, String? current, bool expected, String why)
      in cases) {
    test('"$text" resolving to $current gives $expected: $why', () {
      expect(isUnfinishedPersonaTag(text, personas, current), expected);
    });
  }

  test(
    'never holds back text that the matcher already gives to that tag alone',
    () {
      const List<Persona> only = <Persona>[
        Persona(
          id: 'caly',
          name: 'Caly',
          personaTags: [PersonaTag(prefix: 'c:')],
        ),
      ];
      for (final String text in <String>['c:', 'c: ', 'c:hello', 'c: hello']) {
        final PreviewResult preview = previewPersona(
          text,
          only,
          null,
          hasAttachments: false,
        );
        expect(preview.persona?.id, 'caly');
        expect(
          isUnfinishedPersonaTag(text, only, preview.persona?.id),
          isFalse,
        );
      }
    },
  );
}
