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
  int barFetches = 0;
  final List<String> calls = <String>[];

  @override
  Future<SignalBarConfig> fetchBar() async {
    barFetches++;
    return bar;
  }

  @override
  Future<({int barVersion, List<SignalEntry> entries})> fetchChannel(
    String channelId,
  ) async => (barVersion: bar.version, entries: entries);

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

  test('removes the own entry locally when turning a signal off', () async {
    repository.entries = <SignalEntry>[
      SignalEntry.fromJson(_entryJson('reading', '1')),
    ];
    await signals().loadChannel('c');
    await signals().deactivate('c', 'reading', userId: '1');
    expect(entries('c'), isEmpty);
    expect(repository.calls, ['DELETE c reading']);
  });

  test('follows the composer persona only when it changes', () async {
    repository.entries = <SignalEntry>[
      SignalEntry.fromJson(_entryJson('reading', '1')),
      SignalEntry.fromJson(_entryJson('reading', '2')),
    ];
    await signals().loadChannel('c');

    signals().reportOwnPersona('c', userId: '1', persona: null);
    expect(repository.calls, isEmpty);

    signals().reportOwnPersona(
      'c',
      userId: '1',
      persona: const SignalPersona(id: '9', name: 'Kitsune', avatar: 'hash'),
    );
    expect(repository.calls, ['PUT c reading 9']);
    expect(entries('c').first.personaId, '9');
    expect(entries('c').first.displayName, 'Kitsune');
    expect(entries('c').last.personaId, isNull);

    signals().reportOwnPersona(
      'c',
      userId: '1',
      persona: const SignalPersona(id: '9', name: 'Kitsune'),
    );
    expect(repository.calls, hasLength(1));

    signals().reportOwnPersona('c', userId: '1', persona: null);
    expect(repository.calls.last, 'PUT c reading -');
    expect(entries('c').first.personaId, isNull);
  });

  test(
    'a first persona report never re-sends, so devices do not fight',
    () async {
      repository.entries = <SignalEntry>[
        SignalEntry.fromJson(
          _entryJson('reading', '1', personaId: '9', personaName: 'Kitsune'),
        ),
      ];
      await signals().loadChannel('c');
      signals().reportOwnPersona('c', userId: '1', persona: null);
      expect(repository.calls, isEmpty);
      expect(entries('c').single.personaId, '9');
    },
  );
}

final Provider<Ref> _refProvider = Provider<Ref>((Ref ref) => ref);
