import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = <_QuizPrompt>[
      const _QuizPrompt(
        question: 'What does "GG" mean in gaming?',
        options: ['Good game', 'Game glitch', 'Go go'],
        answerIndex: 0,
      ),
      const _QuizPrompt(
        question: 'What is "ghosting"?',
        options: [
          'Ignoring someone suddenly',
          'Sending gifts',
          'Starting a chat',
        ],
        answerIndex: 0,
      ),
      const _QuizPrompt(
        question: 'Which phrase means to revisit later?',
        options: ['Circle back', 'Buff up', 'No cap'],
        answerIndex: 0,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  const Text('Quiz', style: AppTextStyles.sectionTitle),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Practice slang, workplace jargon, and meme phrases with quick multiple-choice questions.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = questions[index];
                    return _QuizCard(prompt: item, index: index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final _QuizPrompt prompt;
  final int index;

  const _QuizCard({required this.prompt, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $index',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          for (final option in prompt.options) ...[
            _OptionRow(label: option),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.planCardBlue.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Answer: ${prompt.options[prompt.answerIndex]}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;

  const _OptionRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.challengeCard,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizPrompt {
  final String question;
  final List<String> options;
  final int answerIndex;

  const _QuizPrompt({
    required this.question,
    required this.options,
    required this.answerIndex,
  });
}
