// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/providers/app_ui_lifecycle_provider.dart';
import 'package:fluxer_app/core/providers/database_provider.dart';
import 'package:fluxer_app/core/router/fluxer_router.dart';
import 'package:fluxer_app/features/channels/data/ack_batcher.dart';
import 'package:fluxer_app/features/channels/providers/ack_batcher_provider.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/shared/services/guild_member_hydration_service.dart';
import 'package:fluxer_dart/export.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/noop_guild_member_hydration_service.dart';
import '../../../../helpers/open_test_database.dart';

class _FakeMyPersonasNotifier extends MyPersonasNotifier {
  _FakeMyPersonasNotifier([this._initial = const []]);

  final List<Persona> _initial;

  @override
  AsyncValue<List<Persona>> build() => AsyncData(_initial);

  void setPersonas(List<Persona> personas) {
    state = AsyncData(personas);
  }

  @override
  void reset() {
    state = const AsyncValue.data([]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const personaA = Persona(
    id: 'persona_a',
    name: 'Alice',
    personaTags: [
      PersonaTag(prefix: 'a:', suffix: ''),
    ],
    signatureEmojis: [
      SignatureEmoji(name: '🔥'),
    ],
  );

  const personaB = Persona(
    id: 'persona_b',
    name: 'Bob',
    personaTags: [
      PersonaTag(prefix: 'b:', suffix: ''),
    ],
    signatureEmojis: [
      SignatureEmoji(id: 'cat_123', name: 'custom_cat', animated: false),
    ],
  );

  late FluxerDatabase db;
  late ProviderContainer container;
  late ChatViewModel viewModel;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = openTestDatabase();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.fluxer.app/v1'));
    final client = FluxerClient(dio, baseUrl: 'https://api.fluxer.app/v1');

    container = ProviderContainer(
      overrides: [
        fluxerDatabaseProvider.overrideWithValue(db),
        appUiForegroundProvider.overrideWithValue(true),
        fluxerDioProvider.overrideWithValue(dio),
        fluxerClientProvider.overrideWithValue(client),
        currentUserIdProvider.overrideWithValue('me'),
        myPersonasProvider.overrideWith(() => _FakeMyPersonasNotifier([personaA, personaB])),
        ackBatcherProvider.overrideWith((ref) {
          final batcher = AckBatcher(client: client, batchDelay: Duration.zero);
          ref.onDispose(() {
            unawaited(batcher.dispose());
          });
          return batcher;
        }),
        guildMemberHydrationServiceProvider.overrideWithValue(
          NoopGuildMemberHydrationService(database: db),
        ),
      ],
    );

    viewModel = container.read(chatViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('ChatViewModel.resolveEffectiveReactionPersona', () {
    test('returns null when user has no personas', () {
      (container.read(myPersonasProvider.notifier) as _FakeMyPersonasNotifier)
          .setPersonas(const []);

      final result = viewModel.resolveEffectiveReactionPersona(emoji: '🔥');
      expect(result, isNull);
    });

    test('Tier 1: Signature emoji match takes highest priority over tags and latched persona', () {
      // Latch to Persona B and put Persona B's tag in composer text
      container.read(activePersonaProvider.notifier).syncFromSettings(
            mode: PersonaMode.manual,
            activeId: personaB.id,
            isLatched: true,
          );
      viewModel.updateMessageText('b: some text');

      // Reacting with '🔥' (Alice's signature emoji) resolves to Alice despite Bob being latched and tagged
      final resultAlice = viewModel.resolveEffectiveReactionPersona(emoji: '🔥');
      expect(resultAlice, equals(personaA.id));

      // Reacting with custom emoji 'custom_cat' (Bob's signature emoji) resolves to Bob
      final resultBob = viewModel.resolveEffectiveReactionPersona(
        emoji: 'custom_cat',
        emojiId: 'cat_123',
      );
      expect(resultBob, equals(personaB.id));
    });

    test('Tier 2: Composer proxy tag match takes precedence when no signature emoji matches', () {
      // Latch to Alice
      container.read(activePersonaProvider.notifier).syncFromSettings(
            mode: PersonaMode.manual,
            activeId: personaA.id,
            isLatched: true,
          );
      // But composer has Bob's tag
      viewModel.updateMessageText('b: hello from bob');

      // '👍' is not a signature emoji of Alice or Bob -> matches Bob via composer tag
      final result = viewModel.resolveEffectiveReactionPersona(emoji: '👍');
      expect(result, equals(personaB.id));
    });

    test('Tier 3: Active latched persona takes precedence when no signature and no composer tag match', () {
      // Latch to Alice
      container.read(activePersonaProvider.notifier).syncFromSettings(
            mode: PersonaMode.manual,
            activeId: personaA.id,
            isLatched: true,
          );
      // Untagged composer text
      viewModel.updateMessageText('just a regular message');

      // '👍' is not a signature emoji -> resolves to active latched persona (Alice)
      final result = viewModel.resolveEffectiveReactionPersona(emoji: '👍');
      expect(result, equals(personaA.id));
    });

    test('Tier 4: Falls back to root account (null) when unlatched with no tag and no signature match', () {
      // Unlatched / root account
      container.read(activePersonaProvider.notifier).syncFromSettings(
            mode: PersonaMode.manual,
            activeId: null,
            isLatched: false,
          );
      viewModel.updateMessageText('just a regular message');

      // '👍' is not a signature emoji -> resolves to root account (null)
      final result = viewModel.resolveEffectiveReactionPersona(emoji: '👍');
      expect(result, isNull);
    });
  });
}
