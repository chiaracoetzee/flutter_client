// Root ProviderScope built by a helper; the lint only exempts a
// ProviderScope written inline in pumpWidget.
// ignore_for_file: riverpod_lint/scoped_providers_should_specify_dependencies

import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart'
    show KnownPersona;
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/core/theme/fluxer_layout_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_text_theme.dart';
import 'package:fluxer_app/core/theme/fluxer_theme.dart';
import 'package:fluxer_app/core/theme/themes/dark.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_mention.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/data/known_personas.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/providers/guild_user_display_provider.dart';
import 'package:fluxer_app/shared/utils/guild_user_display.dart';
import 'package:riverpod/src/framework.dart' show Override;

import '../../../../../helpers/instance_runtime_config_override.dart';
import '../../../../../helpers/test_l10n.dart';

const String _kTestUserId = '1481621807877361924';
const String _kTestPersonaId = '1550229100331794432';

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier(this._initial);
  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncValue.data(_initial);
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

Widget _testApp({
  required Widget child,
  List<Override> overrides = const [],
  Map<String, KnownPersona> known = const <String, KnownPersona>{},
}) {
  final colorTheme = buildDarkColorTheme();
  return ProviderScope(
    overrides: [
      instanceRuntimeConfigOverride(),
      knownPersonaProvider.overrideWith(
        (ref, String personaId) => Stream.value(known[personaId]),
      ),
      chatViewModelProvider.overrideWithValue(_chatState()),
      guildUserDisplayFromDbProvider((_kTestUserId, null)).overrideWith(
        (ref) => const AsyncValue.data(
          GuildUserDisplay(
            displayName: 'msubizo',
            accountDisplayName: 'msubizo',
            avatarUrl: null,
            avatarColor: null,
          ),
        ),
      ),
      ...overrides,
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets(
    'UserMention renders standard user mention label when personaId is null',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _testApp(child: const UserMention(userId: _kTestUserId)),
      );
      await tester.pumpAndSettle();

      expect(find.text('@msubizo'), findsOneWidget);
    },
  );

  testWidgets(
    'UserMention renders persona display name without owner username when personaId is provided',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _testApp(
          known: const <String, KnownPersona>{
            _kTestPersonaId: KnownPersona(
              id: _kTestPersonaId,
              name: 'Bob the Fox',
              color: 0xFF5500,
            ),
          },
          child: const UserMention(
            userId: _kTestUserId,
            personaId: _kTestPersonaId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Displays persona name
      expect(find.text('@Bob the Fox'), findsOneWidget);
      // Does not leak owner username or user ID
      expect(find.text('@msubizo'), findsNothing);
      expect(find.text('@$_kTestUserId'), findsNothing);
    },
  );

  testWidgets(
    'UserMention applies persona accent color to text when configured',
    (WidgetTester tester) async {
      const int customColor = 0xFF336699;

      await tester.pumpWidget(
        _testApp(
          known: const <String, KnownPersona>{
            _kTestPersonaId: KnownPersona(
              id: _kTestPersonaId,
              name: 'Color Persona',
              color: customColor,
            ),
          },
          child: const UserMention(
            userId: _kTestUserId,
            personaId: _kTestPersonaId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final widgets.Text textWidget = tester.firstWidget<widgets.Text>(
        find.text('@Color Persona'),
      );
      expect(textWidget.style?.color, const Color(customColor | 0xFF000000));
    },
  );

  testWidgets(
    'UserMention resolves owned persona from myPersonasProvider when current user matches',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _testApp(
          overrides: [
            currentUserIdProvider.overrideWithValue(_kTestUserId),
            publicPersonaProvider((
              userId: _kTestUserId,
              personaId: _kTestPersonaId,
            )).overrideWith((ref) => Future<PublicPersona?>.value()),
            myPersonasProvider.overrideWith(
              () => _FakeMyPersonasNotifier([
                const Persona(
                  id: _kTestPersonaId,
                  name: 'My Custom Subprofile',
                  color: 0x00AAFF,
                ),
              ]),
            ),
          ],
          child: const UserMention(
            userId: _kTestUserId,
            personaId: _kTestPersonaId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('@My Custom Subprofile'), findsOneWidget);
      expect(find.text('@$_kTestUserId'), findsNothing);
    },
  );

  group('a persona this device knows', () {
    late int lookups;

    Override lookup(PublicPersona? found) =>
        publicPersonaProvider((
          userId: _kTestUserId,
          personaId: _kTestPersonaId,
        )).overrideWith((ref) {
          lookups++;
          return Future.value(found);
        });

    setUp(() => lookups = 0);

    testWidgets('is named from what the device knows, without asking', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _testApp(
          known: const <String, KnownPersona>{
            _kTestPersonaId: KnownPersona(
              id: _kTestPersonaId,
              name: 'Bob the Fox',
            ),
          },
          overrides: [
            lookup(const PublicPersona(id: _kTestPersonaId, name: 'Other')),
          ],
          child: const UserMention(
            userId: _kTestUserId,
            personaId: _kTestPersonaId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('@Bob the Fox'), findsOneWidget);
      expect(lookups, 0);
    });

    testWidgets(
      'shows the account, without asking, when the device knows nothing of it',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _testApp(
            overrides: [
              lookup(const PublicPersona(id: _kTestPersonaId, name: 'Other')),
            ],
            child: const UserMention(
              userId: _kTestUserId,
              personaId: _kTestPersonaId,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('@msubizo'), findsOneWidget);
        expect(lookups, 0);
      },
    );
  });
}
