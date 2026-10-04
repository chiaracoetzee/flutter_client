// Fork: tests the fork adds, kept out of upstream's gateway_event_handler_missing_events_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/database/fluxer_database.dart';
import 'package:fluxer_app/core/gateway/gateway_event_handler.dart';
import 'package:fluxer_dart/gateway.dart';

import '../../helpers/open_test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GatewayEventHandler missing events', () {
    late FluxerDatabase database;

    setUp(() {
      database = openTestDatabase();
    });

    test('signal bar events are passed through unparsed', () async {
      final List<String> seen = <String>[];
      final handler = GatewayEventHandler(
        database: database,
        onSignalBarEvent: (String type, Map<String, dynamic> data) {
          seen.add('$type:${data['channel_id'] ?? data['version']}');
        },
      );

      await handler.handle(
        const UnknownGatewayEvent(
          eventType: 'CHANNEL_SIGNAL_UPDATE',
          data: <String, dynamic>{'channel_id': 'c1'},
        ),
      );
      await handler.handle(
        const UnknownGatewayEvent(
          eventType: 'SIGNAL_BAR_UPDATE',
          data: <String, dynamic>{'version': 3},
        ),
      );
      await handler.handle(
        const UnknownGatewayEvent(
          eventType: 'SOMETHING_ELSE',
          data: <String, dynamic>{},
        ),
      );

      expect(seen, <String>['CHANNEL_SIGNAL_UPDATE:c1', 'SIGNAL_BAR_UPDATE:3']);
    });
  });
}
