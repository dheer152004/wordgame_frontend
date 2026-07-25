import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class ProfileStatsSection extends StatelessWidget {
  final dynamic stats;
  final VoidCallback onRefresh;

  const ProfileStatsSection({
    super.key,
    required this.stats,
    required this.onRefresh,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quiz Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh stats',
                iconSize: 20,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStatsDisplay(),
        ],
      ),
    );
  }

  Widget _buildStatsDisplay() {
    if (stats == null) {
      return const Text(
        'No stats available',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    if (stats is Map<String, dynamic>) {
      final entries = stats.entries
          .where((entry) => entry.value != null)
          .toList();

      if (entries.isEmpty) {
        return const Text(
          'No stats available',
          style: TextStyle(color: AppColors.textSecondary),
        );
      }

      return Column(
        children: [
          for (final entry in entries) ...[
            _StatRow(label: entry.key, value: entry.value.toString()),
            const SizedBox(height: 8),
          ],
        ],
      );
    }

    return Text(
      stats.toString(),
      style: const TextStyle(color: AppColors.textSecondary),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
