import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileSupportSection extends StatelessWidget {
  final VoidCallback? onFAQTap;
  final VoidCallback? onContactUsTap;
  final VoidCallback? onReportProblemTap;

  const ProfileSupportSection({
    super.key,
    this.onFAQTap,
    this.onContactUsTap,
    this.onReportProblemTap,
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
            'Support',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppThemeColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Need help? Browse common questions or reach out to us directly.',
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _SupportOptionTile(
            title: 'FAQ',
            icon: Icons.quiz_outlined,
            onTap: onFAQTap,
          ),
          _SupportOptionTile(
            title: 'Contact Us',
            icon: Icons.mail_outline_rounded,
            onTap: onContactUsTap,
          ),
          _SupportOptionTile(
            title: 'Report a Problem',
            icon: Icons.report_problem_outlined,
            onTap: onReportProblemTap,
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
