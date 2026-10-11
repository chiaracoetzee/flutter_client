import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_dart/fluxer_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers the persona routes and remembers what was asked of it.
class _Api implements HttpClientAdapter {
  final List<String> calls = <String>[];
  Map<String, String> channelStates = <String, String>{};
  bool failPut = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String path = options.uri.path;
    final Object? data = options.data;
    final String body = data == null
        ? ''
        : ' ${data is String ? data : jsonEncode(data)}';
    calls.add('${options.method} $path$body');
    ResponseBody json(Object? body, [int status = 200]) =>
        ResponseBody.fromString(
          jsonEncode(body),
          status,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
    if (path.endsWith('/personas/channel-states') && options.method == 'GET') {
      return json({
        'states': [
          for (final entry in channelStates.entries)
            {'channel_id': entry.key, 'persona_id': entry.value},
        ],
      });
    }
    if (path.contains('/personas/channel-states/') && options.method == 'PUT') {
      if (failPut) {
        return json({'code': 'NOPE', 'message': 'no'}, 500);
      }
      final String channelId = path.split('/').last;
      final Object? decoded = data is String ? jsonDecode(data) : data;
      final Object? personaId = (decoded as Map?)?['persona_id'];
      return json({'channel_id': channelId, 'persona_id': personaId});
    }
    if (path.endsWith('/personas/settings')) {
      return json(<String, Object?>{});
    }
    return json(<Object?>[]);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Api api;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _Api();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://test.fluxer.invalid'))
      ..httpClientAdapter = api;
    container = ProviderContainer(
      overrides: [
        fluxerDioProvider.overrideWithValue(dio),
        fluxerClientProvider.overrideWithValue(
          FluxerClient(dio, baseUrl: 'https://test.fluxer.invalid'),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  ActivePersonaNotifier notifier() =>
      container.read(activePersonaProvider.notifier);
  ActivePersonaState state() => container.read(activePersonaProvider);
  List<String> puts() =>
      api.calls.where((String call) => call.startsWith('PUT ')).toList();

  Future<void> perChannel() async {
    // Let the settings finish loading first: their arrival sets the scope and
    // the selections from the server, as it does when the app starts.
    container.read(personaSettingsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    notifier().syncFromSettings(
      mode: state().mode,
      activeId: state().activePersonaId,
      isLatched: state().isLatched,
      scope: PersonaScope.channel,
    );
  }

  group('ActivePersonaState.latchedIdFor', () {
    test('is the one selection for every channel by default', () {
      const ActivePersonaState global = ActivePersonaState(
        activePersonaId: 'alice',
        isLatched: true,
      );
      expect(global.latchedIdFor('one'), 'alice');
      expect(global.latchedIdFor(null), 'alice');
      expect(
        const ActivePersonaState(activePersonaId: 'alice').latchedIdFor('one'),
        isNull,
      );
    });

    test("is the channel's own selection when kept per channel", () {
      const ActivePersonaState perChannelState = ActivePersonaState(
        activePersonaId: 'alice',
        isLatched: true,
        scope: PersonaScope.channel,
        channelPersonaIds: <String, String>{'one': 'bob'},
      );
      expect(perChannelState.latchedIdFor('one'), 'bob');
      // Every other channel starts as the account, whatever is selected
      // for every channel.
      expect(perChannelState.latchedIdFor('two'), isNull);
      expect(perChannelState.latchedIdFor(null), isNull);
      expect(perChannelState.latchedIdFor(''), isNull);
    });
  });

  test("a pick with a channel is that channel's alone", () async {
    await perChannel();
    // Alice is selected for every channel, from before the scope changed.
    notifier().syncFromSettings(
      mode: PersonaMode.manual,
      activeId: 'alice',
      isLatched: true,
      scope: PersonaScope.channel,
    );
    api.calls.clear();

    await notifier().setActivePersona('bob', channelId: 'one');

    expect(state().latchedIdFor('one'), 'bob');
    expect(state().latchedIdFor('two'), isNull);
    // Still there for when the scope is switched back.
    expect(state().activePersonaId, 'alice');
    expect(puts(), [
      'PUT /users/@me/personas/channel-states/one {"persona_id":"bob"}',
    ]);
    expect(
      api.calls.where((String call) => call.startsWith('PATCH ')),
      isEmpty,
    );
  });

  test('going back to the account clears only that channel', () async {
    await perChannel();
    await notifier().setActivePersona('alice', channelId: 'one');
    await notifier().setActivePersona('bob', channelId: 'two');

    await notifier().unlatch(channelId: 'one');

    expect(state().latchedIdFor('one'), isNull);
    expect(state().latchedIdFor('two'), 'bob');
    expect(
      puts().last,
      'PUT /users/@me/personas/channel-states/one {"persona_id":null}',
    );
  });

  test('without the per-channel scope a channel changes nothing', () async {
    await Future<void>.delayed(Duration.zero);
    await notifier().setActivePersona('alice', channelId: 'one');
    expect(state().activePersonaId, 'alice');
    expect(state().latchedIdFor('two'), 'alice');
    expect(puts(), isEmpty);
  });

  test('takes what is loaded and what another session selects', () async {
    await perChannel();
    api.channelStates = <String, String>{'one': 'alice', 'two': 'bob'};
    await notifier().loadChannelStates();
    expect(state().latchedIdFor('one'), 'alice');

    notifier()
      ..applyChannelState('one', 'bob')
      ..applyChannelState('two', null);
    expect(state().latchedIdFor('one'), 'bob');
    expect(state().latchedIdFor('two'), isNull);
    expect(puts(), isEmpty);
  });

  test('asks the server what holds when a pick cannot be saved', () async {
    await perChannel();
    api.channelStates = <String, String>{'one': 'alice'};
    await notifier().loadChannelStates();
    api.failPut = true;

    await notifier().setActivePersona('bob', channelId: 'one');

    expect(state().latchedIdFor('one'), 'alice');
  });

  test('a new thread starts as whoever opened it, per channel only', () async {
    await Future<void>.delayed(Duration.zero);
    notifier().startChannelAs('thread', 'bob');
    await Future<void>.delayed(Duration.zero);
    expect(puts(), isEmpty);

    await perChannel();
    notifier()
      ..startChannelAs('thread', 'bob')
      ..startChannelAs('other', null);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(state().latchedIdFor('thread'), 'bob');
    expect(state().latchedIdFor('other'), isNull);
    expect(puts(), hasLength(1));
  });

  test('latchedPersonaFor ignores a selection whose persona is gone', () {
    const ActivePersonaState perChannelState = ActivePersonaState(
      scope: PersonaScope.channel,
      channelPersonaIds: <String, String>{'one': 'bob', 'two': 'gone'},
    );
    const List<Persona> personas = <Persona>[Persona(id: 'bob', name: 'Bob')];
    expect(latchedPersonaFor(perChannelState, personas, 'one')?.name, 'Bob');
    expect(latchedPersonaFor(perChannelState, personas, 'two'), isNull);
    expect(latchedPersonaFor(perChannelState, personas, 'three'), isNull);
  });
}
