import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fluxer_app/features/chat/utils/timezone_data.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

bool _tzInitialized = false;

void _ensureInitialized() {
  if (!_tzInitialized) {
    tzdata.initializeTimeZones();
    _tzInitialized = true;
  }
}

/// Returns the device's IANA timezone name (e.g. 'America/Los_Angeles').
/// Falls back to 'UTC' if the platform plugin fails.
Future<String> getDeviceIanaTimezone() async {
  try {
    return await FlutterTimezone.getLocalTimezone();
  } on Object {
    return 'UTC';
  }
}

/// Resolves an IANA timezone name to a [tz.Location].
///
/// Handles UTC aliases ('Etc/UTC', 'GMT', etc.) and returns null
/// for unrecognized names rather than throwing.
tz.Location? safeGetLocation(String? timezoneIana) {
  if (timezoneIana == null || timezoneIana.isEmpty) {
    return null;
  }
  _ensureInitialized();
  if (timezoneIana == 'UTC' ||
      timezoneIana == 'Etc/UTC' ||
      timezoneIana == 'Etc/UCT' ||
      timezoneIana == 'GMT' ||
      timezoneIana == 'Etc/GMT') {
    return tz.UTC;
  }
  try {
    return tz.getLocation(timezoneIana);
  } on Object {
    return null;
  }
}

/// Returns the current wall-clock time in the given timezone as a
/// **naive DateTime**.
///
/// The returned DateTime's year, month, day, hour, minute, and second
/// fields represent the wall clock in the target timezone. However, it
/// is NOT timezone-aware — its `millisecondsSinceEpoch` and
/// `timeZoneOffset` are meaningless and must not be used for epoch
/// calculations. Use `calculateEpochFromWallClock` instead.
DateTime getCurrentWallClockTime(TimezoneOption option) {
  final tz.Location? loc = safeGetLocation(option.value);
  if (loc != null) {
    final tz.TZDateTime nowInZone = tz.TZDateTime.now(loc);
    return DateTime(
      nowInZone.year,
      nowInZone.month,
      nowInZone.day,
      nowInZone.hour,
      nowInZone.minute,
      nowInZone.second,
    );
  }
  // Fallback for unrecognized IANA names (should not happen with our
  // runtime-built list, but kept for defensive robustness).
  final DateTime utcNow =
      DateTime.now().toUtc().add(Duration(minutes: option.offsetMinutes));
  return DateTime(
    utcNow.year,
    utcNow.month,
    utcNow.day,
    utcNow.hour,
    utcNow.minute,
    utcNow.second,
  );
}

/// Converts a UTC epoch DateTime to a naive wall-clock DateTime
/// in the viewer's timezone. Used for rendering timestamps in messages.
///
/// For relative timestamps (flag 'R'), the caller should pass the
/// original epoch DateTime directly — no timezone conversion needed.
DateTime adjustToViewerTimezone(DateTime dt, String? timezoneIana) {
  if (timezoneIana == null || timezoneIana.isEmpty) {
    return dt;
  }
  final tz.Location? loc = safeGetLocation(timezoneIana);
  if (loc != null) {
    final tz.TZDateTime tzDt = tz.TZDateTime.fromMillisecondsSinceEpoch(
      loc,
      dt.millisecondsSinceEpoch,
    );
    return DateTime(
      tzDt.year,
      tzDt.month,
      tzDt.day,
      tzDt.hour,
      tzDt.minute,
      tzDt.second,
      tzDt.millisecond,
      tzDt.microsecond,
    );
  }
  // Fallback: use the option's static offset (less accurate for DST
  // but handles unknown IANA names gracefully).
  final TimezoneOption option = findTimezoneOption(timezoneIana);
  final DateTime utcDt =
      dt.toUtc().add(Duration(minutes: option.offsetMinutes));
  return DateTime(
    utcDt.year,
    utcDt.month,
    utcDt.day,
    utcDt.hour,
    utcDt.minute,
    utcDt.second,
    utcDt.millisecond,
    utcDt.microsecond,
  );
}

/// Normalizes known UTC aliases to the canonical 'UTC' string.
String _normalizeIanaName(String name) {
  if (name == 'Etc/UTC' ||
      name == 'Etc/UCT' ||
      name == 'GMT' ||
      name == 'Etc/GMT') {
    return 'UTC';
  }
  return name;
}

/// Finds a [TimezoneOption] by IANA name, device IANA name, or
/// as a last resort, by closest UTC offset match.
///
/// Priority:
/// 1. Exact match on [ianaName] (after normalization)
/// 2. Exact match on [deviceIanaName] (after normalization)
/// 3. Closest offset match from [fallbackOffsetMinutes] or system offset
/// 4. UTC (absolute fallback)
TimezoneOption findTimezoneOption(
  String? ianaName, [
  int? fallbackOffsetMinutes,
  String? deviceIanaName,
]) {
  // 1. Try exact match on provided IANA name.
  if (ianaName != null && ianaName.isNotEmpty) {
    final String normalized = _normalizeIanaName(ianaName);
    for (final TimezoneOption option in kTimezoneOptions) {
      if (option.value == normalized || option.value == ianaName) {
        return option;
      }
    }
  }

  // 2. Try exact match on device-reported IANA name.
  if (deviceIanaName != null && deviceIanaName.isNotEmpty) {
    final String normalized = _normalizeIanaName(deviceIanaName);
    for (final TimezoneOption option in kTimezoneOptions) {
      if (option.value == normalized || option.value == deviceIanaName) {
        return option;
      }
    }
  }

  // 3. Fall back to closest offset match (preferring UTC for offset 0).
  final int targetOffset =
      fallbackOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes;
  if (targetOffset == 0) {
    for (final TimezoneOption option in kTimezoneOptions) {
      if (option.value == 'UTC') {
        return option;
      }
    }
  }
  TimezoneOption? bestMatch;
  int minDiff = 100000;
  for (final TimezoneOption option in kTimezoneOptions) {
    final int diff = (option.offsetMinutes - targetOffset).abs();
    if (diff < minDiff) {
      minDiff = diff;
      bestMatch = option;
    }
  }

  return bestMatch ?? kTimezoneOptions.first;
}

/// Converts wall-clock date/time components in a specific timezone
/// to a Unix epoch (seconds since 1970-01-01T00:00:00Z).
///
/// Uses the `timezone` package's `TZDateTime` constructor which
/// correctly handles DST transitions. Falls back to static offset
/// arithmetic for unrecognized IANA names.
int calculateEpochFromWallClock({
  required DateTime wallClockDate,
  required int hour,
  required int minute,
  required String timezoneIana,
  int second = 0,
}) {
  final tz.Location? location = safeGetLocation(timezoneIana);
  if (location != null) {
    final tz.TZDateTime tzDateTime = tz.TZDateTime(
      location,
      wallClockDate.year,
      wallClockDate.month,
      wallClockDate.day,
      hour,
      minute,
      second,
    );
    return tzDateTime.millisecondsSinceEpoch ~/ 1000;
  }
  // Fallback: assume the option's static offset.
  final TimezoneOption option = findTimezoneOption(timezoneIana);
  final DateTime utcBase = DateTime.utc(
    wallClockDate.year,
    wallClockDate.month,
    wallClockDate.day,
    hour,
    minute,
    second,
  );
  return (utcBase.millisecondsSinceEpoch ~/ 1000) -
      (option.offsetMinutes * 60);
}
