import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/utils/timezone_data.dart';
import 'package:fluxer_app/features/chat/utils/timezone_picker_utils.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(ensureTimezonesInitialized);

  group('findTimezoneOption', () {
    test('finds exact match by ianaName', () {
      final opt = findTimezoneOption('America/Los_Angeles');
      expect(opt.value, 'America/Los_Angeles');
      expect(opt.label, contains('Pacific Time - Los Angeles'));
    });

    test('normalizes Etc/UTC to UTC', () {
      final opt = findTimezoneOption('Etc/UTC');
      expect(opt.value, 'UTC');
    });

    test('finds deviceIanaName when ianaName is null', () {
      final opt = findTimezoneOption(null, -420, 'America/Los_Angeles');
      expect(opt.value, 'America/Los_Angeles');
    });

    test('prefers UTC for offset 0 instead of Azores', () {
      final opt = findTimezoneOption(null, 0);
      expect(opt.value, 'UTC');
      expect(opt.offsetMinutes, 0);
    });

    test('prefers America/Los_Angeles for offset -420 instead of Hermosillo', () {
      final opt = findTimezoneOption(null, -420);
      expect(opt.value, 'America/Los_Angeles');
      expect(opt.offsetMinutes, -420);
    });
  });

  group('safeGetLocation', () {
    test('resolves UTC and aliases to tz.UTC', () {
      expect(safeGetLocation('UTC'), tz.UTC);
      expect(safeGetLocation('Etc/UTC'), tz.UTC);
      expect(safeGetLocation('GMT'), tz.UTC);
    });

    test('resolves standard IANA timezone', () {
      expect(safeGetLocation('America/Los_Angeles')?.name, 'America/Los_Angeles');
    });

    test('returns null gracefully for non-existent timezone', () {
      expect(safeGetLocation('NonExistent/Zone'), isNull);
    });
  });

  group('getCurrentWallClockTime', () {
    test('computes wall clock for UTC without throwing', () {
      final opt = findTimezoneOption('UTC');
      final wallClock = getCurrentWallClockTime(opt);
      final nowUtc = DateTime.now().toUtc();
      expect(wallClock.year, nowUtc.year);
      expect(wallClock.month, nowUtc.month);
      expect(wallClock.day, nowUtc.day);
      expect(wallClock.hour, nowUtc.hour);
    });

    test('computes wall clock for offset-only fallback timezone without throwing', () {
      const opt = TimezoneOption(
        value: 'Europe/Amsterdam',
        label: 'Amsterdam',
        searchText: 'Amsterdam',
        offsetMinutes: 120,
      );
      final wallClock = getCurrentWallClockTime(opt);
      final expected = DateTime.now().toUtc().add(const Duration(minutes: 120));
      expect(wallClock.hour, expected.hour);
    });
  });

  group('adjustToViewerTimezone', () {
    test('returns original datetime when timezone is null or empty', () {
      final dt = DateTime.utc(2026, 4, 20, 15, 30);
      expect(adjustToViewerTimezone(dt, null), dt);
      expect(adjustToViewerTimezone(dt, ''), dt);
    });

    test('handles UTC timezone explicitly without throwing', () {
      final dt = DateTime.utc(2026, 4, 20, 15, 30);
      final adjusted = adjustToViewerTimezone(dt, 'UTC');
      expect(adjusted.year, 2026);
      expect(adjusted.month, 4);
      expect(adjusted.day, 20);
      expect(adjusted.hour, 15);
      expect(adjusted.minute, 30);
    });

    test('adjusts UTC instant to Tokyo wall-clock (UTC+9)', () {
      // 2026-04-20 12:00 UTC -> 2026-04-20 21:00 Tokyo
      final dt = DateTime.utc(2026, 4, 20, 12);
      final adjusted = adjustToViewerTimezone(dt, 'Asia/Tokyo');
      expect(adjusted.year, 2026);
      expect(adjusted.month, 4);
      expect(adjusted.day, 20);
      expect(adjusted.hour, 21);
      expect(adjusted.minute, 0);
    });

    test('adjusts UTC instant to New York wall-clock (EDT, UTC-4)', () {
      // 2026-04-20 12:00 UTC -> 2026-04-20 08:00 New York
      final dt = DateTime.utc(2026, 4, 20, 12);
      final adjusted = adjustToViewerTimezone(dt, 'America/New_York');
      expect(adjusted.year, 2026);
      expect(adjusted.month, 4);
      expect(adjusted.day, 20);
      expect(adjusted.hour, 8);
      expect(adjusted.minute, 0);
    });
  });

  group('calculateEpochFromWallClock', () {
    test('calculates correct epoch for wall clock in timezone', () {
      final date = DateTime(2026, 4, 20);
      final epoch = calculateEpochFromWallClock(
        wallClockDate: date,
        hour: 21,
        minute: 0,
        timezoneIana: 'Asia/Tokyo',
        fallbackOffsetMinutes: 540,
      );
      // 21:00 Tokyo = 12:00 UTC on 2026-04-20
      final utc = DateTime.utc(2026, 4, 20, 12);
      expect(epoch, utc.millisecondsSinceEpoch ~/ 1000);
    });

    test('calculates correct epoch for UTC without throwing', () {
      final date = DateTime(2026, 4, 20);
      final epoch = calculateEpochFromWallClock(
        wallClockDate: date,
        hour: 15,
        minute: 30,
        timezoneIana: 'UTC',
        fallbackOffsetMinutes: 0,
      );
      final utc = DateTime.utc(2026, 4, 20, 15, 30);
      expect(epoch, utc.millisecondsSinceEpoch ~/ 1000);
    });
  });
}
