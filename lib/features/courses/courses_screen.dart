import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = AppState.of(context).courses;

    return Scaffold(
      appBar: AppBar(title: const Text('Courses & levels')),
      body: courses.isEmpty
          ? const EmptyState(
              title: 'No courses yet',
              message: 'Courses will appear once a child is enrolled.',
              icon: Icons.menu_book_outlined,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text(
                  'Current levels are highlighted. Locked levels stay visible so progress feels clear.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...courses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseCard(course: course),
                        const SizedBox(height: 10),
                        ...course.levels.map((level) {
                          final isCurrent = level.state == LevelState.current;
                          final locked = level.state == LevelState.locked;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : AppColors.outline,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  locked
                                      ? Icons.lock_rounded
                                      : level.state == LevelState.completed
                                          ? Icons.check_circle_rounded
                                          : Icons.play_circle_outline_rounded,
                                  color: locked
                                      ? AppColors.locked
                                      : isCurrent
                                          ? AppColors.primary
                                          : AppColors.success,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(level.title, style: Theme.of(context).textTheme.titleSmall),
                                      if (level.state == LevelState.current ||
                                          level.state == LevelState.completed)
                                        Text(
                                          '${(level.progress * 100).round()}% complete',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                                StatusChip(
                                  label: level.state.name,
                                  color: locked ? AppColors.locked : AppColors.primary,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
