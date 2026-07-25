import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileLegalSection extends StatelessWidget {
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onTermsOfUseTap;
  final VoidCallback? onConsentmanagement;

  const ProfileLegalSection({
    super.key,
    this.onPrivacyPolicyTap,
    this.onTermsOfUseTap,
    this.onConsentmanagement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review the policies and terms that apply to your account.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _LegalOptionTile(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: onPrivacyPolicyTap,
          ),
          _LegalOptionTile(
            title: 'Terms of Use',
            icon: Icons.description_outlined,
            onTap: onTermsOfUseTap,
          ),
          _LegalOptionTile(
            title: 'Consent Management',
            icon: Icons.description_outlined,
            onTap: onConsentmanagement,
          ),
        ],
      ),
    );
  }
}

class _LegalOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _LegalOptionTile({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.challengeCard.withAlpha(28),
          child: Icon(icon, color: AppColors.challengeCard),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
