// Fork: tests the fork adds, kept out of upstream's user_profile_view_test.dart so that file stays as
// upstream has it.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart' show User;
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/auth/providers/account_manager_provider.dart';
import 'package:fluxer_app/features/friends/data/friend_repository.dart';
import 'package:fluxer_app/features/friends/domain/friend.dart';
import 'package:fluxer_app/features/friends/providers/friend_providers.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/presentation/widgets/user_profile_view.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/user_note_view_model.dart';
import 'package:fluxer_app/features/profile/providers/user_presence_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/toast/fluxer_toast_overlay.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/providers/user_profile.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:fluxer_dart/export.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../helpers/instance_runtime_config_override.dart';
import '../../../../helpers/test_l10n.dart';

const String _kUserId = '1';

class _FakeUserSettings extends UserSettingsViewModel {
  _FakeUserSettings({
    this.premiumType,
    this.premiumSince,
    this.premiumBadgeTimestampHidden = false,
  });

  final int? premiumType;
  final String? premiumSince;
  final bool premiumBadgeTimestampHidden;

  @override
  UserSettingsViewState build() => UserSettingsViewState(
    userId: _kUserId,
    username: 'tester',
    displayName: 'Tester',
    discriminator: '0001',
    avatar: null,
    avatarColor: null,
    memberSince: null,
    status: 'online',
    messageDisplayCompact: false,
    developerMode: false,
    trustedDomains: const <String>[],
    premiumType: premiumType,
    premiumSince: premiumSince,
    premiumBadgeTimestampHidden: premiumBadgeTimestampHidden,
  );
}

class _FakeCurrentUserFullProfile extends CurrentUserFullProfile {
  @override
  UserProfileFullResponse? build() => null;
}

class _FakeAccountManager extends AccountManager {
  @override
  AccountManagerState build() =>
      const AccountManagerState(accounts: [], isSwitching: false);

  @override
  Future<void> loadAccounts() async {}
}

class _FakeUserNoteViewModel extends UserNoteViewModel {
  @override
  Stream<String?> build({required String userId}) =>
      Stream<String?>.value(null);
}

class _FakeFriendRepository implements FriendRepository {
  @override
  Stream<List<Friend>> watchRelationships() =>
      Stream<List<Friend>>.value(const <Friend>[]);

  @override
  Future<List<Friend>> getRelationships() async => const <Friend>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._initial);
  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncValue.data(_initial);
}

User _onlineUser() {
  return const User(
    id: _kUserId,
    username: 'tester',
    discriminator: '0001',
    bot: false,
    system: false,
    status: 'online',
    mobile: false,
  );
}

CurrentUserCachedProfile _cachedProfile() {
  return const CurrentUserCachedProfile(
    id: _kUserId,
    username: 'tester',
    discriminator: '0001',
    globalName: 'Tester',
    avatar: null,
    avatarColor: null,
    bio: null,
    pronouns: null,
    accentColor: null,
    banner: null,
    publicFlags: 0,
  );
}

List<Override> _overrides({UserSettingsViewModel Function()? settings}) {
  return <Override>[
    instanceRuntimeConfigOverride(),
    userSettingsViewModelProvider.overrideWith(
      settings ?? _FakeUserSettings.new,
    ),
    accountManagerProvider.overrideWith(_FakeAccountManager.new),
    friendRepositoryProvider.overrideWithValue(_FakeFriendRepository()),
    userPresenceProvider(
      _kUserId,
    ).overrideWith((Ref ref) => Stream<User?>.value(_onlineUser())),
    userNoteViewModelProvider(
      userId: _kUserId,
    ).overrideWith(_FakeUserNoteViewModel.new),
    currentUserCachedProfileProvider.overrideWithValue(_cachedProfile()),
    currentUserFullProfileProvider.overrideWith(
      _FakeCurrentUserFullProfile.new,
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FluxerHaptics.enabled = false;
  });

  tearDown(() {
    FluxerHaptics.enabled = true;
  });

  testWidgets(
    'own persona profile resolves from myPersonasProvider and displays edit button',
    (tester) async {
      final ScrollController scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      const testPersona = Persona(
        id: 'persona_1',
        name: 'Sneaks Test',
        bio: 'Sneaky bio',
        personaTags: [PersonaTag(prefix: 'Snk:')],
      );

      final colorTheme = buildDarkColorTheme();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._overrides(),
            myPersonasProvider.overrideWith(
              () => _FakeMyPersonasNotifier([testPersona]),
            ),
          ],
          child: MaterialApp(
            locale: kTestLocale,
            localizationsDelegates: FluxerLocalizations.localizationsDelegates,
            supportedLocales: FluxerLocalizations.supportedLocales,
            theme: buildFluxerTheme(
              colorTheme: colorTheme,
              textTheme: FluxerTextTheme.fromColors(colorTheme),
              layoutTheme: FluxerLayoutTheme.scaled(),
            ),
            home: FluxerToastOverlay(
              child: Scaffold(
                body: UserProfileView(
                  userId: _kUserId,
                  personaId: 'persona_1',
                  autoFocusNote: false,
                  scrollController: scrollController,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sneaks Test'), findsOneWidget);
      expect(find.text(testL10n.fork.personaEditPersona), findsOneWidget);
    },
  );
}
