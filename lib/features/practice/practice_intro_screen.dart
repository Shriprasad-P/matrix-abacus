import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class PracticeIntroScreen extends StatelessWidget {
  const PracticeIntroScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final activity = state.dailyActivity;
    final child = state.selectedChild;

    if (activity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final difficulty = switch (activity.difficulty) {
      PracticeDifficulty.easy => 'Easy',
      PracticeDifficulty.medium => 'Medium',
      PracticeDifficulty.challenge => 'Challenge',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Practice mode')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.practiceGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    Text(
                      child == null ? 'Ready?' : 'Let’s go, ${child.name.split(' ').first}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(activity.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(activity.description, textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatChip(label: '~${activity.estimatedMinutes} min', icon: Icons.timer_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatChip(label: difficulty, icon: Icons.trending_up_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatChip(label: '${activity.questions.length} Qs', icon: Icons.quiz_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                activity.encouragement,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Start',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  state.startPractice(activity);
                  onStart();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
