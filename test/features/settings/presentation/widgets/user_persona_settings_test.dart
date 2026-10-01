import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/presentation/widgets/user_persona_settings.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/shell/providers/current_user_private_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_dart/export.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_fluxer_app.dart';

class _MockDioAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _createMockDio() {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'));
  dio.httpClientAdapter = _MockDioAdapter();
  return dio;
}

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

class _FixedCurrentUserPrivate extends CurrentUserPrivateRead {
  _FixedCurrentUserPrivate([this._user]);

  final UserPrivateResponse? _user;

  @override
  UserPrivateResponse? build() => _user;
}

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._initial);

  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_initial);

  @override
  Future<void> reloadSilently() async {}

  @override
  void removePersona(String id) {
    final current = state.asData?.value ?? [];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }
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

class _FakeSystemDisplayTagNotifier extends SystemDisplayTagNotifier {
  _FakeSystemDisplayTagNotifier(this._initial);

  final SystemDisplayTag _initial;

  @override
  SystemDisplayTag build() => _initial;

  @override
  Future<void> updateDisplayTag(String? text, String? iconUrl) async {
    state = SystemDisplayTag(text: text, iconUrl: iconUrl);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const personaAlpha = Persona(
    id: 'p_alpha',
    name: 'Alpha Alter',
    pronouns: 'they/them',
    bio: 'Primary front',
    personaTags: [
      PersonaTag(prefix: 'a:', suffix: ''),
    ],
  );

  const personaBeta = Persona(
    id: 'p_beta',
    name: 'Beta Alter',
    pronouns: 'she/her',
    bio: 'Co-front',
    personaTags: [
      PersonaTag(prefix: '[', suffix: ']'),
    ],
  );

  final allPersonas = [personaAlpha, personaBeta];

  Widget buildTestBed({
    List<Persona> personas = const [],
    SystemDisplayTag initialTag = const SystemDisplayTag(),
  }) {
    return pumpFluxerApp(
      overrides: [
        fluxerDioProvider.overrideWithValue(_createMockDio()),
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        currentUserPrivateReadProvider.overrideWith(
          () => _FixedCurrentUserPrivate(null),
        ),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(personas)),
        personaSettingsProvider.overrideWith(_FakePersonaSettingsNotifier.new),
        systemDisplayTagProvider.overrideWith(
          () => _FakeSystemDisplayTagNotifier(initialTag),
        ),
      ],
      child: const Scaffold(
        body: UserPersonaSettings(),
      ),
    );
  }

  Future<void> pumpSettings(
    WidgetTester tester, {
    List<Persona> personas = const [],
    SystemDisplayTag initialTag = const SystemDisplayTag(),
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
        initialTag: initialTag,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('UserPersonaSettings', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders sections, mode options, and empty state when no personas', (tester) async {
      await pumpSettings(tester, personas: const []);

      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Last Used'), findsOneWidget);
      expect(find.text('CHAT PREVIEW'), findsOneWidget);
      expect(
        find.text('No personas configured yet. Create one via Manage Personas.'),
        findsOneWidget,
      );
    });

    testWidgets('renders configured personas list with details and actions', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      expect(find.text('Configured Personas (2)'), findsOneWidget);
      expect(find.text('Alpha Alter'), findsOneWidget);
      expect(find.text('(they/them)'), findsOneWidget);
      expect(find.text('a:text'), findsOneWidget);
      expect(find.text('Primary front'), findsOneWidget);

      expect(find.text('Beta Alter'), findsOneWidget);
      expect(find.text('(she/her)'), findsOneWidget);
      expect(find.text('[text]'), findsOneWidget);
      expect(find.text('Co-front'), findsOneWidget);

      // Both personas have Set Active, Edit, and Delete buttons
      expect(find.text('Set Active'), findsNWidgets(2));
      expect(find.byIcon(PhosphorIconsBold.pencilSimple), findsNWidgets(2));
      expect(find.byIcon(PhosphorIconsBold.trash), findsNWidgets(2));
    });

    testWidgets('filters personas using search query and shows empty search', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      // Search input is the second FluxerInput on screen (first is display tag)
      final searchInputs = find.byType(TextField);
      expect(searchInputs, findsNWidgets(2));
      final searchField = searchInputs.at(1);

      await tester.enterText(searchField, 'Alpha');
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsOneWidget);
      expect(find.text('Beta Alter'), findsNothing);

      // Search by pronouns
      await tester.enterText(searchField, 'she/her');
      await tester.pumpAndSettle();

      expect(find.text('Alpha Alter'), findsNothing);
      expect(find.text('Beta Alter'), findsOneWidget);

      // Non-existent search
      await tester.enterText(searchField, 'UnknownName');
      await tester.pumpAndSettle();

      expect(find.text('No matching personas found.'), findsOneWidget);
    });

    testWidgets('toggles persona active latch state', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      expect(find.text('Set Active'), findsNWidgets(2));
      expect(find.text('Active'), findsNothing);

      // Tap Set Active on first persona (Alpha)
      await tester.tap(find.text('Set Active').first);
      await tester.pumpAndSettle();

      // Now Alpha Alter is Active
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Set Active'), findsOneWidget);

      // Tapping Active unlatches it
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsNothing);
      expect(find.text('Set Active'), findsNWidgets(2));
    });

    testWidgets('editing display tag activates save bar and allows reset', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      final displayTagField = find.byType(TextField).first;
      expect(tester.widget<TextField>(displayTagField).controller?.text, isEmpty);

      // Enter a new display tag
      await tester.enterText(displayTagField, '[SYS]');
      await tester.pumpAndSettle();

      // SaveBar should be visible
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(displayTagField).controller?.text, isEmpty);
    });

    testWidgets('saving display tag updates state and hides save bar', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      final displayTagField = find.byType(TextField).first;
      await tester.enterText(displayTagField, '[MY-SYS]');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // SaveBar resets
      expect(tester.widget<TextField>(displayTagField).controller?.text, '[MY-SYS]');
    });

    testWidgets('delete persona button shows modal and removes persona on confirm', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      expect(find.text('Beta Alter'), findsOneWidget);

      // Tap trash button for Beta Alter (second trash icon)
      final trashButtons = find.byIcon(PhosphorIconsBold.trash);
      await tester.tap(trashButtons.at(1));
      await tester.pumpAndSettle();

      // Confirmation modal
      expect(find.text('Delete Persona'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Beta Alter is removed from the list
      expect(find.text('Beta Alter'), findsNothing);
      expect(find.text('Alpha Alter'), findsOneWidget);
    });

    testWidgets('switches persona mode to Last Used via radio item', (tester) async {
      await pumpSettings(tester, personas: allPersonas);

      await tester.tap(find.text('Last Used'));
      await tester.pumpAndSettle();
    });

    testWidgets('removing tag icon marks sheet dirty and shows save bar', (tester) async {
      await pumpSettings(
        tester,
        personas: allPersonas,
        initialTag: const SystemDisplayTag(
          text: '[SYS]',
          iconUrl: 'https://example.com/icon.png',
        ),
      );

      expect(find.text('Remove Icon'), findsOneWidget);

      await tester.tap(find.text('Remove Icon'));
      await tester.pumpAndSettle();

      // SaveBar becomes visible
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
