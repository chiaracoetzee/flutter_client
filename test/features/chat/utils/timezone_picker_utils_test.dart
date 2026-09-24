import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/utils/timezone_data.dart';
import 'package:fluxer_app/features/chat/utils/timezone_picker_utils.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('kTimezoneOptions', () {
    test('is non-empty and contains UTC', () {
      expect(kTimezoneOptions, isNotEmpty);
      final utc = kTimezoneOptions.where((o) => o.value == 'UTC');
      expect(utc, hasLength(1));
      expect(utc.first.label, contains('UTC'));
      expect(utc.first.offsetMinutes, 0);
    });

    test('contains well-known timezones', () {
      final values = kTimezoneOptions.map((o) => o.value).toSet();
      expect(values, contains('America/Los_Angeles'));
      expect(values, contains('America/New_York'));
      expect(values, contains('Europe/London'));
      expect(values, contains('Asia/Tokyo'));
      expect(values, contains('Australia/Sydney'));
    });

    test('excludes Etc/ entries and Factory', () {
      for (final option in kTimezoneOptions) {
        expect(option.value.startsWith('Etc/'), isFalse,
            reason: '${option.value} should be filtered out');
        expect(option.value, isNot('Factory'));
      }
    });

    test('is sorted by offset ascending', () {
      for (int i = 1; i < kTimezoneOptions.length; i++) {
        expect(
          kTimezoneOptions[i].offsetMinutes,
          greaterThanOrEqualTo(kTimezoneOptions[i - 1].offsetMinutes),
          reason:
              '${kTimezoneOptions[i].value} should come after ${kTimezoneOptions[i - 1].value}',
        );
      }
    });

    test('every entry has a non-empty label and searchText', () {
      for (final option in kTimezoneOptions) {
        expect(option.label, isNotEmpty, reason: '${option.value} has empty label');
        expect(option.searchText, isNotEmpty,
            reason: '${option.value} has empty searchText');
      }
    });

    test('every non-UTC entry resolves via safeGetLocation', () {
      for (final option in kTimezoneOptions) {
        final loc = safeGetLocation(option.value);
        expect(loc, isNotNull,
            reason: '${option.value} should resolve to a tz.Location');
      }
    });
  });

  group('findTimezoneOption', () {
    test('finds exact match by ianaName', () {
      final opt = findTimezoneOption('America/Los_Angeles');
      expect(opt.value, 'America/Los_Angeles');
      expect(opt.label, contains('Pacific Time'));
      expect(opt.label, contains('Los Angeles'));
    });

    test('normalizes Etc/UTC to UTC', () {
      final opt = findTimezoneOption('Etc/UTC');
      expect(opt.value, 'UTC');
    });

    test('normalizes GMT to UTC', () {
      final opt = findTimezoneOption('GMT');
      expect(opt.value, 'UTC');
    });

    test('finds deviceIanaName when ianaName is null', () {
      final opt = findTimezoneOption(null, null, 'America/Los_Angeles');
      expect(opt.value, 'America/Los_Angeles');
    });

    test('falls back to closest offset match for unknown IANA name', () {
      // Pass an IANA name that doesn't exist in our list, with offset 0
      final opt = findTimezoneOption('Fake/Timezone', 0);
      expect(opt.value, 'UTC');
    });
  });

  group('safeGetLocation', () {
    test('resolves UTC and aliases to tz.UTC', () {
      expect(safeGetLocation('UTC'), tz.UTC);
      expect(safeGetLocation('Etc/UTC'), tz.UTC);
      expect(safeGetLocation('GMT'), tz.UTC);
    });

    test('resolves standard IANA timezone', () {
      expect(
          safeGetLocation('America/Los_Angeles')?.name, 'America/Los_Angeles');
    });

    test('returns null gracefully for non-existent timezone', () {
      expect(safeGetLocation('NonExistent/Zone'), isNull);
    });

    test('returns null for null or empty input', () {
      expect(safeGetLocation(null), isNull);
      expect(safeGetLocation(''), isNull);
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

    test('computes wall clock for Los Angeles without throwing', () {
      final opt = findTimezoneOption('America/Los_Angeles');
      final wallClock = getCurrentWallClockTime(opt);
      // Just verify it doesn't throw and returns reasonable values
      expect(wallClock.year, greaterThanOrEqualTo(2024));
      expect(wallClock.hour, inInclusiveRange(0, 23));
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
      );
      final utc = DateTime.utc(2026, 4, 20, 15, 30);
      expect(epoch, utc.millisecondsSinceEpoch ~/ 1000);
    });

    test('handles DST transition correctly for US timezones', () {
      // 2026-03-08 02:30 America/New_York is during spring-forward
      // The tz package handles this by pushing to 03:30
      final date = DateTime(2026, 3, 8);
      final epoch = calculateEpochFromWallClock(
        wallClockDate: date,
        hour: 3,
        minute: 30,
        timezoneIana: 'America/New_York',
      );
      // 03:30 EDT (UTC-4) = 07:30 UTC
      final utc = DateTime.utc(2026, 3, 8, 7, 30);
      expect(epoch, utc.millisecondsSinceEpoch ~/ 1000);
    });
  });
}
