import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver.dart';

const String _perfOutputDirectory = 'build/perf';

Future<void> main() => integrationDriver(
  responseDataCallback: (Map<String, dynamic>? data) async {
    if (data == null) {
      return;
    }
    for (final MapEntry<String, dynamic> entry in data.entries) {
      final dynamic value = entry.value;
      if (value is! Map<String, dynamic>) {
        continue;
      }
      final TimelineSummary summary = TimelineSummary.summarize(
        Timeline.fromJson(value),
      );
      await summary.writeTimelineToFile(
        entry.key,
        pretty: true,
        destinationDirectory: _perfOutputDirectory,
      );
    }
    await writeResponseData(data, destinationDirectory: _perfOutputDirectory);
  },
);
