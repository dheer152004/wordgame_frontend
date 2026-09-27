import 'package:flutter/material.dart';

import '../../../../services/backend_api.dart';
import '../../../../theme/app_theme.dart';

class DateOfBirthDialog extends StatefulWidget {
  final DateTime? initialDate;
  final bool canSkip;

  const DateOfBirthDialog({super.key, this.initialDate, this.canSkip = true});

  @override
  State<DateOfBirthDialog> createState() => _DateOfBirthDialogState();
}

class _DateOfBirthDialogState extends State<DateOfBirthDialog> {
  DateTime? _selectedDate;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeColors.surface(context),
      title: const Text('Date of birth'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add your date of birth to complete your profile.',
            style: TextStyle(color: AppThemeColors.textSecondary(context)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _selectDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _selectedDate == null
                    ? 'Choose date'
                    : _formatDate(_selectedDate!),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        if (widget.canSkip)
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
        FilledButton(
          onPressed: _isSaving || _selectedDate == null ? null : _save,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected != null && mounted) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _save() async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await BackendApi.instance.updateDateOfBirth(selectedDate);
      if (mounted) Navigator.of(context).pop(selectedDate);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = error.toString();
      });
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
