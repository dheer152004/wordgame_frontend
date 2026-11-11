import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/streak_calendar_model.dart';

void main() {
  test('parses calendar streak metrics and date-only activity records', () {
    final calendar = StreakCalendar.fromJson({
      'month': '2026-11',
      'currentStreak': 2,
      'longestStreak': 2,
      'lastActivityDate': '2026-11-10',
      'trackedFromDate': '2026-11-06',
      'streakUpdatedToday': true,
      'activeDates': ['2026-11-06', '2026-11-09', '2026-11-10'],
      'missedDates': ['2026-11-07', '2026-11-08'],
    });

    expect(calendar.month, '2026-11');
    expect(calendar.currentStreak, 2);
    expect(calendar.longestStreak, 2);
    expect(calendar.streakUpdatedToday, isTrue);
    expect(calendar.activeDates, contains(DateTime(2026, 11, 6)));
    expect(calendar.activeDates, contains(DateTime(2026, 11, 9)));
    expect(calendar.activeDates, contains(DateTime(2026, 11, 10)));
    expect(calendar.missedDates, contains(DateTime(2026, 11, 7)));
    expect(calendar.missedDates, contains(DateTime(2026, 11, 8)));
    expect(calendar.trackedFromDate, DateTime(2026, 11, 6));
  });
}
