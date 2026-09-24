import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart' as db;
import 'package:fluxer_app/core/limits/instance_limit_provider.dart';
import 'package:fluxer_app/core/limits/limit_key.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/router/route_state_providers.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/providers/theme_preference_provider.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/channels/domain/channel.dart';
import 'package:fluxer_app/features/channels/providers/channel_list_view_model.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/wide_composer_layout.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/channel_welcome_section.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list.dart';
import 'package:fluxer_app/features/chat/providers/channel/channel_message_permissions_provider.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_read_viewport_provider.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/dm/domain/dm_conversation.dart';
import 'package:fluxer_app/features/dm/presentation/widgets/group_dm_welcome_section.dart';
import 'package:fluxer_app/features/dm/providers/dm_view_model.dart';
import 'package:fluxer_app/features/friends/domain/friend.dart';
import 'package:fluxer_app/features/friends/providers/blocked_user_ids_provider.dart';
import 'package:fluxer_app/features/settings/providers/appearance_preferences_provider.dart';
import 'package:fluxer_app/features/settings/providers/chat_preferences_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../../helpers/open_test_database.dart';
import '../../../../../helpers/test_l10n.dart';

const String _channelId = 'empty-test-channel';
const String _currentUserId = '111111111111111111';

class _EmptyChatViewModel extends ChatViewModel {
  _EmptyChatViewModel(this._initialState);

  final ChatViewState _initialState;

  @override
  ChatViewState build() {
    ref
        .read(chatReadViewportProvider.notifier)
        .setActiveChannel(_initialState.channelId);
    return _initialState;
  }

  @override
  void clearStickyUnreadAfterBuildForCurrentChannel() {}
}

Future<db.FluxerDatabase> _openDatabase() async {
  final db.FluxerDatabase database = openTestDatabase();
  await database.channelDao.upsertChannel(
    db.ChannelsCompanion.insert(
      id: _channelId,
      guildId: '',
      name: 'general',
      type: const Value<int>(0),
    ),
  );
  return database;
}

List<Override> _messageListOverrides({
  required db.FluxerDatabase database,
  required ChatViewModel chatViewModel,
  List<DmConversation> conversations = const <DmConversation>[],
}) {
  return <Override>[
    fluxerDatabaseProvider.overrideWithValue(database),
    chatViewModelProvider.overrideWith(() => chatViewModel),
    currentUserIdProvider.overrideWithValue(_currentUserId),
    blockedUserIdsProvider.overrideWithValue(<String>{}),
    activeGuildIdProvider.overrideWithValue(null),
    channelListViewModelProvider.overrideWithValue(
      const ChannelListState(
        guild: null,
        categories: <ChannelCategory>[
          ChannelCategory(
            id: 'category-1',
            name: 'Channels',
            channels: <Channel>[
              Channel(
                id: _channelId,
                guildId: '',
                name: 'general',
              ),
            ],
          ),
        ],
        selectedChannelId: _channelId,
      ),
    ),
    dmViewModelProvider.overrideWithValue(
      DmViewState(
        conversations: conversations,
        friendsList: const <Friend>[],
        activeTab: FriendsTab.online,
        searchQuery: '',
      ),
    ),
    channelMessagePermissionsProvider(
      _channelId,
    ).overrideWith((ref) => ChannelMessagePermissions.all),
    messageListReadStateProvider(
      _channelId,
    ).overrideWith((ref) => Stream<db.ReadState?>.value(null)),
    themePreferenceProvider.overrideWithValue(ThemePreferenceState()),
    userSettingsViewModelProvider.overrideWithValue(
      const UserSettingsViewState(
        userId: _currentUserId,
        username: 'tester',
        displayName: 'Tester',
        discriminator: '0',
        avatar: null,
        avatarColor: null,
        memberSince: null,
        status: 'online',
        messageDisplayCompact: false,
        developerMode: false,
        trustedDomains: <String>[],
        renderEmbeds: false,
        renderReactions: false,
        inlineAttachmentMedia: false,
      ),
    ),
    chatPreferencesProvider.overrideWithValue(const ChatPreferencesState()),
    appearancePreferencesProvider.overrideWithValue(
      const AppearancePreferencesState(),
    ),
    instanceLimitProvider(LimitKeys.maxGroupDmRecipients).overrideWithValue(10),
  ];
}

