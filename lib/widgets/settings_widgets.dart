import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showChevron;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppThemeColors.chipBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: ListTile(
        minTileHeight: 56,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppThemeColors.primary(context).withAlpha(28),
          child: Icon(icon, color: AppThemeColors.primary(context)),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppThemeColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: showChevron
            ? Icon(
                Icons.chevron_right_rounded,
                color: AppThemeColors.textSecondary(context),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
