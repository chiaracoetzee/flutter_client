// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/sheets/persona_picker_sheet.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_fluxer_app.dart';

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

class _FakePersonaSettingsNotifier extends PersonaSettingsNotifier {
  @override
  AsyncValue<PersonaSettings> build() => const AsyncData(PersonaSettings());

  @override
  Future<void> reloadSilently() async {}

  @override
  Future<void> updateSettings({
    String? activePersonaMode,
    String? Function()? activePersonaId,
    bool? isLatched,
    String? displayTagText,
    String? Function()? displayTagIcon,
  }) async {
    final current = state.asData?.value ?? const PersonaSettings();
    final updated = current.copyWith(
      activePersonaMode: activePersonaMode,
      activePersonaId: activePersonaId,
      isLatched: isLatched,
      displayTagText: displayTagText,
      displayTagIcon: displayTagIcon,
    );
    state = AsyncValue.data(updated);
  }
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
    String? selectedPersonaId,
    bool showModes = true,
    ValueChanged<Persona>? onSelectPersona,
    VoidCallback? onSelectRoot,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(personas)),
        personaSettingsProvider.overrideWith(_FakePersonaSettingsNotifier.new),
      ],
      child: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              key: const ValueKey('open_picker_btn'),
              onPressed: () => PersonaPickerSheet.show(
                context,
                showModes: showModes,
                selectedPersonaId: selectedPersonaId,
                onSelectPersona: onSelectPersona,
                onSelectRoot: onSelectRoot,
              ),
              child: const Text('Open Picker'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPicker(
    WidgetTester tester, {
    List<Persona> personas = const [],
    String? selectedPersonaId,
    bool showModes = true,
    ValueChanged<Persona>? onSelectPersona,
    VoidCallback? onSelectRoot,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildTestBed(
        personas: personas,
        selectedPersonaId: selectedPersonaId,
        showModes: showModes,
        onSelectPersona: onSelectPersona,
        onSelectRoot: onSelectRoot,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_picker_btn')));
    await tester.pumpAndSettle();
  }

  group('PersonaPickerSheet', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders search input, root account, and configured personas', (tester) async {
      await openPicker(tester, personas: allPersonas);

      expect(find.text('Select Persona'), findsOneWidget);
      expect(find.text('Search personas, tags, pronouns...'), findsOneWidget);
      expect(find.text('Root Account (Default)'), findsOneWidget);
      expect(find.text('Alpha Alter'), findsWidgets);
      expect(find.text('Beta Alter'), findsWidgets);
      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('filters personas by search query', (tester) async {
      await openPicker(tester, personas: allPersonas);

      final searchInput = find.byType(TextField).first;
      await tester.enterText(searchInput, 'Alpha');
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsOneWidget);
      expect(find.text('Beta Alter'), findsNothing);

      // Search by proxy tag
      await tester.enterText(searchInput, '[');
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsNothing);
      expect(find.text('Beta Alter'), findsOneWidget);

      // Search with non-existent query shows empty state
      await tester.enterText(searchInput, 'NonExistentAlter');
      await tester.pumpAndSettle();

      expect(find.text('No matching personas found.'), findsOneWidget);
    });

    testWidgets('tapping persona triggers onSelectPersona callback', (tester) async {
      Persona? selected;
      await openPicker(
        tester,
        personas: allPersonas,
        onSelectPersona: (p) => selected = p,
      );

      await tester.tap(find.text('Alpha Alter').first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.id, 'p_alpha');
      expect(selected?.name, 'Alpha Alter');
    });

    testWidgets('tapping root account triggers onSelectRoot callback', (tester) async {
      bool rootSelected = false;
      await openPicker(
        tester,
        personas: allPersonas,
        onSelectRoot: () => rootSelected = true,
      );

      await tester.tap(find.text('Root Account (Default)'));
      await tester.pumpAndSettle();

      expect(rootSelected, isTrue);
    });

    testWidgets('switches between Manual and Last Used modes', (tester) async {
      await openPicker(tester, personas: allPersonas);

      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Last Used'), findsOneWidget);

      await tester.tap(find.text('Last Used'));
      await tester.pumpAndSettle();

      // Mode description updates
      expect(
        find.textContaining('Auto-switches to the persona used in your last message.'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when user has no personas', (tester) async {
      await openPicker(tester, personas: const []);

      expect(
        find.text('No personas configured yet. Create one via Manage Personas.'),
        findsOneWidget,
      );
    });

    testWidgets('hides mode selector tabs when showModes is false', (tester) async {
      await openPicker(tester, personas: allPersonas, showModes: false);

      expect(find.text('Manual'), findsNothing);
      expect(find.text('Last Used'), findsNothing);
    });

    testWidgets('clears search text when suffix clear icon is tapped', (tester) async {
      await openPicker(tester, personas: allPersonas);

      final searchInput = find.byType(TextField).first;
      await tester.enterText(searchInput, 'Alpha');
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsOneWidget);
      expect(find.text('Beta Alter'), findsNothing);

      // Tap suffix clear icon (PhosphorIconsBold.x)
      final clearIcon = find.byIcon(PhosphorIconsBold.x);
      expect(clearIcon, findsOneWidget);
      await tester.tap(clearIcon);
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsWidgets);
      expect(find.text('Beta Alter'), findsWidgets);
    });

    testWidgets('respects selectedPersonaId as active persona', (tester) async {
      await openPicker(tester, personas: allPersonas, selectedPersonaId: 'p_beta');

      // Both check icons: only 1 check icon should exist (on Beta Alter)
      expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);
    });

    testWidgets('renders persona name in standard primary text color even when persona has custom color', (tester) async {
      const coloredPersona = Persona(
        id: 'p_colored',
        name: 'Colored Alter',
        color: 0xFF8A2E, // 24-bit hex #FF8A2E
      );

      await openPicker(tester, personas: [coloredPersona]);

      final nameFinder = find.text('Colored Alter');
      expect(nameFinder, findsNWidgets(2)); // Once in recents, once in all personas

      final dynamic listTileText = tester.firstWidget(nameFinder.last);
      expect(listTileText.style?.color?.a, 1.0);
      expect(listTileText.style?.color, isNot(const Color(0x00FF8A2E)));
    });
  });
}
