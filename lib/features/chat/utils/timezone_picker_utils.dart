import 'package:flutter_timezone/flutter_timezone.dart';
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

Future<String> getDeviceIanaTimezone() async {
  try {
    return await FlutterTimezone.getLocalTimezone();
  } on Object {
    return 'UTC';
  }
}

tz.Location? safeGetLocation(String? timezoneIana) {
  if (timezoneIana == null || timezoneIana.isEmpty) {
    return null;
  }
  ensureTimezonesInitialized();
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
  final DateTime utcNow = DateTime.now().toUtc().add(Duration(minutes: option.offsetMinutes));
  return DateTime(
    utcNow.year,
    utcNow.month,
    utcNow.day,
    utcNow.hour,
    utcNow.minute,
    utcNow.second,
  );
}

DateTime adjustToViewerTimezone(DateTime dt, String? timezoneIana) {
  if (timezoneIana == null || timezoneIana.isEmpty) {
    return dt;
  }
  final tz.Location? loc = safeGetLocation(timezoneIana);
  if (loc != null) {
    try {
      final tzDt = tz.TZDateTime.fromMillisecondsSinceEpoch(
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
    } on Object {
      // Fall through to offset calculation below
    }
  }

  final TimezoneOption option = findTimezoneOption(timezoneIana);
  final DateTime utcDt = dt.toUtc().add(Duration(minutes: option.offsetMinutes));
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

const Map<int, String> kPreferredTimezonesByOffset = <int, String>{
  0: 'UTC',
  -420: 'America/Los_Angeles', // UTC-7 (PDT)
  -480: 'America/Los_Angeles', // UTC-8 (PST)
  -300: 'America/New_York',    // UTC-5 (CDT/EST)
  -240: 'America/New_York',    // UTC-4 (EDT)
  -360: 'America/Chicago',     // UTC-6 (CST)
  60: 'Europe/London',        // UTC+1 (BST)
  120: 'Europe/Paris',        // UTC+2 (CEST)
  540: 'Asia/Tokyo',          // UTC+9 (JST)
};

String _normalizeIanaName(String name) {
  if (name == 'Etc/UTC' || name == 'Etc/UCT' || name == 'GMT' || name == 'Etc/GMT') {
    return 'UTC';
  }
  return name;
}

TimezoneOption findTimezoneOption(
  String? ianaName, [
  int? fallbackOffsetMinutes,
  String? deviceIanaName,
]) {
  if (ianaName != null && ianaName.isNotEmpty) {
    final String normalized = _normalizeIanaName(ianaName);
    for (final option in kTimezoneOptions) {
      if (option.value == normalized || option.value == ianaName) {
        return option;
      }
    }
  }

  if (deviceIanaName != null && deviceIanaName.isNotEmpty) {
    final String normalized = _normalizeIanaName(deviceIanaName);
    for (final option in kTimezoneOptions) {
      if (option.value == normalized || option.value == deviceIanaName) {
        return option;
      }
    }
  }

  final int targetOffset = fallbackOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes;

  final String? preferredIana = kPreferredTimezonesByOffset[targetOffset];
  if (preferredIana != null) {
    for (final option in kTimezoneOptions) {
      if (option.value == preferredIana) {
        return option;
      }
    }
  }

  TimezoneOption? bestMatch;
  int minDiff = 100000;
  for (final option in kTimezoneOptions) {
    final diff = (option.offsetMinutes - targetOffset).abs();
    if (diff < minDiff) {
      minDiff = diff;
      bestMatch = option;
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
  final tz.Location? location = safeGetLocation(timezoneIana);
  if (location != null) {
    try {
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
      // Fall through to offset calculation
    }
  }
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
