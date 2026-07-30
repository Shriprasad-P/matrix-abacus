import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final child = state.selectedChild;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const PageHeader(
            title: 'Progress',
            subtitle: 'A clear view of learning without rankings.',
          ),
          if (child == null)
            const EmptyState(title: 'No child selected', message: 'Select a child to view progress.')
          else ...[
            ProgressCard(
              title: 'Overall progress',
              progress: child.overallProgress,
              subtitle: child.currentCourse,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Accuracy',
                    value: '${(child.accuracy * 100).round()}%',
                    icon: Icons.gps_fixed_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Avg speed',
                    value: '${child.avgSpeedSeconds.toStringAsFixed(1)}s',
                    icon: Icons.speed_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatCard(
              label: 'Current streak',
              value: '${child.streak} days',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.streak,
            ),
            const SizedBox(height: 16),
            ProgressChart(points: state.weeklyActivity),
            const SizedBox(height: 16),
            Text('Course progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...state.courses.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProgressCard(title: c.title, progress: c.progress, subtitle: c.description),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
