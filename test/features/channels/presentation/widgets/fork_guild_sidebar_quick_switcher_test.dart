// SPDX-License-Identifier: AGPL-3.0-or-later

// The fork's quick switcher button in the guild sidebar (8f0c0c0aa). Its setup is a copy of
// the parts of upstream's guild_sidebar_test.dart it needs, so upstream's file stays as
// upstream has it.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show FluxerDatabase;
import 'package:fluxer_app/core/experiments/experiments_provider.dart';
import 'package:fluxer_app/core/permissions/channel_effective_permissions.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/router/route_kind.dart';
import 'package:fluxer_app/core/router/route_state_providers.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/channels/presentation/channel_settings/channel_settings_nav_page.dart';
import 'package:fluxer_app/features/channels/presentation/widgets/guild_sidebar.dart';
import 'package:fluxer_app/features/channels/providers/channel_list_view_model.dart';
import 'package:fluxer_app/features/channels/providers/channel_mute_provider.dart';
import 'package:fluxer_app/features/channels/providers/channel_settings_providers.dart';
import 'package:fluxer_app/features/channels/providers/channel_sidebar_icon_connect_bits_provider.dart';
import 'package:fluxer_app/features/channels/providers/guild_collapsed_categories_provider.dart';
import 'package:fluxer_app/features/channels/providers/unread_provider.dart';
import 'package:fluxer_app/features/dm/providers/dm_view_model.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/guilds/providers/guild_list_view_model.dart';
import 'package:fluxer_app/features/guilds/providers/guild_mute_provider.dart';
import 'package:fluxer_app/features/guilds/providers/guild_permissions_provider.dart';
import 'package:fluxer_app/features/guilds/providers/guild_read_state_provider.dart';
import 'package:fluxer_app/features/mature_content/domain/mature_content_types.dart';
import 'package:fluxer_app/features/mature_content/providers/mature_content_agreements_provider.dart';
import 'package:fluxer_app/features/mature_content/providers/sensitive_content_provider.dart';
import 'package:fluxer_app/features/members/data/member_repository.dart';
import 'package:fluxer_app/features/members/domain/member.dart';
import 'package:fluxer_app/features/members/providers/member_providers.dart';
import 'package:fluxer_app/features/settings/providers/appearance_preferences_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/voice/providers/voice_session_provider.dart';
import 'package:fluxer_app/features/voice/providers/voice_session_state.dart';
import 'package:fluxer_app/material_ui.dart' hide SensitiveContent;
import 'package:go_router/go_router.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../helpers/open_test_database.dart';
import '../../../../helpers/pump_fluxer_app.dart';
import '../../../../helpers/test_l10n.dart';
import '../../../../helpers/wide_layout_test_sizes.dart';

Future<void> _pumpSidebar(WidgetTester tester) async {
  await pumpFluxerFrames(tester);
}

const String _guildId = 'g1';
const String _otherGuildId = 'g2';

void main() {
  group('GuildSidebar mobile quick switcher FAB', () {
    testWidgets('shows FAB on mobile and opens quick switcher sheet', (
      tester,
    ) async {
      _setMobileSurface(tester);
      await tester.pumpWidget(
        _buildTestApp(
          overrides: _buildOverrides(
            channelListState: _state(),
            unread: const {'c1': UnreadState(), 'c2': UnreadState()},
          ),
        ),
      );
      await _pumpSidebar(tester);

      final fabFinder = find.byKey(
        const ValueKey<String>('quick-switcher-fab'),
      );
      expect(fabFinder, findsOneWidget);

      await tester.tap(fabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Search for channels, people, or communities'),
        findsOneWidget,
      );
      await releaseTestWidgetTree(tester);
    });

    testWidgets('does not show FAB on wide/desktop layout', (tester) async {
      tester.view.physicalSize = kWideTestViewportSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          overrides: _buildOverrides(
            channelListState: _state(),
            unread: const {'c1': UnreadState(), 'c2': UnreadState()},
          ),
        ),
      );
      await _pumpSidebar(tester);

      final fabFinder = find.byKey(
        const ValueKey<String>('quick-switcher-fab'),
      );
      expect(fabFinder, findsNothing);
      await releaseTestWidgetTree(tester);
    });
  });
}

void _setMobileSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Channel _channel(String id, String name) =>
    Channel(id: id, guildId: _guildId, name: name, parentId: 'cat1');