Widget _messageListApp({
  required db.FluxerDatabase database,
  required ChatViewModel chatViewModel,
  required Widget body,
  List<DmConversation> conversations = const <DmConversation>[],
}) {
  final colorTheme = buildDarkColorTheme();
  return ProviderScope(
    overrides: _messageListOverrides(
      database: database,
      chatViewModel: chatViewModel,
      conversations: conversations,
    ),
    child: MaterialApp(
      locale: kTestLocale,
      localizationsDelegates: FluxerLocalizations.localizationsDelegates,
      supportedLocales: FluxerLocalizations.supportedLocales,
      theme: buildFluxerTheme(
        colorTheme: colorTheme,
        textTheme: FluxerTextTheme.fromColors(colorTheme),
        layoutTheme: FluxerLayoutTheme.scaled(),
      ),
      home: Scaffold(body: body),
    ),
  );
}

ChatViewState _emptyState({required String channelId}) {
  return ChatViewState(
    channelId: channelId,
    messages: const <Message>[],
    replyingTo: null,
    replyMentioning: false,
    editingMessage: null,
    messageText: '',
    scrollToBottomSignal: 0,
    isLoading: false,
    isSyncingMessages: false,
    isLoadingMore: false,
    isLoadingNewer: false,
    hasMoreMessages: false,
    hasMoreNewerMessages: false,
    errorMessage: null,
  );
}

Future<void> _disposeWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets(
    'empty channel welcome section has bottom clearance for mobile status overlay',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db.FluxerDatabase database = await _openDatabase();
      addTearDown(database.close);
      final _EmptyChatViewModel chatViewModel = _EmptyChatViewModel(
        _emptyState(channelId: _channelId),
      );

      await tester.pumpWidget(
        _messageListApp(
          database: database,
          chatViewModel: chatViewModel,
          body: const MessageList(expectedChannelId: _channelId),
        ),
      );
      await tester.pump();

      expect(find.byType(ChannelWelcomeSection), findsOneWidget);

      final Rect messageListRect = tester.getRect(find.byType(MessageList));
      final Rect welcomeRect = tester.getRect(
        find.byType(ChannelWelcomeSection),
      );

      // On mobile, the welcome section should be inset from the bottom of
      // the message list by mobileMessageListTrailingInset to clear the fade
      final double bottomClearance = messageListRect.bottom - welcomeRect.bottom;
      expect(
        bottomClearance,
        WideComposerLayout.mobileMessageListTrailingInset,
      );

      await _disposeWidgetTree(tester);
    },
  );

  testWidgets(
    'empty channel welcome section has bottom clearance for desktop status overlay',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db.FluxerDatabase database = await _openDatabase();
      addTearDown(database.close);
      final _EmptyChatViewModel chatViewModel = _EmptyChatViewModel(
        _emptyState(channelId: _channelId),
      );

      await tester.pumpWidget(
        _messageListApp(
          database: database,
          chatViewModel: chatViewModel,
          body: const MessageList(expectedChannelId: _channelId),
        ),
      );
      await tester.pump();

      expect(find.byType(ChannelWelcomeSection), findsOneWidget);

      final Rect messageListRect = tester.getRect(find.byType(MessageList));
      final Rect welcomeRect = tester.getRect(
        find.byType(ChannelWelcomeSection),
      );

      // On desktop, the welcome section should be inset from the bottom of
      // the message list by messageListTrailingInset to clear the fade
      final double bottomClearance = messageListRect.bottom - welcomeRect.bottom;
      expect(
        bottomClearance,
        WideComposerLayout.messageListTrailingInset,
      );

      await _disposeWidgetTree(tester);
    },
  );

  testWidgets(
    'empty group dm welcome section has bottom clearance for mobile status overlay',
    (tester) async {
      const String groupDmId = 'empty-group-dm-channel';
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db.FluxerDatabase database = await _openDatabase();
      addTearDown(database.close);
      final _EmptyChatViewModel chatViewModel = _EmptyChatViewModel(
        _emptyState(channelId: groupDmId),
      );

      final DmConversation groupDm = DmConversation(
        id: groupDmId,
        type: ChannelType.groupDm.wireValue,
        recipientId: 'user-1',
        recipientName: 'Friend 1',
        name: 'Cool Group',
        lastMessage: '',
        lastMessageTime: DateTime.utc(2026),
      );

      await tester.pumpWidget(
        _messageListApp(
          database: database,
          chatViewModel: chatViewModel,
          conversations: <DmConversation>[groupDm],
          body: const MessageList(expectedChannelId: groupDmId),
        ),
      );
      await tester.pump();

      expect(find.byType(GroupDmWelcomeSection), findsOneWidget);

      final Rect messageListRect = tester.getRect(find.byType(MessageList));
      final Rect welcomeRect = tester.getRect(
        find.byType(GroupDmWelcomeSection),
      );

      final double bottomClearance = messageListRect.bottom - welcomeRect.bottom;
      expect(
        bottomClearance,
        WideComposerLayout.mobileMessageListTrailingInset,
      );

      await _disposeWidgetTree(tester);
    },
  );
}
