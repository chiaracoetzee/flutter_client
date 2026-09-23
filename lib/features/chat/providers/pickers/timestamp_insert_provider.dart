import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<PendingTimestampInsert, ({int epoch, String style})?>
pendingTimestampInsertProvider =
    NotifierProvider<PendingTimestampInsert, ({int epoch, String style})?>(
      PendingTimestampInsert.new,
    );

class PendingTimestampInsert extends Notifier<({int epoch, String style})?> {
  @override
  ({int epoch, String style})? build() => null;

  void emit(int epoch, String style) {
    state = (epoch: epoch, style: style);
  }

  void consume() {
    state = null;
  }
}
