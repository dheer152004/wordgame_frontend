import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/backend_api.dart';
import '../../../../services/session_store.dart';
import '../../../../theme/app_theme.dart';

class DateOfBirthDialog extends StatefulWidget {
  final DateTime? initialDate;
  final bool canSkip;

  const DateOfBirthDialog({super.key, this.initialDate, this.canSkip = true});

  @override
  State<DateOfBirthDialog> createState() => _DateOfBirthDialogState();
}

class _DateOfBirthDialogState extends State<DateOfBirthDialog> {
  static const int _firstYear = 1900;
  static const List<String> _months = [
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

  late DateTime _selectedDate;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;
  late final FixedExtentScrollController _yearController;
  late final TapGestureRecognizer _privacyLinkRecognizer;
  bool _isSaving = false;
  String? _errorMessage;

  int get _currentYear => DateTime.now().year;
  int get _daysInSelectedMonth =>
      DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final initialDate =
        widget.initialDate ?? DateTime(today.year - 18, today.month, today.day);
    final boundedYear = initialDate.year.clamp(_firstYear, today.year);
    final boundedDate = DateTime(
      boundedYear,
      initialDate.month,
      initialDate.day,
    );
    _selectedDate = boundedDate.isAfter(today) ? today : boundedDate;
    _monthController = FixedExtentScrollController(
      initialItem: _selectedDate.month - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDate.day - 1,
    );
    _yearController = FixedExtentScrollController(
      initialItem: _selectedDate.year - _firstYear,
    );
    _privacyLinkRecognizer = TapGestureRecognizer()..onTap = _openPrivacyNotice;
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _privacyLinkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppThemeColors.textPrimary(context);
    final secondaryTextColor = AppThemeColors.textSecondary(context);
    final backgroundColor = AppThemeColors.background(context);
    final primaryColor = AppThemeColors.primary(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0,
                    constraints.maxHeight,
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: widget.canSkip
                          ? TextButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Skip'),
                            )
                          : const SizedBox(height: 48),
                    ),
                    SizedBox(
                      height: (constraints.maxHeight * 0.08).clamp(24, 80),
                    ),
                    Text(
                      'Select your\ndate of birth',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(
                      height: (constraints.maxHeight * 0.12).clamp(32, 100),
                    ),
                    SizedBox(
                      height: 228,
                      child: _buildDatePicker(
                        textColor: textColor,
                        backgroundColor: AppThemeColors.surfaceAlt(context),
                      ),
                    ),
                    SizedBox(
                      height: (constraints.maxHeight * 0.15).clamp(28, 120),
                    ),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Please refer to our '),
                          TextSpan(
                            text: 'Privacy notice',
                            style: TextStyle(
                              color: AppThemeColors.primary(context),
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: _privacyLinkRecognizer,
                          ),
                          const TextSpan(
                            text:
                                ' for further information on how we process this data.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: AppThemeColors.textOnPrimary(
                            context,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required Color textColor,
    required Color backgroundColor,
  }) {
    final today = DateTime.now();
    final monthCount = _selectedDate.year == today.year ? today.month : 12;

    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: CupertinoPicker(
                scrollController: _monthController,
                itemExtent: 42,
                selectionOverlay: const SizedBox.shrink(),
                onSelectedItemChanged: (index) {
                  final month = index + 1;
                  _updateDate(
                    year: _selectedDate.year,
                    month: month,
                    day: _selectedDate.day,
                  );
                },
                children: List.generate(
                  monthCount,
                  (index) => _pickerLabel(_months[index], textColor),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: CupertinoPicker(
                scrollController: _dayController,
                itemExtent: 42,
                selectionOverlay: const SizedBox.shrink(),
                onSelectedItemChanged: (index) {
                  _updateDate(
                    year: _selectedDate.year,
                    month: _selectedDate.month,
                    day: index + 1,
                  );
                },
                children: List.generate(
                  _daysInSelectedMonth,
                  (index) => _pickerLabel('${index + 1}', textColor),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: CupertinoPicker(
                scrollController: _yearController,
                itemExtent: 42,
                selectionOverlay: const SizedBox.shrink(),
                onSelectedItemChanged: (index) {
                  _updateDate(
                    year: _firstYear + index,
                    month: _selectedDate.month,
                    day: _selectedDate.day,
                  );
                },
                children: List.generate(
                  _currentYear - _firstYear + 1,
                  (index) => _pickerLabel('${_firstYear + index}', textColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pickerLabel(String label, Color color) {
    return Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 17),
      ),
    );
  }

  Future<void> _openPrivacyNotice() async {
    await launchUrl(
      Uri.parse('https://www.nroq.in/privacy-policy'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _updateDate({required int year, required int month, required int day}) {
    final today = DateTime.now();
    final daysInMonth = DateTime(year, month + 1, 0).day;
    var updatedDate = DateTime(year, month, day.clamp(1, daysInMonth));
    if (updatedDate.isAfter(today)) {
      updatedDate = today;
    }

    setState(() {
      _selectedDate = updatedDate;
      _errorMessage = null;
    });

    if (_monthController.hasClients &&
        _monthController.selectedItem != updatedDate.month - 1) {
      _monthController.jumpToItem(updatedDate.month - 1);
    }
    if (_dayController.hasClients &&
        _dayController.selectedItem != updatedDate.day - 1) {
      _dayController.jumpToItem(updatedDate.day - 1);
    }
    if (_yearController.hasClients &&
        _yearController.selectedItem != updatedDate.year - _firstYear) {
      _yearController.jumpToItem(updatedDate.year - _firstYear);
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await BackendApi.instance.updateDateOfBirth(_selectedDate);
      final user = await SessionStore.restoreUser();
      if (user != null) {
        await SessionStore.saveUser(user.copyWith(dateOfBirth: _selectedDate));
      }
      if (mounted) Navigator.of(context).pop(_selectedDate);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = error.toString();
      });
    }
  }
}
