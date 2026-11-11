import 'package:flutter/material.dart';

import '../services/backend_api.dart';
import '../theme/app_theme.dart';

class CategoryRequestSection extends StatefulWidget {
  final String initialCategoryName;

  const CategoryRequestSection({super.key, this.initialCategoryName = ''});

  @override
  State<CategoryRequestSection> createState() => _CategoryRequestSectionState();
}

class _CategoryRequestSectionState extends State<CategoryRequestSection> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categoryNameController.text = widget.initialCategoryName;
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request category to create by team',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suggest a category for our team to add.',
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _categoryNameController,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Category name',
                hintText: 'e.g. Toolbox',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppThemeColors.chipBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a category name.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What kind of words should this category include?',
                filled: true,
                fillColor: AppThemeColors.chipBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a short description.'
                  : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitRequest,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primary(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await BackendApi.instance.requestCategory(
        categoryName: _categoryNameController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      _categoryNameController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category request submitted.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
