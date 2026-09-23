import 'package:fluxer_app/features/chat/utils/timezone_data.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

bool _tzInitialized = false;

void ensureTimezonesInitialized() {
  if (!_tzInitialized) {
    tz.initializeTimeZones();
    _tzInitialized = true;
  }
}

TimezoneOption findTimezoneOption(String? ianaName, [int? fallbackOffsetMinutes]) {
  if (ianaName != null && ianaName.isNotEmpty) {
    for (final option in kTimezoneOptions) {
      if (option.value == ianaName) {
        return option;
      }
    }
  }

  final int targetOffset = fallbackOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes;

  TimezoneOption? bestMatch;
  int minDiff = 100000;
  for (final option in kTimezoneOptions) {
    final diff = (option.offsetMinutes - targetOffset).abs();
    if (diff < minDiff) {
      minDiff = diff;
      bestMatch = option;
      if (diff == 0 && (option.value.contains('UTC') || option.value == 'UTC')) {
        // keep candidate
      }
    }
  }

  return bestMatch ?? kTimezoneOptions.first;
}

int calculateEpochFromWallClock({
  required DateTime wallClockDate,
  required int hour,
  required int minute,
  required String timezoneIana,
  required int fallbackOffsetMinutes,
  int second = 0,
}) {
  ensureTimezonesInitialized();

  try {
    final location = tz.getLocation(timezoneIana);
    final tzDateTime = tz.TZDateTime(
      location,
      wallClockDate.year,
      wallClockDate.month,
      wallClockDate.day,
      hour,
      minute,
      second,
    );
    return tzDateTime.millisecondsSinceEpoch ~/ 1000;
  } on Object {
    final DateTime utcBase = DateTime.utc(
      wallClockDate.year,
      wallClockDate.month,
      wallClockDate.day,
      hour,
      minute,
      second,
    );
    return (utcBase.millisecondsSinceEpoch ~/ 1000) - (fallbackOffsetMinutes * 60);
  }
}
