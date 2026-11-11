class StreakCalendar {
  final String month;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final DateTime? trackedFromDate;
  final bool streakUpdatedToday;
  final Set<DateTime> activeDates;
  final Set<DateTime> missedDates;

  const StreakCalendar({
    required this.month,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.trackedFromDate,
    required this.streakUpdatedToday,
    required this.activeDates,
    required this.missedDates,
  });

  factory StreakCalendar.fromJson(Map<String, dynamic> json) {
    return StreakCalendar(
      month: json['month']?.toString() ?? '',
      currentStreak: _readInt(json['currentStreak']),
      longestStreak: _readInt(json['longestStreak']),
      lastActivityDate: _readDate(json['lastActivityDate']),
      trackedFromDate: _readDate(json['trackedFromDate']),
      streakUpdatedToday: json['streakUpdatedToday'] == true,
      activeDates: _readDates(json['activeDates']),
      missedDates: _readDates(json['missedDates']),
    );
  }

  static Set<DateTime> _readDates(Object? value) {
    if (value is! List) return <DateTime>{};

    return value
        .map((date) => DateTime.tryParse(date.toString()))
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    final date = DateTime.tryParse(value.toString());
    return date == null ? null : DateTime(date.year, date.month, date.day);
  }

  static int _readInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
