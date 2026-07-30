import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = AppState.of(context).attendance;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: summary == null
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: LoadingSkeleton(),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Present',
                        value: '${summary.presentCount}',
                        color: AppColors.present,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Absent',
                        value: '${summary.absentCount}',
                        color: AppColors.absent,
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Holiday',
                        value: '${summary.holidayCount}',
                        color: AppColors.holiday,
                        icon: Icons.beach_access_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AttendanceCalendar(summary: summary),
              ],
            ),
    );
  }
}
