// Fork: tests the fork adds, kept out of upstream's relative_time_test.dart so that file stays as
// upstream has it.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/shared/utils/relative_time.dart';

Future<FluxerLocalizations> _loadL10n() {
  WidgetsFlutterBinding.ensureInitialized();
  return FluxerLocalizations.delegate.load(const Locale('en'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('relativeTimestamp', () {
    test(
      'rounds future minutes correctly (e.g. 4m 50s rounds to in 5 minutes)',
      () async {
        final l10n = await _loadL10n();
        final DateTime now = DateTime(2026, 7, 20, 16);
        final resultExact = relativeTimestamp(
          now.add(const Duration(minutes: 5)),
          l10n,
          now: now,
        );
        expect(resultExact, 'in 5 minutes');

        // 4 minutes and 45 seconds (slight processing delay) rounds to 5 minutes
        final resultNear = relativeTimestamp(
          now.add(const Duration(minutes: 4, seconds: 45)),
          l10n,
          now: now,
        );
        expect(resultNear, 'in 5 minutes');
      },
    );
  });
}
