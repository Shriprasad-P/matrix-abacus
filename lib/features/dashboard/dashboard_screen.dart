import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
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

  Future<void> _switchChild(BuildContext context) async {
    final state = AppState.read(context);
    final id = await showChildSwitcherSheet(
      context: context,
      children: state.children,
      selectedId: state.selectedChildId,
      onAddChild: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Use More → Settings to manage profiles, or re-run setup.')),
        );
      },
    );
    if (id != null) await state.selectChild(id);
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
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
              onTap: onOpenChildProfile,
              onSwitch: () => _switchChild(context),
            ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (child != null) ...[
            ProgressCard(
              title: 'Overall progress',
              progress: child.overallProgress,
              subtitle: child.currentCourse,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Attendance',
                    value: state.attendance == null
                        ? '—'
                        : '${(state.attendance!.percentage * 100).round()}%',
                    icon: Icons.event_available_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
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
          const SizedBox(height: 8),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onOpenPractice,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.dailyActivity?.title ?? 'Daily Drill',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                          ),
                          Text(
                            '~${state.dailyActivity?.estimatedMinutes ?? 8} min · Encouraging practice for ${child?.name.split(' ').first ?? 'your child'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _SectionTitle(title: 'Recent worksheets', actionLabel: 'See all', onAction: () {}),
          const SizedBox(height: 8),
          if (state.worksheets.isEmpty)
            const EmptyState(
              title: 'No worksheets yet',
              message: 'Assigned worksheets will appear here.',
              icon: Icons.description_outlined,
            )
          else
            ...state.worksheets.take(2).map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
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
          const SizedBox(height: 8),
          ...state.announcements.take(2).map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnnouncementCard(
                    announcement: a,
                    onTap: () => onOpenAnnouncement(a.id),
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickAction(icon: Icons.insights_rounded, label: 'Progress', onTap: () {}),
              _QuickAction(icon: Icons.event_available_rounded, label: 'Attendance', onTap: onOpenAttendance),
              _QuickAction(icon: Icons.menu_book_rounded, label: 'Courses', onTap: onOpenCourses),
              _QuickAction(icon: Icons.emoji_events_outlined, label: 'Results', onTap: onOpenResults),
              _QuickAction(icon: Icons.workspace_premium_outlined, label: 'Certificates', onTap: onOpenCertificates),
              _QuickAction(icon: Icons.payments_outlined, label: 'Payments', onTap: onOpenPayments),
            ],
          ),
          const SizedBox(height: 24),
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
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(label, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
