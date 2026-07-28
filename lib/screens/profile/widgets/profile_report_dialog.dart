import 'package:flutter/material.dart';

import '../../../../services/backend_api.dart';
import '../../../../theme/app_theme.dart';

class ProfileReportDialog extends StatefulWidget {
  const ProfileReportDialog({super.key});

  @override
  State<ProfileReportDialog> createState() => _ProfileReportDialogState();
}

class _ProfileReportDialogState extends State<ProfileReportDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _screenshotUrlsController =
      TextEditingController();
  String _selectedReason = 'APP_IS_CRASHING';
  bool _isSubmitting = false;
  String? _errorMessage;

  static const List<String> _reasons = [
    'APP_IS_CRASHING',
    'NOT_LOADING_WORDS',
    'QUIZ_ISSUE',
    'WRONG_INFO',
    'NSFW',
    'OTHER',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _screenshotUrlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_isSubmitting && _descriptionController.text.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Report a problem'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedReason,
                items: _reasons
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(
                          reason
                              .replaceAll('_', ' ')
                              .toLowerCase()
                              .split(' ')
                              .map(
                                (word) => word.isEmpty
                                    ? word
                                    : '${word[0].toUpperCase()}${word.substring(1)}',
                              )
                              .join(' '),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedReason = value;
                          });
                        }
                      },
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                minLines: 3,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue and where it occurs',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _screenshotUrlsController,
                enabled: !_isSubmitting,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Screenshot URLs',
                  hintText: 'One URL per line or comma separated',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Screenshots are optional. Paste direct image URLs separated by new lines or commas.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canSubmit ? _submitReport : null,
          child: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final screenshotUrls = _parseScreenshotUrls(
        _screenshotUrlsController.text,
      );
      await BackendApi.instance.submitReport(
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
        screenshotUrls: screenshotUrls.isEmpty ? null : screenshotUrls,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem report submitted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString();
      });
    }
  }

  List<String> _parseScreenshotUrls(String rawText) {
    final separators = RegExp(r'[\n,;]+');
    return rawText
        .split(separators)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}
