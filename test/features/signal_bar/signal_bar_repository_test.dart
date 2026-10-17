// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/signal_bar/data/signal_bar_repository.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';

// Fork: the signal bar's REST calls, which go through Dio rather than the
// generated SDK.

void main() {
  late List<RequestOptions> requests;
  late Object? answer;

  SignalBarRepository repository() {
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/v1'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response<dynamic>(requestOptions: options, data: answer),
            );
          },
        ),
      );
    return SignalBarRepository(dio);
  }

  setUp(() {
    requests = <RequestOptions>[];
    answer = null;
  });

  test('reads the bar', () async {
    answer = <String, dynamic>{
      'version': 4,
      'guild_id': '42',
      'can_manage': true,
      'signals': <dynamic>[
        <String, dynamic>{
          'id': 's1',
          'emoji_id': null,
          'emoji_name': '📖',
          'animated': false,
          'label': 'Reading',
        },
      ],
    };

    final SignalBarConfig bar = await repository().fetchBar();

    expect(requests.single.method, 'GET');
    expect(requests.single.path, '/instance/signal-bar');
    expect(bar.version, 4);
    expect(bar.guildId, '42');
    expect(bar.canManage, isTrue);
    expect(bar.signals.single.label, 'Reading');
  });

  test(
    "reads a channel's signals, with the persona each is given as",
    () async {
      answer = <String, dynamic>{
        'enabled': true,
        'bar_version': 4,
        'entries': <dynamic>[
          <String, dynamic>{
            'signal_id': 's1',
            'user': <String, dynamic>{'id': '7', 'username': 'alice'},
            'persona_id': 'p1',
            'subprofile': <String, dynamic>{'name': 'Bob', 'avatar': 'b0b'},
          },
        ],
      };

      final channel = await repository().fetchChannel('c1');

      expect(requests.single.path, '/channels/c1/signals');
      expect(channel.enabled, isTrue);
      expect(channel.barVersion, 4);
      final SignalEntry entry = channel.entries.single;
      expect(entry.userId, '7');
      expect(entry.personaId, 'p1');
      expect(entry.personaName, 'Bob');
      expect(entry.personaAvatar, 'b0b');
    },
  );

  test('reads an empty answer as a switched-off channel', () async {
    final channel = await repository().fetchChannel('c1');

    expect(channel.enabled, isFalse);
    expect(channel.barVersion, 0);
    expect(channel.entries, isEmpty);
  });

  test('names the persona only when giving a signal as one', () async {
    final SignalBarRepository signals = repository();

    await signals.activate('c1', 's1', personaId: 'p1');
    await signals.activate('c1', 's1');

    expect(requests.map((r) => (r.method, r.path)), [
      ('PUT', '/channels/c1/signals/s1/@me'),
      ('PUT', '/channels/c1/signals/s1/@me'),
    ]);
    expect(requests[0].data, <String, dynamic>{'persona_id': 'p1'});
    expect(requests[1].data, <String, dynamic>{});
  });

  test('withdraws, removes and resets signals at their own paths', () async {
    final SignalBarRepository signals = repository();

    await signals.deactivate('c1', 's1');
    await signals.removeUser('c1', 's1', '7');
    await signals.reset('c1', 's1');

    expect(requests.map((r) => (r.method, r.path)), [
      ('DELETE', '/channels/c1/signals/s1/@me'),
      ('DELETE', '/channels/c1/signals/s1/users/7'),
      ('DELETE', '/channels/c1/signals/s1'),
    ]);
  });
}
