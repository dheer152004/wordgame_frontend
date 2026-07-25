import 'package:flutter/material.dart';

import '../saved_words_screen.dart';
import '../../../services/backend_api.dart';
import '../../../theme/app_theme.dart';

class ProfileSavedWordsSection extends StatelessWidget {
  const ProfileSavedWordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SavedWordsScreen()));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: FutureBuilder<int>(
            future: BackendApi.instance.fetchSavedWordsCount(),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final count = snapshot.hasData ? snapshot.data! : 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved Words',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLoading
                            ? 'Loading...'
                            : '$count saved word${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
