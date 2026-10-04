import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/streak_calendar_model.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late DateTime _selectedMonth;
  StreakCalendar? _calendar;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final calendar = await BackendApi.instance.fetchStreakCalendar(
        _selectedMonth,
      );
      if (!mounted) return;
      setState(() {
        _calendar = calendar;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _changeMonth(int amount) {
    final candidate = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + amount,
    );
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    if (candidate.isAfter(currentMonth)) return;

    setState(() => _selectedMonth = candidate);
    _loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _calendar?.currentStreak ?? 0;
    final longestStreak = _calendar?.longestStreak ?? 0;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      appBar: AppBar(
        backgroundColor: AppThemeColors.background(context),
        foregroundColor: AppThemeColors.textPrimary(context),
        elevation: 0,
        title: const Text('Streak'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadCalendar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryMetric(
                      context,
                      LucideIcons.flame,
                      const Color(0xFFFF762B),
                      '$currentStreak',
                      'Current streak',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryMetric(
                      context,
                      LucideIcons.trophy,
                      AppThemeColors.primary(context),
                      '$longestStreak',
                      'Longest streak',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _calendarPanel(context),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: [
                  _legend(context, const Color(0xFFFF762B), 'Quiz complete'),
                  _legend(context, const Color(0xFFE35D65), 'Missed'),
                  _legend(
                    context,
                    AppThemeColors.divider(context),
                    'Untracked',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _activityStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarPanel(BuildContext context) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final leadingDays = firstDay.weekday - 1;
    final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trackedFrom = _calendar?.trackedFromDate;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: _loading ? null : () => _changeMonth(-1),
                icon: const Icon(LucideIcons.chevronLeft, size: 19),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppThemeColors.textPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: _loading || _isCurrentMonth
                    ? null
                    : () => _changeMonth(1),
                icon: const Icon(LucideIcons.chevronRight, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final weekday in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load streak history.',
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _loadCalendar,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 5,
                crossAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final day = index - leadingDays + 1;
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month,
                  day,
                );
                final isActive = _calendar!.activeDates.contains(date);
                final isToday = date == today;
                final isMissed =
                    !isActive &&
                    date.isBefore(today) &&
                    trackedFrom != null &&
                    !date.isBefore(trackedFrom);
                return _dayCell(context, day, isActive, isToday, isMissed);
              },
            ),
        ],
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    int day,
    bool isActive,
    bool isToday,
    bool isMissed,
  ) {
    final color = isActive
        ? const Color(0xFFFF762B)
        : isMissed
        ? const Color(0xFFE35D65).withAlpha(28)
        : Colors.transparent;
    final textColor = isActive
        ? Colors.white
        : isMissed
        ? const Color(0xFFE35D65)
        : AppThemeColors.textPrimary(context);

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: AppThemeColors.primary(context), width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: isMissed
          ? Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.lineThrough,
              ),
            )
          : Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isActive || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
    );
  }

  Widget _activityStatus(BuildContext context) {
    final lastActivity = _calendar?.lastActivityDate;
    final trackedFrom = _calendar?.trackedFromDate;
    final status = lastActivity == null
        ? 'No completed quiz recorded yet.'
        : 'Last quiz: ${_formatDate(lastActivity)}';
    final tracking = trackedFrom == null
        ? 'Calendar history will begin with your first completed quiz.'
        : 'Missed days are shown from ${_formatDate(trackedFrom)} onward.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status,
          style: TextStyle(
            color: AppThemeColors.textPrimary(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          tracking,
          style: TextStyle(
            color: AppThemeColors.textSecondary(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _summaryMetric(
    BuildContext context,
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppThemeColors.textSecondary(context),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  String _formatDate(DateTime date) =>
      '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}
