import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../services/backend_api.dart';
import '../../../../theme/app_theme.dart';

class ProfileReportDialog extends StatefulWidget {
  const ProfileReportDialog({super.key});

  @override
  State<ProfileReportDialog> createState() => _ProfileReportDialogState();
}

class _ProfileReportDialogState extends State<ProfileReportDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  List<PlatformFile> _screenshotFiles = [];
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_isSubmitting && _descriptionController.text.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: AppThemeColors.surface(context),
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
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickScreenshots,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Attach screenshots'),
                ),
              ),
              if (_screenshotFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._screenshotFiles.map(
                  (file) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.image_outlined),
                    title: Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Screenshots are optional. You can attach multiple image files.',
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12,
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
      await BackendApi.instance.submitReport(
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
        screenshotFiles: _screenshotFiles,
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

  Future<void> _pickScreenshots() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: kIsWeb,
    );
    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _screenshotFiles = result.files;
    });
  }
}