ChannelListState _state({String? selectedChannelId}) => ChannelListState(
  guild: const Guild(id: _guildId, name: 'Test Guild'),
  categories: [
    ChannelCategory(
      id: 'cat1',
      name: 'My Category',
      channels: [_channel('c1', 'general'), _channel('c2', 'random')],
    ),
  ],
  selectedChannelId: selectedChannelId,
  hasReceivedInitialChannelList: true,
);

List<Override> _buildOverrides({
  required ChannelListState channelListState,
  String? selectedChannelId,
  Set<String> collapsed = const {},
  Set<String> muted = const {},
  bool hideMuted = false,
  Map<String, UnreadState> unread = const {},
  Map<String, Stream<UnreadState>> unreadStreams = const {},
  AsyncValue<Set<String>>? mutedValue,
  Map<String, GuildReadStateEntry> guildReadState = const {},
  Map<String, int> permissionBits = const {},
  Map<String, int?> sidebarConnectBits = const {},
  bool developerMode = false,
  bool showFavorites = false,
  VoiceSession Function()? voiceSessionFactory,
  String? Function(Ref ref)? activeGuildIdReader,
  ChannelListViewModel Function()? channelListViewModelFactory,
  int guildPermissions = 0,
  FluxerDatabase? database,
}) {
  final db = database ?? openTestDatabase();
  final String routeLocation = selectedChannelId != null
      ? '/channels/$_guildId/$selectedChannelId'
      : '/channels/$_guildId';
  final List<Guild> guildList = <Guild>[
    if (channelListState.guild != null) channelListState.guild!,
    const Guild(id: _otherGuildId, name: 'Other Guild'),
  ];
  return [
    fluxerDatabaseProvider.overrideWithValue(db),
    memberRepositoryProvider.overrideWithValue(_FakeMemberRepository()),
    dmViewModelProvider.overrideWithValue(
      const DmViewState(
        conversations: [],
        friendsList: [],
        activeTab: FriendsTab.online,
        searchQuery: '',
        hasReceivedInitialConversations: true,
      ),
    ),
    currentUserIdProvider.overrideWithValue('me'),
    experimentsProvider.overrideWithValue(null),
    routeStateProvider.overrideWithValue(
      RouteState(
        location: routeLocation,
        activeBranchLocation: routeLocation,
        activeBranchIndex: 0,
        kind: classifyRoute(routeLocation),
        guildId: _guildId,
        channelId: selectedChannelId,
      ),
    ),
    guildListViewModelProvider.overrideWithValue(
      GuildListViewState(guilds: guildList),
    ),
    if (activeGuildIdReader != null)
      activeGuildIdProvider.overrideWith(activeGuildIdReader)
    else
      activeGuildIdProvider.overrideWithValue(_guildId),
    activeChannelIdProvider.overrideWithValue(selectedChannelId),
    channelListViewModelProvider.overrideWith(
      channelListViewModelFactory ??
          () => _FakeChannelListViewModel(channelListState),
    ),
    appearancePreferencesProvider.overrideWith(
      () => _FakeAppearancePreferences(showFavorites: showFavorites),
    ),
    voiceSessionProvider.overrideWith(
      voiceSessionFactory ?? _FakeVoiceSession.new,
    ),
    userSettingsViewModelProvider.overrideWith(
      () => _FakeUserSettings(developerMode: developerMode),
    ),
    sensitiveContentProvider.overrideWith(_FakeSensitiveContent.new),
    matureContentAgreementsProvider.overrideWith(_FakeMatureAgreements.new),
    guildMuteProvider(_guildId).overrideWithValue(
      AsyncData<GuildMuteState>(GuildMuteState(hideMutedChannels: hideMuted)),
    ),
    mutedChannelIdsProvider(
      _guildId,
    ).overrideWithValue(mutedValue ?? AsyncData<Set<String>>(muted)),
    guildCollapsedCategoriesProvider(
      _guildId,
    ).overrideWithValue(AsyncData<Set<String>>(collapsed)),
    for (final Channel channel in channelListState.categories.expand<Channel>(
      (ChannelCategory category) => category.channels,
    )) ...[
      effectiveGuildChannelPermissionBitsProvider(
        channel.id,
      ).overrideWith((ref) => permissionBits[channel.id] ?? 0),
      channelSettingsPermissionBitsProvider(
        channel.id,
      ).overrideWith((ref) => permissionBits[channel.id] ?? 0),
      if (sidebarConnectBits.containsKey(channel.id))
        channelSidebarIconConnectBitsProvider(
          channel.id,
        ).overrideWith((ref) => sidebarConnectBits[channel.id]),
    ],
    for (final entry in unread.entries)
      channelUnreadProvider(
        entry.key,
      ).overrideWith((ref) => Stream.value(entry.value)),
    for (final entry in unreadStreams.entries)
      channelUnreadProvider(entry.key).overrideWith((ref) => entry.value),
    guildReadStateProvider.overrideWithValue(guildReadState),
    guildPermissionsProvider.overrideWith(
      () => _FakeGuildPermissions(<String, int>{_guildId: guildPermissions}),
    ),
  ];
}

