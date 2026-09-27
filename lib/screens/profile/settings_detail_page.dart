import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/screen_action_buttons.dart';

class SettingsDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? content;

  const SettingsDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppBackIconButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppThemeColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppThemeColors.divider(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppThemeColors.primary(
                        context,
                      ).withAlpha(28),
                      child: Icon(
                        icon,
                        color: AppThemeColors.primary(context),
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (content != null) ...[
                      const SizedBox(height: 20),
                      content!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
