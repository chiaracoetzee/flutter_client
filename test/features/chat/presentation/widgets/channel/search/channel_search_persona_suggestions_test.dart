import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';
import 'package:fluxer_app/features/chat/domain/channel_search_token.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/channel/search/channel_search_persona_suggestions.dart';
import 'package:fluxer_app/material_ui.dart';

import '../../../../../../helpers/pump_fluxer_app.dart';

/// Fails the test if the widget goes to the network: the personas below are
/// already in the cache.
class _NoNetwork extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    fail('unexpected request to ${options.path}');
  }
}

void main() {
  setUp(() {
    ChannelPersonaMentionCache.instance.setChannelPersonas(
      'c1',
      <Map<String, dynamic>>[
        <String, dynamic>{
          'id': '501',
          'name': 'Ash',
          'visibility': 'public',
          'use_count': 0,
          'owner_user_id': '700',
          'owner_username': 'alice',
        },
      ],
    );
  });

  tearDown(ChannelPersonaMentionCache.instance.clear);

  Widget suggestions({
    required String query,
    required ValueChanged<ChannelSearchToken> onPick,
  }) {
    final Dio dio = Dio()..interceptors.add(_NoNetwork());
    return pumpFluxerApp(
      overrides: [fluxerDioProvider.overrideWithValue(dio)],
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            ChannelSearchPersonaSuggestions(
              channelId: 'c1',
              guildId: null,
              kind: ChannelSearchTokenKind.mentions,
              query: query,
              onPick: onPick,
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('lists matching personas and picks one as a persona token', (
    WidgetTester tester,
  ) async {
    final List<ChannelSearchToken> picked = <ChannelSearchToken>[];
    await tester.pumpWidget(suggestions(query: 'as', onPick: picked.add));
    await tester.pump();

    expect(find.text('Personas'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);

    await tester.tap(find.text('Ash'));
    expect(picked, <ChannelSearchToken>[
      const ChannelSearchToken(
        kind: ChannelSearchTokenKind.mentions,
        value: 'persona:501',
        label: 'Ash',
      ),
    ]);
  });

  testWidgets('shows nothing before anything is typed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      suggestions(query: '', onPick: (ChannelSearchToken _) {}),
    );
    await tester.pump();

    expect(find.text('Personas'), findsNothing);
    expect(find.text('Ash'), findsNothing);
  });
}
