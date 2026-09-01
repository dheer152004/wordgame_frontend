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
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quiz Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppThemeColors.textPrimary(context),
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
          _buildStatsDisplay(context),
        ],
      ),
    );
  }

  Widget _buildStatsDisplay(BuildContext context) {
    if (stats == null) {
      return Text(
        'No stats available',
        style: TextStyle(color: AppThemeColors.textSecondary(context)),
      );
    }

    if (stats is Map<String, dynamic>) {
      final entries = stats.entries
          .where((entry) => entry.value != null)
          .toList();

      if (entries.isEmpty) {
        return Text(
          'No stats available',
          style: TextStyle(color: AppThemeColors.textSecondary(context)),
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
      style: TextStyle(color: AppThemeColors.textSecondary(context)),
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
