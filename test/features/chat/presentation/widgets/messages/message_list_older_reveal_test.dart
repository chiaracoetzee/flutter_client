import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/messages/message_list_viewport.dart';

import '../../../../../helpers/pump_fluxer_app.dart';
import 'message_list_test_harness.dart';

int withheldLeadingCount(WidgetTester tester) {
  return tester
      .widget<MessageListViewport>(find.byType(MessageListViewport))
      .withheldLeadingCount;
}

void main() {
  testWidgets('an installed older page is exposed two rows per frame', (
    WidgetTester tester,
  ) async {
    final AroundAckMessageListHarness harness =
        await createBottomMessageListHarness();
    await tester.pumpWidget(
      messageListApp(
        database: harness.database,
        chatViewModel: harness.chatViewModel,
      ),
    );
    await pumpFluxerFrames(tester);
    expect(withheldLeadingCount(tester), 0);

    harness.prependOlderMessages(count: 50);
    await tester.pump();
    expect(withheldLeadingCount(tester), 50);

    final List<int> exposed = <int>[];
    for (int frame = 0; frame < 25; frame += 1) {
      await tester.pump();
      exposed.add(50 - withheldLeadingCount(tester));
    }

    expect(exposed.take(3), <int>[2, 4, 6]);
    expect(exposed.last, 50);
    expect(withheldLeadingCount(tester), 0);

    await disposeMessageList(tester);
  });

  testWidgets('a jump exposes the whole installed page in one frame', (
    WidgetTester tester,
  ) async {
    final AroundAckMessageListHarness harness =
        await createBottomMessageListHarness();
    await tester.pumpWidget(
      messageListApp(
        database: harness.database,
        chatViewModel: harness.chatViewModel,
      ),
    );
    await pumpFluxerFrames(tester);

    harness.prependOlderMessages(count: 50);
    await tester.pump();
    await tester.pump();
    expect(withheldLeadingCount(tester), 48);

    harness.chatViewModel.testState = harness.chatViewModel.testState.copyWith(
      scrollToMessageSignal: (harness.ackId, 1),
    );
    await tester.pump();

    expect(withheldLeadingCount(tester), 0);

    await disposeMessageList(tester);
  });
}
