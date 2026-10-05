// Fork: tests the fork adds, kept out of upstream's typing_indicator_bar_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/gateway/providers/gateway_event_providers.dart';
import 'package:fluxer_dart/models/message_subprofile_response_schema.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../helpers/open_test_database.dart';
import 'typing_indicator_bar_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    forkDatabase = openTestDatabase();
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
      await forkUpstream.pumpTypingIndicatorBar(tester, compact: false);
      container.read(typingIndicatorsProvider.notifier).clearAll();
      container
          .read(typingIndicatorsProvider.notifier)
          .addTyping(
            'channel-1',
            forkKTyperUserId,
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
