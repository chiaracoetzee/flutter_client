import 'package:chrono_dart/chrono_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chrono natural language date parsing', () {
    test('parses relative date and time "tomorrow at 3pm"', () {
      final now = DateTime(2026, 9, 22, 10);
      final results = Chrono.parse(
        'tomorrow at 3pm',
        ref: now,
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isNotEmpty);
      final first = results.first;
      final dt = first.date();
      expect(dt.year, 2026);
      expect(dt.month, 9);
      expect(dt.day, 23);
      expect(dt.hour, 15);
      expect(dt.minute, 0);
      expect(first.start.isCertain(Component.hour), isTrue);
    });

    test('parses relative offset "in 2 hours"', () {
      final now = DateTime(2026, 9, 22, 10);
      final results = Chrono.parse(
        'in 2 hours',
        ref: now,
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isNotEmpty);
      final first = results.first;
      final dt = first.date();
      expect(dt.hour, 12);
      expect(first.start.isCertain(Component.hour), isTrue);
    });

    test('parses weekday "next friday" with forwardDate', () {
      final now = DateTime(2026, 9, 22, 10); // Tuesday
      final results = Chrono.parse(
        'next friday',
        ref: now,
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isNotEmpty);
      final first = results.first;
      final dt = first.date();
      expect(dt.weekday, DateTime.friday);
      expect(dt.isAfter(now), isTrue);
      // Hour is implied (not certain) when only weekday is mentioned
      expect(first.start.isCertain(Component.hour), isFalse);
    });

    test('parses absolute date "december 25"', () {
      final now = DateTime(2026, 9, 22, 10);
      final results = Chrono.parse(
        'december 25',
        ref: now,
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isNotEmpty);
      final first = results.first;
      final dt = first.date();
      expect(dt.month, 12);
      expect(dt.day, 25);
      expect(first.start.isCertain(Component.hour), isFalse);
    });

    test('parses time expression only "5pm"', () {
      final now = DateTime(2026, 9, 22, 10);
      final results = Chrono.parse(
        '5pm',
        ref: now,
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isNotEmpty);
      final first = results.first;
      final dt = first.date();
      expect(dt.hour, 17);
      expect(dt.minute, 0);
      expect(first.start.isCertain(Component.hour), isTrue);
    });

    test('handles empty or non-date text gracefully without throwing', () {
      final results = Chrono.parse(
        'hello world',
        option: ParsingOption(forwardDate: true),
      );
      expect(results, isEmpty);
    });
  });
}
