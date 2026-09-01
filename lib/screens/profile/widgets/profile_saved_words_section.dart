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
            color: AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppThemeColors.divider(context)),
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
                      Text(
                        'Saved Words',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLoading
                            ? 'Loading...'
                            : '$count saved word${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: AppThemeColors.textSecondary(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppThemeColors.textSecondary(context),
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
