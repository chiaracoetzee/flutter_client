// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/persona_composer_pill.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helpers/pump_fluxer_app.dart';

class _FakeUserSettings extends UserSettingsViewModel {
  @override
  UserSettingsViewState build() => const UserSettingsViewState(
        userId: '1',
        username: 'tester',
        displayName: 'Root User',
        discriminator: '0001',
        avatar: null,
        avatarColor: null,
        memberSince: null,
        status: 'online',
        messageDisplayCompact: false,
        developerMode: false,
        trustedDomains: <String>[],
      );
}

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._initial);

  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_initial);

  @override
  Future<void> reloadSilently() async {}
}

class _FakeActivePersonaNotifier extends ActivePersonaNotifier {
  _FakeActivePersonaNotifier({this.initialLatchedId});

  final String? initialLatchedId;

  @override
  ActivePersonaState build() => ActivePersonaState(
        isLatched: initialLatchedId != null,
        activePersonaId: initialLatchedId,
      );
}

class _FakePersonaSettingsNotifier extends PersonaSettingsNotifier {
  @override
  AsyncValue<PersonaSettings> build() => const AsyncData(PersonaSettings());

  @override
  Future<void> reloadSilently() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const personaAlpha = Persona(
    id: 'p_alpha',
    name: 'Alpha Alter',
    pronouns: 'they/them',
    personaTags: [
      PersonaTag(prefix: 'a:', suffix: ''),
    ],
  );

  const personaBeta = Persona(
    id: 'p_beta',
    name: 'Beta Alter',
    pronouns: 'she/her',
    personaTags: [
      PersonaTag(prefix: '[', suffix: ']'),
    ],
  );

  final allPersonas = [personaAlpha, personaBeta];

  Widget buildTestBed({
    List<Persona> personas = const [],
    String? latchedPersonaId,
    String text = '',
    bool hasAttachments = false,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(personas)),
        activePersonaProvider.overrideWith(
          () => _FakeActivePersonaNotifier(initialLatchedId: latchedPersonaId),
        ),
        personaSettingsProvider.overrideWith(_FakePersonaSettingsNotifier.new),
      ],
      child: Scaffold(
        body: Center(
          child: PersonaComposerPill(
            text: text,
            hasAttachments: hasAttachments,
          ),
        ),
      ),
    );
  }

  group('PersonaComposerPill', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders SizedBox.shrink when user has no personas', (tester) async {
      await tester.pumpWidget(buildTestBed(personas: const []));
      await tester.pumpAndSettle();

      expect(find.byType(Tooltip), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders root user state with root tooltip when unlatched and no tag match', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          personas: allPersonas,
          latchedPersonaId: null,
          text: 'Hello world',
        ),
      );
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Sending as @tester');

      // No lock badge, no tag badge
      expect(find.byIcon(PhosphorIconsBold.lockSimple), findsNothing);
      expect(find.byIcon(PhosphorIconsBold.tag), findsNothing);
    });

    testWidgets('renders latched persona with lock badge and latched tooltip', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          personas: allPersonas,
          latchedPersonaId: 'p_alpha',
          text: 'Hello world',
        ),
      );
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Sending as Alpha Alter (Latched)');

      // Lock badge is present, tag badge is absent
      expect(find.byIcon(PhosphorIconsBold.lockSimple), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.tag), findsNothing);
    });

    testWidgets('renders tag matched persona with tag badge and tag tooltip', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          personas: allPersonas,
          latchedPersonaId: null,
          text: 'a: Hello world',
        ),
      );
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Sending as Alpha Alter (Matched by tag)');

      // Tag badge is present, lock badge is absent
      expect(find.byIcon(PhosphorIconsBold.tag), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.lockSimple), findsNothing);
    });

    testWidgets('tag match overrides latched persona indicator', (tester) async {
      await tester.pumpWidget(
        buildTestBed(
          personas: allPersonas,
          latchedPersonaId: 'p_alpha',
          text: '[Hello world]',
        ),
      );
      await tester.pumpAndSettle();

      // Matched Beta Alter via [text]
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Sending as Beta Alter (Matched by tag)');

      expect(find.byIcon(PhosphorIconsBold.tag), findsOneWidget);
      expect(find.byIcon(PhosphorIconsBold.lockSimple), findsNothing);
    });

    testWidgets('tapping pill opens PersonaPickerSheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestBed(
          personas: allPersonas,
          latchedPersonaId: 'p_alpha',
          text: 'Hello world',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PersonaComposerPill));
      await tester.pumpAndSettle();

      expect(find.text('Select Persona'), findsOneWidget);
    });
  });
}
