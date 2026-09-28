// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/message.dart';
import 'package:fluxer_app/features/chat/presentation/sheets/persona_react_as_sheet.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../helpers/pump_fluxer_app.dart';

class _FakeUserSettings extends UserSettingsViewModel {
  @override
  UserSettingsViewState build() => const UserSettingsViewState(
        userId: 'root_user',
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
  _FakeMyPersonasNotifier(this._personas);
  final List<Persona> _personas;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_personas);

  @override
  Future<void> reloadSilently() async {}
}

class _FakeChatViewModel extends ChatViewModel {
  _FakeChatViewModel(this._initialState);
  final ChatViewState _initialState;

  String? toggledMessageId;
  String? toggledEmoji;
  String? toggledEmojiId;
  String? toggledPersonaId;
  bool? toggledExplicitRoot;

  @override
  ChatViewState build() => _initialState;

  @override
  Future<void> toggleReaction(
    String messageId,
    String emoji, {
    String? emojiId,
    bool animated = false,
    String? personaId,
    bool explicitRoot = false,
  }) async {
    toggledMessageId = messageId;
    toggledEmoji = emoji;
    toggledEmojiId = emojiId;
    toggledPersonaId = personaId;
    toggledExplicitRoot = explicitRoot;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const personaBob = Persona(
    id: 'p_bob',
    name: 'Bob the Builder',
    pronouns: 'he/him',
  );

  const personaAlice = Persona(
    id: 'p_alice',
    name: 'Alice Wonder',
    pronouns: 'she/her',
  );

  final allPersonas = [personaBob, personaAlice];

  final testMessage = Message(
    id: 'msg_1',
    channelId: 'chan_1',
    authorId: 'other_user',
    authorName: 'other',
    content: 'Hello World',
    timestamp: DateTime.now(),
    reactions: const [
      Reaction(
        emoji: '👍',
        count: 2,
        hasReacted: true,
        meRoot: true,
        personaReactions: ['p_bob'],
      ),
    ],
  );

  late _FakeChatViewModel fakeChatVm;

  Widget buildTestBed({
    VoidCallback? onReacted,
    String emoji = '👍',
  }) {
    fakeChatVm = _FakeChatViewModel(
      ChatViewState(
        channelId: 'chan_1',
        messages: [testMessage],
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
      ),
    );

    return pumpFluxerApp(
      overrides: [
        userSettingsViewModelProvider.overrideWith(_FakeUserSettings.new),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier(allPersonas)),
        chatViewModelProvider.overrideWith(() => fakeChatVm),
      ],
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            key: const ValueKey('open_btn'),
            onPressed: () {},
            child: Builder(
              builder: (context) => ElevatedButton(
                key: const ValueKey('trigger_react_as'),
                onPressed: () => PersonaReactAsSheet.show(
                  context,
                  channelId: 'chan_1',
                  messageId: 'msg_1',
                  emoji: emoji,
                  onReacted: onReacted,
                ),
                child: const Text('Open React As'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders root user and persona options with existing reactions highlighted', (tester) async {
    await tester.pumpWidget(buildTestBed());
    await tester.tap(find.byKey(const ValueKey('trigger_react_as')));
    await tester.pumpAndSettle();

    expect(find.text('React as...'), findsOneWidget);
    expect(find.text('Root User'), findsOneWidget);
    expect(find.text('Bob the Builder'), findsWidgets);
    expect(find.text('Alice Wonder'), findsWidgets);

    // Root and Bob have reacted with 👍 -> Check icons should be present
    expect(find.byIcon(PhosphorIconsBold.check), findsNWidgets(2));
  });

  testWidgets('filters personas using search box', (tester) async {
    await tester.pumpWidget(buildTestBed());
    await tester.tap(find.byKey(const ValueKey('trigger_react_as')));
    await tester.pumpAndSettle();

    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);

    await tester.enterText(searchInput, 'Alice');
    await tester.pumpAndSettle();

    expect(find.text('Alice Wonder'), findsOneWidget);
    expect(find.text('Bob the Builder'), findsNothing);
  });

  testWidgets('tapping a persona toggles reaction and invokes onReacted', (tester) async {
    var reactedCalled = false;
    await tester.pumpWidget(buildTestBed(onReacted: () => reactedCalled = true));
    await tester.tap(find.byKey(const ValueKey('trigger_react_as')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice Wonder').last);
    await tester.pumpAndSettle();

    expect(fakeChatVm.toggledMessageId, 'msg_1');
    expect(fakeChatVm.toggledEmoji, '👍');
    expect(fakeChatVm.toggledPersonaId, 'p_alice');
    expect(reactedCalled, isTrue);
  });

  testWidgets('tapping root user toggles reaction with explicitRoot and invokes onReacted', (tester) async {
    var reactedCalled = false;
    await tester.pumpWidget(buildTestBed(onReacted: () => reactedCalled = true));
    await tester.tap(find.byKey(const ValueKey('trigger_react_as')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Root User'));
    await tester.pumpAndSettle();

    expect(fakeChatVm.toggledMessageId, 'msg_1');
    expect(fakeChatVm.toggledEmoji, '👍');
    expect(fakeChatVm.toggledExplicitRoot, isTrue);
    expect(reactedCalled, isTrue);
  });
}
