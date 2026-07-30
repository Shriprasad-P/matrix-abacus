import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/constants/app_constants.dart';
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

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
        onSwitchToPracticeTab: () => setState(() => _index = 1),
      ),
      _PracticeTab(onStart: widget.onOpenPractice),
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
            onDestinationSelected: (i) {
              if (i == 1) {
                // Practice tab shows intro launcher; keep tab selected.
              }
              setState(() => _index = i);
            },
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
  const _PracticeTab({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Practice', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Open child practice mode for the selected profile. No separate child login.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.practiceGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const Icon(Icons.sports_esports_rounded, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(AppConstants.appName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Ready for today’s drill?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onStart,
                    child: const Text('Start practice mode'),
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
