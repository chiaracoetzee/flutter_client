// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/presentation/sheets/edit_persona_sheet.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/input/fluxer_input.dart';
import 'package:fluxer_app/features/ui/settings/fluxer_save_bar.dart';
import 'package:fluxer_app/features/ui/toast/toast_provider.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../../helpers/pump_fluxer_app.dart';

class _FakeUserSettings extends UserSettingsViewModel {
  @override
  UserSettingsViewState build() => const UserSettingsViewState(
        userId: '1',
        username: 'tester',
        displayName: 'Tester',
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
  _FakeMyPersonasNotifier([this._initial = const []]);

  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_initial);

  @override
  Future<void> reloadSilently() async {}
}

class _FakeSystemDisplayTagNotifier extends SystemDisplayTagNotifier {
  @override
  SystemDisplayTag build() => const SystemDisplayTag(text: 'SYS');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const existingPersona = Persona(
    id: 'existing_p1',
    name: 'Existing Alter',
    personaTags: [
      PersonaTag(prefix: '[', suffix: ']'),
    ],
  );

  Widget buildTestBed({
    PublicPersona? persona,
    List<Persona> otherPersonas = const [],
    void Function(WidgetRef ref)? onRef,
  }) {
    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(otherPersonas)),
        systemDisplayTagProvider.overrideWith(_FakeSystemDisplayTagNotifier.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          onRef?.call(ref);
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const ValueKey('open_btn'),
                onPressed: () => EditPersonaSheet.show(context, persona: persona),
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> openSheet(
    WidgetTester tester, {
    PublicPersona? persona,
    List<Persona> otherPersonas = const [],
    void Function(WidgetRef ref)? onRef,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildTestBed(
        persona: persona,
        otherPersonas: otherPersonas,
        onRef: onRef,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_btn')));
    await tester.pumpAndSettle();
  }

  bool isSaveBarVisible(WidgetTester tester) {
    final saveBar = tester.widget<FluxerSaveBar>(find.byType(FluxerSaveBar));
    return saveBar.visible;
  }

  group('EditPersonaSheet - Creation Mode', () {
    testWidgets('renders create persona form with default fields', (tester) async {
      await openSheet(tester);

      expect(find.text('Create Persona'), findsOneWidget);
      expect(find.byType(FluxerInput), findsWidgets);
      expect(find.text('Persona Tags'), findsOneWidget);
      expect(find.text('Add Tag Pair (1/5)'), findsOneWidget);
      expect(isSaveBarVisible(tester), isFalse);
    });

    testWidgets('typing in name field triggers dirty state and displays SaveBar', (tester) async {
      await openSheet(tester);

      // Name field is index 1
      final nameInput = find.byType(TextField).at(1);
      await tester.enterText(nameInput, 'New Persona Name');
      await tester.pumpAndSettle();

      expect(isSaveBarVisible(tester), isTrue);

      // Tapping Reset reverts changes and hides SaveBar
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(isSaveBarVisible(tester), isFalse);
    });

    testWidgets('adding and removing tag pairs updates list', (tester) async {
      await openSheet(tester);

      final addTagBtn = find.text('Add Tag Pair (1/5)');
      expect(addTagBtn, findsOneWidget);
      await tester.tap(addTagBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Tag Pair (2/5)'), findsOneWidget);
    });

    testWidgets('validates required name on save', (tester) async {
      WidgetRef? capturedRef;
      await openSheet(tester, onRef: (ref) => capturedRef = ref);

      // Add a non-empty tag prefix (index 3) to make form dirty while name is empty
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(3), 'tag:');
      await tester.pumpAndSettle();

      expect(isSaveBarVisible(tester), isTrue);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final toasts = capturedRef!.read(toastProvider);
      expect(toasts, isNotEmpty);
      expect(toasts.any((t) => t.toast.message.contains('persona display name')), isTrue);
    });

    testWidgets('validates tag collision against existing personas', (tester) async {
      WidgetRef? capturedRef;
      await openSheet(
        tester,
        otherPersonas: const [existingPersona],
        onRef: (ref) => capturedRef = ref,
      );

      final textFields = find.byType(TextField);
      // Name is index 1
      await tester.enterText(textFields.at(1), 'Colliding Alter');
      // Tag 1 Prefix is index 3, Suffix is index 4
      await tester.enterText(textFields.at(3), '[');
      await tester.enterText(textFields.at(4), ']');
      await tester.pumpAndSettle();

      expect(isSaveBarVisible(tester), isTrue);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final toasts = capturedRef!.read(toastProvider);
      expect(toasts, isNotEmpty);
      expect(
        toasts.any((t) => t.toast.message.contains('already used by') || t.toast.message.contains('Existing Alter')),
        isTrue,
      );
    });

    testWidgets('validates duplicate tag pairs on the same persona', (tester) async {
      WidgetRef? capturedRef;
      await openSheet(tester, onRef: (ref) => capturedRef = ref);

      final textFields = find.byType(TextField);
      // Name is index 1
      await tester.enterText(textFields.at(1), 'Valid Name');
      // Tag 1 Prefix is index 3
      await tester.enterText(textFields.at(3), '{');

      // Add second tag pair
      await tester.tap(find.text('Add Tag Pair (1/5)'));
      await tester.pumpAndSettle();

      final updatedFields = find.byType(TextField);
      // Second tag pair prefix is now index 5
      await tester.enterText(updatedFields.at(5), '{');
      await tester.pumpAndSettle();

      expect(isSaveBarVisible(tester), isTrue);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final toasts = capturedRef!.read(toastProvider);
      expect(toasts, isNotEmpty);
      expect(toasts.any((t) => t.toast.message.contains('Duplicate tag pair')), isTrue);
    });
  });

  group('EditPersonaSheet - Edit Mode', () {
    const publicPersona = PublicPersona(
      id: 'p_test',
      name: 'Test Persona',
      pronouns: 'they/them',
      bio: 'Testing persona edit sheet',
      personaTags: [
        PersonaTag(prefix: 't:', suffix: ''),
      ],
      color: 0x5865F2,
    );

    testWidgets('renders existing persona details and delete button', (tester) async {
      await openSheet(tester, persona: publicPersona);

      expect(find.text('Edit Persona'), findsOneWidget);

      final textFields = find.byType(TextField);
      // Color is at 0, Name is at 1, Pronouns is at 2, Tag prefix at 3, Suffix at 4, Bio at 5
      final nameField = tester.widget<TextField>(textFields.at(1));
      expect(nameField.controller?.text, 'Test Persona');

      final pronounsField = tester.widget<TextField>(textFields.at(2));
      expect(pronounsField.controller?.text, 'they/them');

      final bioField = tester.widget<TextField>(textFields.at(5));
      expect(bioField.controller?.text, 'Testing persona edit sheet');

      // Verify Delete Persona button exists
      final deleteButton = find.text('Delete Persona');
      expect(deleteButton, findsOneWidget);

      // Tap delete button to open confirmation dialog
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to delete "Test Persona"? This cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel dismissal
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsNothing);
    });
  });
}
