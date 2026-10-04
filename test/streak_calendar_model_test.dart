import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/streak_calendar_model.dart';

void main() {
  test('parses calendar streak metrics and date-only activity records', () {
    final calendar = StreakCalendar.fromJson({
      'month': '2026-10',
      'currentStreak': 4,
      'longestStreak': 9,
      'lastActivityDate': '2026-10-02',
      'trackedFromDate': '2026-09-28',
      'streakUpdatedToday': true,
      'activeDates': ['2026-10-01', '2026-10-02'],
    });

    expect(calendar.month, '2026-10');
    expect(calendar.currentStreak, 4);
    expect(calendar.longestStreak, 9);
    expect(calendar.streakUpdatedToday, isTrue);
    expect(calendar.activeDates, contains(DateTime(2026, 10, 1)));
    expect(calendar.activeDates, contains(DateTime(2026, 10, 2)));
    expect(calendar.trackedFromDate, DateTime(2026, 9, 28));
  });
}
