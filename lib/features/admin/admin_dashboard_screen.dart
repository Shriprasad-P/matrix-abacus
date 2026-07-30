import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/feature_cards.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final admin = AppState.of(context).parent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text(
              'Welcome, ${admin?.name ?? 'Admin'}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Manage learning operations, students, and centre communication.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                gradient: AppColors.splashGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.space_dashboard_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Today’s centre overview',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    label: 'Active students',
                    value: '42',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Parents',
                    value: '28',
                    icon: Icons.family_restroom_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    label: 'Courses',
                    value: '6',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Pending work',
                    value: '14',
                    icon: Icons.assignment_late_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text(
              'Admin actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _actionTile(
              context,
              icon: Icons.school_rounded,
              title: 'Manage courses and levels',
              subtitle: 'Create courses and organise the learning path.',
            ),
            _actionTile(
              context,
              icon: Icons.assignment_rounded,
              title: 'Assign worksheets',
              subtitle: 'Send practice work to a student profile.',
            ),
            _actionTile(
              context,
              icon: Icons.campaign_rounded,
              title: 'Publish announcements',
              subtitle: 'Share updates with parents and families.',
            ),
            _actionTile(
              context,
              icon: Icons.extension_rounded,
              title: 'Manage practice activities',
              subtitle: 'Create question sets for daily practice.',
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ActivityRow(
              icon: Icons.person_add_alt_1_rounded,
              title: 'New parent account registered',
              time: 'Today · 10:24 AM',
            ),
            const _ActivityRow(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Worksheets completed by 8 students',
              time: 'Today · 9:15 AM',
            ),
            const _ActivityRow(
              icon: Icons.emoji_events_outlined,
              title: 'Three certificates ready to review',
              time: 'Yesterday',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '${AppConstants.appName} · Admin workspace',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is ready for API connection.')),
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(time),
    );
  }
}