class _FakeGuildPermissions extends GuildPermissions {
  _FakeGuildPermissions(this._initial);

  final Map<String, int> _initial;

  @override
  Map<String, int> build() => _initial;

  @override
  Future<void> refreshPermissions(String guildId) async {}
}

Widget _buildTestApp({required List<Override> overrides}) {
  final colorTheme = buildDarkColorTheme();
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      localizationsDelegates: fluxerLocalizationsDelegates,
      supportedLocales: FluxerLocalizations.supportedLocales,
      theme: buildFluxerTheme(
        colorTheme: colorTheme,
        textTheme: FluxerTextTheme.fromColors(colorTheme),
        layoutTheme: FluxerLayoutTheme.scaled(),
      ),
      routerConfig: GoRouter(
        initialLocation: '/channels/$_guildId',
        routes: [
          GoRoute(
            path: '/channels/$_guildId',
            builder: (context, state) => const Scaffold(body: GuildSidebar()),
          ),
          GoRoute(
            path: '/channels/$_guildId/:channelId',
            builder: (context, state) => const Scaffold(body: GuildSidebar()),
          ),
          GoRoute(
            path: '/settings/channel/:channelId',
            builder: (context, state) => ChannelSettingsNavPage(
              channelId: state.pathParameters['channelId'] ?? '',
            ),
          ),
        ],
      ),
    ),
  );
}

class _FakeChannelListViewModel extends ChannelListViewModel {
  _FakeChannelListViewModel(this._state);

  final ChannelListState _state;

  @override
  ChannelListState build() => _state;
}

class _FakeAppearancePreferences extends AppearancePreferences {
  _FakeAppearancePreferences({this.showFavorites = false});

  final bool showFavorites;

  @override
  AppearancePreferencesState build() =>
      AppearancePreferencesState(showFavorites: showFavorites);
}

class _FakeVoiceSession extends VoiceSession {
  @override
  VoiceSessionState build() => const VoiceSessionState();
}

class _FakeUserSettings extends UserSettingsViewModel {
  _FakeUserSettings({required this.developerMode});

  final bool developerMode;

  @override
  UserSettingsViewState build() => UserSettingsViewState(
    userId: 'me',
    username: '',
    displayName: '',
    discriminator: '0',
    avatar: null,
    avatarColor: null,
    memberSince: null,
    status: 'offline',
    messageDisplayCompact: false,
    developerMode: developerMode,
    trustedDomains: const [],
  );
}

class _FakeSensitiveContent extends SensitiveContent {
  @override
  SensitiveContentState build() =>
      const SensitiveContentState(isLoading: false);
}

class _FakeMatureAgreements extends MatureContentAgreements {
  @override
  MatureContentAgreementsState build() =>
      const MatureContentAgreementsState(isLoaded: true);
}

class _FakeMemberRepository implements MemberRepository {
  @override
  Future<List<Member>> getMembers(String guildId, {int limit = 100}) async =>
      const <Member>[];

  @override
  Future<List<Member>> getMembersByUserIds(
    String guildId,
    List<String> userIds,
  ) async => const <Member>[];

  @override
  Future<void> backfillMembersIfSparse(String guildId) async {}

  @override
  Future<List<MemberRole>> getRoles(String guildId) async =>
      const <MemberRole>[];

  @override
  Future<List<Member>> getCachedMembersForGuild(String guildId) async =>
      const <Member>[];

  @override
  Future<bool> isGuildMemberCacheComplete(String guildId) async => true;

  @override
  Future<List<Member>> searchMembersForAutocomplete({
    required String guildId,
    required String query,
    required List<String> scopeUserIds,
  }) async => const <Member>[];
}
