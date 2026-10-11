import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/signal_bar/data/signal_bar_repository.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';
import 'package:fluxer_app/features/signal_bar/providers/signal_bar_providers.dart';

class _FakeRepository implements SignalBarRepository {
  SignalBarConfig bar = const SignalBarConfig(
    version: 1,
    signals: <SignalBarSignal>[
      SignalBarSignal(id: 'reading', emojiName: 'Reading', animated: true),
    ],
  );
  List<SignalEntry> entries = <SignalEntry>[];
  bool enabled = true;
  int barFetches = 0;
  final List<String> calls = <String>[];

  @override
  Future<SignalBarConfig> fetchBar() async {
    barFetches++;
    return bar;
  }

  @override
  Future<({bool enabled, int barVersion, List<SignalEntry> entries})>
  fetchChannel(String channelId) async =>
      (enabled: enabled, barVersion: bar.version, entries: entries);

  @override
  Future<void> removeUser(
    String channelId,
    String signalId,
    String userId,
  ) async => calls.add('REMOVE $channelId $signalId $userId');

  @override
  Future<void> activate(
    String channelId,
    String signalId, {
    String? personaId,
  }) async => calls.add('PUT $channelId $signalId ${personaId ?? '-'}');

  @override
  Future<void> deactivate(String channelId, String signalId) async =>
      calls.add('DELETE $channelId $signalId');

  @override
  Future<void> reset(String channelId, String signalId) async =>
      calls.add('RESET $channelId $signalId');
}

