import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../theme/app_theme.dart';

class WeekDayPicker extends StatefulWidget {
  const WeekDayPicker({super.key});

  @override
  State<WeekDayPicker> createState() => _WeekDayPickerState();
}

class _WeekDayPickerState extends State<WeekDayPicker> {
  int selectedIndex = 3; // Wed = index 3

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (index) {
        final day = weekDays[index];
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => selectedIndex = index),
          child: _DayItem(day: day, isSelected: isSelected),
        );
      }),
    );
  }
}

class _DayItem extends StatelessWidget {
  final DayItem day;
  final bool isSelected;

  const _DayItem({required this.day, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 42,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.daySelected : AppColors.dayUnselected,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day.label,
            style: AppTextStyles.dayLabel.copyWith(
              color: isSelected ? AppColors.textLight : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${day.date}',
            style: AppTextStyles.dayNumber.copyWith(
              color: isSelected ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedOpacity(
            opacity: day.hasEvent && !isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.dayDot,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (!day.hasEvent || isSelected) const SizedBox(height: 5),
        ],
      ),
    );
  }
}
