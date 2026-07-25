import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileAvatarOption extends StatelessWidget {
  final String url;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const ProfileAvatarOption({
    super.key,
    required this.url,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.challengeCard
                  : Colors.white.withAlpha(20),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.network(
                  url,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 42,
                    height: 42,
                    color: AppColors.challengeCard,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