Map<String, dynamic> _entryJson(
  String signalId,
  String userId, {
  String? personaId,
  String? personaName,
}) => <String, dynamic>{
  'signal_id': signalId,
  'user': <String, dynamic>{'id': userId, 'username': 'user$userId'},
  'persona_id': personaId,
  'subprofile': personaId == null
      ? null
      : <String, dynamic>{'id': personaId, 'name': personaName},
  'activated_at': 0,
};

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeRepository();
    container = ProviderContainer(
      overrides: [signalBarRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  ChannelSignalsNotifier signals() =>
      container.read(channelSignalsProvider.notifier);
  List<SignalEntry> entries(String channelId) =>
      container.read(channelSignalsProvider)[channelId] ?? const [];

  test('parses the bar and falls back to the emoji name for a label', () {
    final SignalBarConfig config = SignalBarConfig.fromJson(
      const <String, dynamic>{
        'version': 4,
        'guild_id': '1',
        'can_manage': true,
        'signals': [
          {
            'id': 'a',
            'emoji_id': '9',
            'emoji_name': 'Done',
            'animated': true,
            'label': null,
          },
          {
            'id': 'b',
            'emoji_id': null,
            'emoji_name': '📖',
            'animated': false,
            'label': 'Reading',
          },
        ],
      },
    );
    expect(config.version, 4);
    expect(config.canManage, isTrue);
    expect(config.signals.map((s) => s.displayLabel), ['Done', 'Reading']);
  });

  test('ignores updates for channels that were never loaded', () {
    signals().handleChannelUpdate(<String, dynamic>{
      'channel_id': 'c',
      'bar_version': 1,
      'added': [_entryJson('reading', '1')],
      'removed': <dynamic>[],
    });
    expect(container.read(channelSignalsProvider).containsKey('c'), isFalse);
  });

  test('keeps one entry per account and replaces it in place', () async {
    repository.entries = <SignalEntry>[
      SignalEntry.fromJson(_entryJson('reading', '1')),
      SignalEntry.fromJson(_entryJson('reading', '2')),
    ];
    await signals().loadChannel('c');
    signals().handleChannelUpdate(<String, dynamic>{
      'channel_id': 'c',
      'bar_version': 1,
      'added': [
        _entryJson('reading', '1', personaId: '9', personaName: 'Kitsune'),
        _entryJson('reading', '3'),
      ],
      'removed': [
        {'signal_id': 'reading', 'user_id': '2'},
      ],
    });
    expect(entries('c').map((e) => '${e.userId}:${e.personaId}'), [
      '1:9',
      '3:null',
    ]);
    expect(entries('c').first.displayName, 'Kitsune');
  });

  test('refetches the bar only when a newer version is reported', () async {
    await container.read(signalBarConfigProvider.notifier).refresh();
    expect(repository.barFetches, 1);
    handleSignalBarGatewayEvent(
      container.read(_refProvider),
      'SIGNAL_BAR_UPDATE',
      <String, dynamic>{'version': 1},
    );
    expect(repository.barFetches, 1);
    handleSignalBarGatewayEvent(
      container.read(_refProvider),
      'SIGNAL_BAR_UPDATE',
      <String, dynamic>{'version': 2},
    );
    expect(repository.barFetches, 2);
  });

  test(
    'a channel is off until loaded as enabled, and follows the gateway',
    () async {
      expect(signals().isEnabled('c'), isFalse);
      repository.enabled = false;
      await signals().loadChannel('c');
      expect(signals().isEnabled('c'), isFalse);

      handleSignalBarGatewayEvent(
        container.read(_refProvider),
        'CHANNEL_SIGNAL_BAR_UPDATE',
        <String, dynamic>{'channel_id': 'c', 'enabled': true},
      );
      expect(signals().isEnabled('c'), isTrue);

      signals().handleChannelUpdate(<String, dynamic>{
        'channel_id': 'c',
        'bar_version': 1,
        'added': [_entryJson('reading', '1')],
        'removed': <dynamic>[],
      });
      handleSignalBarGatewayEvent(
        container.read(_refProvider),
        'CHANNEL_SIGNAL_BAR_UPDATE',
        <String, dynamic>{'channel_id': 'c', 'enabled': false},
      );
      expect(signals().isEnabled('c'), isFalse);
      expect(entries('c'), isEmpty);
    },
  );

  test('a manager turning off someone else removes them locally', () async {
    repository.entries = <SignalEntry>[
      SignalEntry.fromJson(_entryJson('reading', '1')),
      SignalEntry.fromJson(_entryJson('reading', '2')),
    ];
    await signals().loadChannel('c');
    await signals().removeUser('c', 'reading', userId: '2');
    expect(entries('c').map((e) => e.userId), ['1']);
    expect(repository.calls, ['REMOVE c reading 2']);
  });

  test('removes the own entry locally when turning a signal off', () async {
    repository.entries = <SignalEntry>[
      SignalEntry.fromJson(_entryJson('reading', '1')),
    ];
    await signals().loadChannel('c');
    await signals().deactivate('c', 'reading', userId: '1');
    expect(entries('c'), isEmpty);
    expect(repository.calls, ['DELETE c reading']);
  });

  test(
    'shows the own signals of one channel as the persona it is given',
    () async {
      repository.entries = <SignalEntry>[
        SignalEntry.fromJson(_entryJson('reading', '1')),
        SignalEntry.fromJson(_entryJson('reading', '2')),
      ];
      await signals().loadChannel('c');
      await signals().loadChannel('elsewhere');

      signals().affirmPersona(
        'c',
        userId: '1',
        persona: const SignalPersona(id: '9', name: 'Kitsune', avatar: 'hash'),
      );
      expect(repository.calls, ['PUT c reading 9']);
      expect(entries('c').first.personaId, '9');
      expect(entries('c').first.displayName, 'Kitsune');
      // Another account's signal, and the same account's in another channel,
      // are not touched.
      expect(entries('c').last.personaId, isNull);
      expect(entries('elsewhere').first.personaId, isNull);

      // Already showing that persona: nothing to send.
      signals().affirmPersona(
        'c',
        userId: '1',
        persona: const SignalPersona(id: '9', name: 'Kitsune'),
      );
      expect(repository.calls, hasLength(1));

      signals().affirmPersona('c', userId: '1', persona: null);
      expect(repository.calls.last, 'PUT c reading -');
      expect(entries('c').first.personaId, isNull);
    },
  );

  test('leaves a channel that was never loaded alone', () {
    signals().affirmPersona(
      'unloaded',
      userId: '1',
      persona: const SignalPersona(id: '9', name: 'Kitsune'),
    );
    expect(repository.calls, isEmpty);
    expect(entries('unloaded'), isEmpty);
  });

  test(
    'loading a channel never re-sends a signal lit as someone else',
    () async {
      // The signal was lit as a persona. Opening the channel later, with any
      // other persona active, is not something done in the channel.
      repository.entries = <SignalEntry>[
        SignalEntry.fromJson(
          _entryJson('reading', '1', personaId: '9', personaName: 'Kitsune'),
        ),
      ];
      await signals().loadChannel('c');
      await signals().loadChannel('c');
      expect(repository.calls, isEmpty);
      expect(entries('c').single.personaId, '9');
    },
  );
}

final Provider<Ref> _refProvider = Provider<Ref>((Ref ref) => ref);
