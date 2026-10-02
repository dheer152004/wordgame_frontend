import 'package:flutter/material.dart';

import '../saved_words_screen.dart';
import '../../../services/backend_api.dart';
import '../../../theme/app_theme.dart';

class ProfileSavedWordsSection extends StatefulWidget {
  const ProfileSavedWordsSection({super.key});

  @override
  State<ProfileSavedWordsSection> createState() =>
      _ProfileSavedWordsSectionState();
}

class _ProfileSavedWordsSectionState extends State<ProfileSavedWordsSection> {
  late Future<int> _savedWordCount;

  @override
  void initState() {
    super.initState();
    _savedWordCount = _loadSavedWordCount();
  }

  Future<int> _loadSavedWordCount() async {
    final savedWords = await BackendApi.instance.fetchSavedWords();
    return savedWords.length;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SavedWordsScreen()));
          if (mounted) {
            setState(() => _savedWordCount = _loadSavedWordCount());
          }
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
            future: _savedWordCount,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final count = snapshot.data;
              final countLabel = isLoading
                  ? 'Loading...'
                  : snapshot.hasError
                  ? 'Unable to load saved words'
                  : '$count saved word${count == 1 ? '' : 's'}';

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
                        countLabel,
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
