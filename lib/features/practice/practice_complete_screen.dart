import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';
import '../../../core/widgets/practice_widgets.dart';

class PracticeCompleteScreen extends StatelessWidget {
  const PracticeCompleteScreen({
    super.key,
    required this.onPracticeAgain,
    required this.onReturnHome,
  });

  final VoidCallback onPracticeAgain;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final result = state.lastPracticeResult;
    final child = state.selectedChild;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: AppPrimaryButton(label: 'Back', onPressed: onReturnHome, expand: false),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SuccessStateView(
                title: 'Great work!',
                message: 'You finished today’s practice. Consistency builds confidence.',
              ),
              const SizedBox(height: 24),
              Text('${result.score}/${result.total}', style: AppTypography.score(color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < result.stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Accuracy',
                      value: '${(result.accuracy * 100).round()}%',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Speed',
                      value: '${result.avgSpeedSeconds.toStringAsFixed(1)}s',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (child != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.streak),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Streak updated to ${child.streak} days',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Practice again',
                onPressed: () {
                  final activity = state.dailyActivity;
                  if (activity != null) state.startPractice(activity);
                  onPracticeAgain();
                },
              ),
              const SizedBox(height: 10),
              AppSecondaryButton(
                label: 'Return to dashboard',
                onPressed: () {
                  state.endPractice();
                  onReturnHome();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
