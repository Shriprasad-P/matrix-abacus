import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/child_switcher.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenPractice,
    required this.onOpenAttendance,
    required this.onOpenCourses,
    required this.onOpenResults,
    required this.onOpenCertificates,
    required this.onOpenAnnouncements,
    required this.onOpenPayments,
    required this.onOpenChildProfile,
    required this.onOpenWorksheet,
    required this.onOpenAnnouncement,
    required this.onSwitchToPracticeTab,
    required this.onSwitchToProgressTab,
    required this.onSwitchToWorksheetsTab,
    this.onAddChild,
  });

  final VoidCallback onOpenPractice;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenCourses;
  final VoidCallback onOpenResults;
  final VoidCallback onOpenCertificates;
  final VoidCallback onOpenAnnouncements;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenChildProfile;
  final ValueChanged<String> onOpenWorksheet;
  final ValueChanged<String> onOpenAnnouncement;
  final VoidCallback onSwitchToPracticeTab;
  final VoidCallback onSwitchToProgressTab;
  final VoidCallback onSwitchToWorksheetsTab;
  final VoidCallback? onAddChild;

  Future<void> _switchChild(BuildContext context) async {
    final state = AppState.read(context);
    final id = await showChildSwitcherSheet(
      context: context,
      children: state.children,
      selectedId: state.selectedChildId,
      onAddChild: onAddChild,
    );
    if (id != null) {
      await state.selectChild(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${state.selectedChild?.name ?? 'child'}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final parent = state.parent;
    final child = state.selectedChild;
    final unread = state.unreadAnnouncements;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(), style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      parent?.name.split(' ').first ?? 'Parent',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Announcements',
                onPressed: onOpenAnnouncements,
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (child != null)
            ChildProfileCard(
              child: child,
              selected: true,
              onTap: onOpenChildProfile,
              onSwitch: () => _switchChild(context),
            )
          else
            EmptyState(
              title: 'No child selected',
              message: 'Add a child profile to see progress and practice.',
              actionLabel: 'Add child',
              onAction: onAddChild,
            ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (child != null) ...[
            InkWell(
              onTap: onSwitchToProgressTab,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: ProgressCard(
                title: 'Overall progress',
                progress: child.overallProgress,
                subtitle: child.currentCourse,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onOpenAttendance,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: StatCard(
                      label: 'Attendance',
                      value: state.attendance == null
                          ? '—'
                          : '${(state.attendance!.percentage * 100).round()}%',
                      icon: Icons.event_available_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    label: 'Streak',
                    value: '${child.streak}d',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.streak,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          _SectionTitle(title: 'Daily practice', actionLabel: 'Open', onAction: onSwitchToPracticeTab),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Start daily practice',
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: InkWell(
                onTap: onOpenPractice,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_circle_filled_rounded,
                        color: AppColors.textOnPrimary,
                        size: 40,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.dailyActivity?.title ?? 'Daily Drill',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textOnPrimary,
                                  ),
                            ),
                            Text(
                              '~${state.dailyActivity?.estimatedMinutes ?? 8} min · for ${child?.name.split(' ').first ?? 'your child'}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textOnPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _SectionTitle(
            title: 'Recent worksheets',
            actionLabel: 'See all',
            onAction: onSwitchToWorksheetsTab,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.worksheets.isEmpty)
            const EmptyState(
              title: 'No worksheets yet',
              message: 'Assigned worksheets will appear here.',
              icon: Icons.description_outlined,
            )
          else
            ...state.worksheets.take(2).map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: WorksheetCard(
                      worksheet: w,
                      onTap: () => onOpenWorksheet(w.id),
                      onDownload: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening ${w.title} (mock)')),
                        );
                      },
                    ),
                  ),
                ),
          const SizedBox(height: AppSpacing.md),
          _SectionTitle(
            title: 'Announcements',
            actionLabel: 'View',
            onAction: onOpenAnnouncements,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.announcements.isEmpty)
            const EmptyState(
              title: 'No announcements',
              message: 'Centre updates will show up here.',
              icon: Icons.notifications_none_rounded,
            )
          else
            ...state.announcements.take(2).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AnnouncementCard(
                      announcement: a,
                      onTap: () => onOpenAnnouncement(a.id),
                    ),
                  ),
                ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickAction(icon: Icons.insights_rounded, label: 'Progress', onTap: onSwitchToProgressTab),
              _QuickAction(icon: Icons.event_available_rounded, label: 'Attendance', onTap: onOpenAttendance),
              _QuickAction(icon: Icons.menu_book_rounded, label: 'Courses', onTap: onOpenCourses),
              _QuickAction(icon: Icons.emoji_events_outlined, label: 'Results', onTap: onOpenResults),
              _QuickAction(icon: Icons.workspace_premium_outlined, label: 'Certificates', onTap: onOpenCertificates),
              _QuickAction(icon: Icons.payments_outlined, label: 'Payments', onTap: onOpenPayments),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 3,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppDimensions.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
