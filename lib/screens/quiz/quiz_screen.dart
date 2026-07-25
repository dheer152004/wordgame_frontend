import 'package:flutter/material.dart';

import '../../models/quiz_models.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_action_buttons.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _selectedOptions = {};
  final Map<int, DateTime> _questionLoadedAt = {};

  List<QuizQuestion> _questions = [];
  dynamic _todayAvailable;
  dynamic _status;
  dynamic _stats;
  dynamic _history;
  QuizSubmissionResult? _result;
  bool _alreadyCompletedToday = false;

  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _alreadyCompletedToday = false;
    });

    try {
      final responses = await Future.wait<dynamic>([
        BackendApi.instance.fetchQuizToday(),
        BackendApi.instance.fetchQuizTodayAvailability(),
        BackendApi.instance.fetchQuizStatus(),
        BackendApi.instance.fetchQuizStats(),
        BackendApi.instance.fetchQuizHistory(),
      ]);

      if (!mounted) {
        return;
      }

      final questions = responses[0] as List<QuizQuestion>;
      setState(() {
        _questions = questions;
        _todayAvailable = responses[1];
        _status = responses[2];
        _stats = responses[3];
        _history = responses[4];
        _loading = false;
        _result = null;
        _selectedOptions.clear();
        _questionLoadedAt
          ..clear()
          ..addEntries(
            questions.map((question) {
              return MapEntry(question.questionId, DateTime.now());
            }),
          );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final errorString = error.toString();

      // Check if error is "already completed today's quiz"
      if (errorString.contains('already completed today')) {
        setState(() {
          _loading = false;
          _alreadyCompletedToday = true;
          _errorMessage = null;
        });

        // Load stats for display
        try {
          final stats = await BackendApi.instance.fetchQuizStats();
          if (mounted) {
            setState(() {
              _stats = stats;
            });
          }
        } catch (_) {
          // Ignore stats loading errors
        }
      } else {
        setState(() {
          _loading = false;
          _alreadyCompletedToday = false;
          _errorMessage = errorString;
        });
      }
    }
  }

  void _selectOption(int questionId, String option) {
    setState(() {
      _selectedOptions[questionId] = option;
    });
  }

  Future<void> _submitQuiz() async {
    final unanswered = _questions
        .where((question) => _selectedOptions[question.questionId] == null)
        .toList();
    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Answer all ${_questions.length} questions before submitting.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final answers = _questions.map((question) {
        final startedAt =
            _questionLoadedAt[question.questionId] ?? DateTime.now();
        return QuizAnswerSubmission(
          questionId: question.questionId,
          selectedOption: _selectedOptions[question.questionId]!,
          timeTakenMs: DateTime.now().difference(startedAt).inMilliseconds,
        );
      }).toList();

      final result = await BackendApi.instance.submitQuizAnswers(answers);
      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _submitting = false;
      });

      await _refreshQuizMetadata();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _refreshQuizMetadata() async {
    try {
      final responses = await Future.wait<dynamic>([
        BackendApi.instance.fetchQuizTodayAvailability(),
        BackendApi.instance.fetchQuizStatus(),
        BackendApi.instance.fetchQuizStats(),
        BackendApi.instance.fetchQuizHistory(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _todayAvailable = responses[0];
        _status = responses[1];
        _stats = responses[2];
        _history = responses[3];
      });
    } catch (_) {
      // Keep the completed quiz result visible even if metadata refresh fails.
    }
  }

  String _describe(dynamic value) {
    if (value == null) {
      return 'No data';
    }

    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    if (value is num || value is String) {
      return value.toString();
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'Empty';
      }

      return '${value.length} item${value.length == 1 ? '' : 's'}';
    }

    if (value is Map) {
      final entries = value.entries
          .where((entry) => entry.value != null)
          .take(3)
          .map((entry) => '${entry.key}: ${_describe(entry.value)}')
          .toList();

      if (entries.isEmpty) {
        return 'Empty';
      }

      return entries.join(' · ');
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _bootstrap,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text('Quiz', style: AppTextStyles.sectionTitle),
                    ),
                    AppRefreshIconButton(
                      onPressed: _loading ? null : _bootstrap,
                      tooltip: 'Refresh quiz',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Take today\'s quiz, submit your answers, and review your score, XP, and history from the backend.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 72),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_alreadyCompletedToday) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2AB67A),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quiz Completed',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'You have already completed today\'s quiz!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'Today\'s stats',
                    subtitle: 'Your performance summary.',
                  ),
                  const SizedBox(height: 12),
                  _InfoGrid(
                    items: [
                      _InfoTile(
                        title: 'Stats',
                        value: _describe(_stats),
                        icon: Icons.bar_chart_rounded,
                      ),
                      _InfoTile(
                        title: 'Status',
                        value: _describe(_status),
                        icon: Icons.insights_rounded,
                      ),
                      _InfoTile(
                        title: 'History',
                        value: _describe(_history),
                        icon: Icons.history_rounded,
                      ),
                    ],
                  ),
                ] else if (_errorMessage != null && _questions.isEmpty)
                  _InlineError(message: _errorMessage!, onRetry: _bootstrap)
                else ...[
                  if (_result != null) ...[
                    _ResultCard(result: _result!),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(
                    title: 'Quiz overview',
                    subtitle:
                        'Availability, status, stats, and history at a glance.',
                  ),
                  const SizedBox(height: 12),
                  _InfoGrid(
                    items: [
                      _InfoTile(
                        title: 'Available today',
                        value: _describe(_todayAvailable),
                        icon: Icons.event_available_rounded,
                      ),
                      _InfoTile(
                        title: 'Current status',
                        value: _describe(_status),
                        icon: Icons.insights_rounded,
                      ),
                      _InfoTile(
                        title: 'Stats',
                        value: _describe(_stats),
                        icon: Icons.bar_chart_rounded,
                      ),
                      _InfoTile(
                        title: 'History',
                        value: _describe(_history),
                        icon: Icons.history_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Today\'s questions',
                    subtitle: _questions.isEmpty
                        ? 'No questions were returned for today.'
                        : 'Select one option per question and submit when ready.',
                  ),
                  const SizedBox(height: 12),
                  if (_questions.isEmpty)
                    const _EmptyState(
                      title: 'No quiz available',
                      message:
                          'The today endpoint returned no questions. Pull to refresh later.',
                    )
                  else
                    Column(
                      children: [
                        for (final entry in _questions.asMap().entries) ...[
                          _QuizCard(
                            prompt: entry.value,
                            index: entry.key + 1,
                            selectedOption:
                                _selectedOptions[entry.value.questionId],
                            onSelect: (option) =>
                                _selectOption(entry.value.questionId, option),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submitQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    _result == null
                                        ? 'Submit quiz'
                                        : 'Submit again',
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_selectedOptions.length}/${_questions.length} answered',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          _InlineError(message: _errorMessage!),
                        ],
                      ],
                    ),
                  if (_result != null && _result!.details.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SectionTitle(
                      title: 'Answer review',
                      subtitle:
                          'See which questions matched the expected answer.',
                    ),
                    const SizedBox(height: 12),
                    for (final detail in _result!.details) ...[
                      _DetailCard(detail: detail),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizQuestion prompt;
  final int index;
  final String? selectedOption;
  final ValueChanged<String> onSelect;

  const _QuizCard({
    required this.prompt,
    required this.index,
    required this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Question $index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.planCardBlue.withAlpha(36),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${prompt.points} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt.word,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the best answer for this word.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (final entry in prompt.options.asMap().entries) ...[
            _OptionRow(
              letter: String.fromCharCode(65 + entry.key),
              label: entry.value,
              selected: selectedOption == String.fromCharCode(65 + entry.key),
              onTap: () => onSelect(String.fromCharCode(65 + entry.key)),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withAlpha(14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? Colors.black : AppColors.challengeCard,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.black : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: Colors.black, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final QuizSubmissionResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submission result',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.score}/${result.totalPossible} correct',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result.message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(label: 'Score', value: '${result.percentage}%'),
              _MetricChip(label: 'XP earned', value: '${result.xpEarned}'),
              _MetricChip(label: 'Total XP', value: '${result.newTotalXp}'),
              _MetricChip(label: 'Level', value: '${result.newLevel}'),
              _MetricChip(label: 'Streak', value: '${result.currentStreak}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.planCardBlue.withAlpha(36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final QuizSubmissionDetail detail;

  const _DetailCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final highlightColor = detail.isCorrect
        ? const Color(0xFF2FBF71)
        : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: highlightColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  detail.isCorrect ? 'Correct' : 'Incorrect',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlightColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your answer: ${detail.yourAnswer}',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Correct answer: ${detail.correctAnswer}',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Points earned: ${detail.pointsEarned}',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          if (detail.explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              detail.explanation,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoTile> items;

  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map((tile) => SizedBox(width: tileWidth, child: tile))
              .toList(),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x33FF6B6B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x66FF6B6B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unable to load quiz data.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
