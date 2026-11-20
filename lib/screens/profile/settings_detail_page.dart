import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/screen_action_buttons.dart';

class SettingsDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Widget? content;

  const SettingsDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = iconColor ?? AppThemeColors.primary(context);

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppThemeColors.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppThemeColors.divider(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundColor: accentColor.withAlpha(24),
                          child: Icon(icon, color: accentColor, size: 21),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            description,
                            style: TextStyle(
                              color: AppThemeColors.textSecondary(context),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (content != null) ...[
                      const SizedBox(height: 14),
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
