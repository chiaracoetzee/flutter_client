// Fork: tests the fork adds, kept out of upstream's typing_indicator_bar_test.dart so that file stays as
// upstream has it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show FluxerDatabase;
import 'package:fluxer_app/core/gateway/providers/gateway_event_providers.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/router/route_state_providers.dart';
import 'package:fluxer_app/core/theme/fluxer_color_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/typing_indicator_bar.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/friends/providers/blocked_user_ids_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/providers/guild_user_display_provider.dart';
import 'package:fluxer_app/shared/utils/guild_user_display.dart';
import 'package:fluxer_dart/models/message_subprofile_response_schema.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../helpers/open_test_database.dart';
import '../../../../../helpers/test_l10n.dart';

const String _kTyperUserId = 'user-1';

late ProviderContainer container;

Future<void> _pumpTypingIndicatorBar(
  WidgetTester tester, {
  required bool compact,
}) async {
  container = ProviderContainer(
    overrides: [
      fluxerDatabaseProvider.overrideWithValue(_database),
      chatViewModelProvider.overrideWithValue(_chatState()),
      currentUserIdProvider.overrideWithValue('me'),
      contextualGuildIdProvider.overrideWithValue('guild-1'),
      blockedUserIdsProvider.overrideWithValue(const <String>{}),
      guildUserDisplayProvider((_kTyperUserId, 'guild-1')).overrideWith(
        (ref) => const AsyncValue.data(
          GuildUserDisplay(
            displayName: 'Typer',
            avatarUrl: null,
            avatarColor: null,
            accountDisplayName: 'Typer',
          ),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  final FluxerColorTheme colorTheme = buildDarkColorTheme();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: kTestLocale,
        localizationsDelegates: fluxerLocalizationsDelegates,
        supportedLocales: FluxerLocalizations.supportedLocales,
        theme: buildFluxerTheme(
          colorTheme: colorTheme,
          textTheme: FluxerTextTheme.fromColors(colorTheme),
          layoutTheme: FluxerLayoutTheme.scaled(),
        ),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: TypingIndicatorBar(compact: compact)),
        ),
      ),
    ),
  );
  container
      .read(typingIndicatorsProvider.notifier)
      .addTyping('channel-1', _kTyperUserId);
  await tester.pump();
}

ChatViewState _chatState() {
  return const ChatViewState(
    channelId: 'channel-1',
    messages: <Message>[],
    replyingTo: null,
    replyMentioning: true,
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

late FluxerDatabase _database;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _database = openTestDatabase();
  });

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  testWidgets(
    'typing indicator renders persona name when subprofile is provided',
    (WidgetTester tester) async {
      await _pumpTypingIndicatorBar(tester, compact: false);
      container.read(typingIndicatorsProvider.notifier).clearAll();
      container
          .read(typingIndicatorsProvider.notifier)
          .addTyping(
            'channel-1',
            _kTyperUserId,
            subprofile: const MessageSubprofileResponseSchema(
              id: 'persona-1',
              name: 'Ruby Rose',
              avatar: 'avatars/ruby.png',
              avatarColor: 0xff0000,
              displayTagText: 'ROSE',
            ),
          );
      await tester.pump();

      expect(find.textContaining('Ruby Rose'), findsOneWidget);
      expect(find.textContaining('is typing'), findsOneWidget);
      container.read(typingIndicatorsProvider.notifier).clearAll();
    },
  );
}
