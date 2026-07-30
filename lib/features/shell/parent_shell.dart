import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../dashboard/dashboard_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/more_screen.dart';
import '../worksheets/worksheets_screen.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({
    super.key,
    required this.onOpenPractice,
    required this.onOpenAttendance,
    required this.onOpenCourses,
    required this.onOpenResults,
    required this.onOpenCertificates,
    required this.onOpenAnnouncements,
    required this.onOpenPayments,
    required this.onOpenSettings,
    required this.onOpenChildProfile,
    required this.onOpenWorksheet,
    required this.onOpenAnnouncement,
    this.onAddChild,
  });

  final VoidCallback onOpenPractice;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenCourses;
  final VoidCallback onOpenResults;
  final VoidCallback onOpenCertificates;
  final VoidCallback onOpenAnnouncements;
  final VoidCallback onOpenPayments;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenChildProfile;
  final ValueChanged<String> onOpenWorksheet;
  final ValueChanged<String> onOpenAnnouncement;
  final VoidCallback? onAddChild;

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final childName = AppState.of(context).selectedChild?.name.split(' ').first;

    final pages = [
      DashboardScreen(
        onOpenPractice: widget.onOpenPractice,
        onOpenAttendance: widget.onOpenAttendance,
        onOpenCourses: widget.onOpenCourses,
        onOpenResults: widget.onOpenResults,
        onOpenCertificates: widget.onOpenCertificates,
        onOpenAnnouncements: widget.onOpenAnnouncements,
        onOpenPayments: widget.onOpenPayments,
        onOpenChildProfile: widget.onOpenChildProfile,
        onOpenWorksheet: widget.onOpenWorksheet,
        onOpenAnnouncement: widget.onOpenAnnouncement,
        onSwitchToPracticeTab: () => _goToTab(1),
        onSwitchToProgressTab: () => _goToTab(2),
        onSwitchToWorksheetsTab: () => _goToTab(3),
        onAddChild: widget.onAddChild,
      ),
      _PracticeTab(
        childName: childName,
        onStart: widget.onOpenPractice,
      ),
      const ProgressScreen(),
      WorksheetsScreen(onOpenWorksheet: widget.onOpenWorksheet),
      MoreScreen(
        onOpenSettings: widget.onOpenSettings,
        onOpenPayments: widget.onOpenPayments,
        onOpenCertificates: widget.onOpenCertificates,
        onOpenAnnouncements: widget.onOpenAnnouncements,
        onOpenResults: widget.onOpenResults,
        onOpenAttendance: widget.onOpenAttendance,
        onOpenCourses: widget.onOpenCourses,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: NavigationBar(
            height: AppDimensions.bottomNavHeight,
            selectedIndex: _index,
            onDestinationSelected: _goToTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline),
                selectedIcon: Icon(Icons.play_circle_filled_rounded),
                label: 'Practice',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description_rounded),
                label: 'Worksheets',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz_rounded),
                selectedIcon: Icon(Icons.more_horiz_rounded),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeTab extends StatelessWidget {
  const _PracticeTab({required this.onStart, this.childName});

  final VoidCallback onStart;
  final String? childName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Practice', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              childName == null
                  ? 'Open focused practice for the selected child. No separate child login.'
                  : 'Practice for $childName — a focused full-screen activity without parent navigation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.practiceGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sports_esports_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(AppConstants.appName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ready for today’s drill?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'Start practice mode',
                    icon: Icons.play_arrow_rounded,
                    onPressed: onStart,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
