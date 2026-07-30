import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../models/child_profile.dart';
import 'common_widgets.dart';

Future<String?> showChildSwitcherSheet({
  required BuildContext context,
  required List<ChildProfile> children,
  required String? selectedId,
  VoidCallback? onAddChild,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            0,
            AppSpacing.screenPadding,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Switch child', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Practice and progress follow the selected profile.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...children.map((child) {
                final selected = child.id == selectedId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.outline,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      onTap: () => Navigator.pop(context, child.id),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            AppAvatar(
                              initials: child.initials,
                              color: Color(child.avatarColor),
                              emoji: child.avatarEmoji,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(child.name, style: Theme.of(context).textTheme.titleMedium),
                                  Text(
                                    '${child.className} · ${child.currentCourse}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onAddChild?.call();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add child'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
