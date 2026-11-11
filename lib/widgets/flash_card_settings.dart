import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FlashCardSettings extends StatelessWidget {
  final bool showPreviousCardButton;
  final ValueChanged<bool> onShowPreviousCardButtonChanged;
  final double wordSizeScale;
  final ValueChanged<double> onWordSizeScaleChanged;
  final ValueChanged<double> onWordSizeScaleChangeEnd;
  final double meaningSizeScale;
  final ValueChanged<double> onMeaningSizeScaleChanged;
  final ValueChanged<double> onMeaningSizeScaleChangeEnd;
  final double imageSizeScale;
  final ValueChanged<double> onImageSizeScaleChanged;
  final ValueChanged<double> onImageSizeScaleChangeEnd;

  const FlashCardSettings({
    super.key,
    required this.showPreviousCardButton,
    required this.onShowPreviousCardButtonChanged,
    required this.wordSizeScale,
    required this.onWordSizeScaleChanged,
    required this.onWordSizeScaleChangeEnd,
    required this.meaningSizeScale,
    required this.onMeaningSizeScaleChanged,
    required this.onMeaningSizeScaleChangeEnd,
    required this.imageSizeScale,
    required this.onImageSizeScaleChanged,
    required this.onImageSizeScaleChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flash Card Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the word, meaning, and image sizes for your cards.',
              style: TextStyle(
                fontSize: 14,
                color: AppThemeColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildSizeSlider(
              context,
              title: 'Word size',
              value: wordSizeScale,
              onChanged: onWordSizeScaleChanged,
              onChangeEnd: onWordSizeScaleChangeEnd,
            ),
            _buildSizeSlider(
              context,
              title: 'Meaning size',
              value: meaningSizeScale,
              onChanged: onMeaningSizeScaleChanged,
              onChangeEnd: onMeaningSizeScaleChangeEnd,
            ),
            _buildSizeSlider(
              context,
              title: 'Image size',
              value: imageSizeScale,
              onChanged: onImageSizeScaleChanged,
              onChangeEnd: onImageSizeScaleChangeEnd,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Show previous card button',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
              subtitle: Text(
                'Go back to a card you have already viewed.',
                style: TextStyle(color: AppThemeColors.textSecondary(context)),
              ),
              value: showPreviousCardButton,
              onChanged: onShowPreviousCardButtonChanged,
              activeTrackColor: AppThemeColors.primary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSlider(
    BuildContext context, {
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(color: AppThemeColors.textSecondary(context)),
            ),
          ],
        ),
        Slider(
          min: 0.6,
          max: 1.6,
          divisions: 10,
          value: value,
          label: '${(value * 100).round()}%',
          activeColor: AppThemeColors.primary(context),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
