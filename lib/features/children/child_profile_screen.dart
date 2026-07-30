import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = AppState.of(context).selectedChild;
    if (child == null) {
      return const Scaffold(body: EmptyState(title: 'No child selected', message: 'Add a child profile to continue.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child profile'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile UI — mock only')),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Center(
            child: AppAvatar(
              initials: child.initials,
              color: Color(child.avatarColor),
              emoji: child.avatarEmoji,
              size: 96,
            ),
          ),
          const SizedBox(height: 16),
          Text(child.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            'Age ${child.age} · ${child.className}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ProgressCard(title: 'Current level', progress: child.overallProgress, subtitle: child.currentLevel),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Streak',
                  value: '${child.streak}',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.streak,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Accuracy',
                  value: '${(child.accuracy * 100).round()}%',
                  icon: Icons.gps_fixed_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Badges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: child.badges
                .map((b) => StatusChip(label: b, color: AppColors.secondary, icon: Icons.star_rounded))
                .toList(),
          ),
        ],
      ),
    );
  }
}
