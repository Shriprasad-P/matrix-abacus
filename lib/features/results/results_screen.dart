import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = AppState.of(context).results;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: results.isEmpty
          ? const EmptyState(
              title: 'No results yet',
              message: 'Completed practice sessions will appear here.',
              icon: Icons.emoji_events_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = results[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(r.title, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Text(
                            '${r.date.day}/${r.date.month}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r.topic, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Score',
                              value: '${r.score}/${r.total}',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              label: 'Accuracy',
                              value: '${(r.accuracy * 100).round()}%',
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              label: 'Speed',
                              value: '${r.avgSpeedSeconds.toStringAsFixed(1)}s',
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      if (r.teacherFeedback != null) ...[
                        const SizedBox(height: 12),
                        Text('Teacher feedback', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(r.teacherFeedback!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < r.stars ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ResultHighlight extends StatelessWidget {
  const ResultHighlight({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.stat()),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
