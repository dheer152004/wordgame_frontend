import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileAppInfoSection extends StatelessWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onAppVersionTap;
  final VoidCallback? onRateAppTap;
  final VoidCallback? onShareAppTap;

  const ProfileAppInfoSection({
    super.key,
    this.onAboutTap,
    this.onAppVersionTap,
    this.onRateAppTap,
    this.onShareAppTap,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick access to app information and sharing options.',
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _SupportOptionTile(
            title: 'About',
            icon: Icons.info_outline_rounded,
            onTap: onAboutTap,
          ),
          _SupportOptionTile(
            title: 'App Version',
            icon: Icons.rocket_launch_outlined,
            onTap: onAppVersionTap,
          ),
          _SupportOptionTile(
            title: 'Rate App',
            icon: Icons.star_outline_rounded,
            onTap: onRateAppTap,
          ),
          _SupportOptionTile(
            title: 'Share App',
            icon: Icons.share_outlined,
            onTap: onShareAppTap,
          ),
        ],
      ),
    );
  }
}

class _SupportOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _SupportOptionTile({
    required this.title,
    required this.icon,
    this.onTap,
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
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppThemeColors.primary(context).withAlpha(28),
          child: Icon(icon, color: AppThemeColors.primary(context)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppThemeColors.textSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
