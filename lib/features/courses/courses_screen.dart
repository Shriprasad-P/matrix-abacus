import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
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
                const SizedBox(height: AppSpacing.lg),
                ...courses.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseCard(course: course),
                        const SizedBox(height: AppSpacing.sm),
                        ...course.levels.map((level) {
                          final isCurrent = level.state == LevelState.current;
                          final locked = level.state == LevelState.locked;
                          final completed = level.state == LevelState.completed;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Material(
                              color: isCurrent
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                side: BorderSide(
                                  color: isCurrent ? AppColors.primary : AppColors.outline,
                                  width: isCurrent ? 1.5 : 1,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                onTap: () {
                                  final message = locked
                                      ? 'Complete earlier levels to unlock ${level.title}.'
                                      : isCurrent
                                          ? '${level.title} is the current level.'
                                          : completed
                                              ? '${level.title} is completed.'
                                              : '${level.title} is unlocked and ready.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      Icon(
                                        locked
                                            ? Icons.lock_rounded
                                            : completed
                                                ? Icons.check_circle_rounded
                                                : Icons.play_circle_outline_rounded,
                                        color: locked
                                            ? AppColors.locked
                                            : isCurrent
                                                ? AppColors.primary
                                                : AppColors.success,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(level.title, style: Theme.of(context).textTheme.titleSmall),
                                            if (!locked)
                                              Text(
                                                '${(level.progress * 100).round()}% complete',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                          ],
                                        ),
                                      ),
                                      StatusChip(
                                        label: levelStateLabel(level.state),
                                        color: locked
                                            ? AppColors.locked
                                            : isCurrent
                                                ? AppColors.primary
                                                : completed
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                        icon: locked
                                            ? Icons.lock_outline
                                            : completed
                                                ? Icons.check_rounded
                                                : isCurrent
                                                    ? Icons.play_arrow_rounded
                                                    : Icons.lock_open_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
