import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart' as db;
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/dm/providers/dm_view_model.dart';
import 'package:fluxer_app/features/favorites/domain/resolved_favorite_entry.dart';
import 'package:fluxer_app/features/favorites/presentation/favorites_sidebar.dart';
import 'package:fluxer_app/features/favorites/providers/favorite_channel_groups_provider.dart';
import 'package:fluxer_app/features/favorites/providers/favorite_channels_provider.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/features/guilds/providers/guild_list_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../helpers/open_test_database.dart';
import '../../../helpers/pump_fluxer_app.dart';
import '../../../helpers/wide_layout_test_sizes.dart';

class _EmptyGuildListViewModel extends GuildListViewModel {
  @override
  GuildListViewState build() => const GuildListViewState(guilds: <Guild>[]);
}

void main() {
  void setMobileSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<Override> buildOverrides() {
    final testDb = openTestDatabase();
    return [
      fluxerDatabaseProvider.overrideWithValue(testDb),
      favoriteChannelGroupsProvider.overrideWith(
        (ref) => const <FavoriteChannelGroup>[],
      ),
      favoriteChannelsProvider.overrideWith((ref) => Stream.value(const [])),
      favoriteCategoriesProvider.overrideWith((ref) => Stream.value(const [])),
      favoriteSettingsProvider.overrideWith(
        (ref) => Stream.value(
          const db.FavoriteSetting(
            id: 1,
            collapsedCategoryIdsJson: '[]',
            hideMuted: false,
            muted: false,
          ),
        ),
      ),
      favoriteGuildChannelsProvider.overrideWith(
        (ref) => Stream.value(const <Channel>[]),
      ),
      dmViewModelProvider.overrideWithValue(
        const DmViewState(
          conversations: [],
          friendsList: [],
          activeTab: FriendsTab.online,
          searchQuery: '',
          hasReceivedInitialConversations: true,
        ),
      ),
      guildListViewModelProvider.overrideWith(_EmptyGuildListViewModel.new),
    ];
  }

  group('FavoritesSidebar mobile quick switcher FAB', () {
    testWidgets('shows FAB on mobile and opens quick switcher sheet', (
      tester,
    ) async {
      setMobileSurface(tester);

      await tester.pumpWidget(
        pumpFluxerApp(
          overrides: buildOverrides(),
          child: const Scaffold(body: FavoritesSidebar()),
        ),
      );
      await pumpFluxerFrames(tester);

      final fabFinder =
          find.byKey(const ValueKey<String>('quick-switcher-fab'));
      expect(fabFinder, findsOneWidget);

      await tester.tap(fabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Search for channels, people, or communities'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('does not show FAB on wide/desktop layout', (tester) async {
      tester.view.physicalSize = kWideTestViewportSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        pumpFluxerApp(
          overrides: buildOverrides(),
          child: const Scaffold(body: FavoritesSidebar()),
        ),
      );
      await pumpFluxerFrames(tester);

      final fabFinder =
          find.byKey(const ValueKey<String>('quick-switcher-fab'));
      expect(fabFinder, findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
