import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../models/attendance.dart';
import '../models/enums.dart';
import '../models/practice.dart';

class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key, required this.summary, this.month});

  final AttendanceSummary summary;
  final DateTime? month;

  @override
  Widget build(BuildContext context) {
    final focus = month ?? DateTime.now();
    final first = DateTime(focus.year, focus.month, 1);
    final daysInMonth = DateTime(focus.year, focus.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sunday = 0

    final byDate = {
      for (final d in summary.days)
        if (d.date.year == focus.year && d.date.month == focus.month) d.date.day: d.status,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _monthLabel(focus),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${(summary.percentage * 100).round()}% present',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(d, style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final status = byDate[day] ?? AttendanceStatus.none;
              return _DayCell(day: day, status: status);
            },
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Legend(color: AppColors.present, label: 'Present'),
              _Legend(color: AppColors.absent, label: 'Absent'),
              _Legend(color: AppColors.holiday, label: 'Holiday'),
            ],
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.status});

  final int day;
  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AttendanceStatus.present => AppColors.present,
      AttendanceStatus.absent => AppColors.absent,
      AttendanceStatus.holiday => AppColors.holiday,
      AttendanceStatus.none => AppColors.outline,
    };
    final label = switch (status) {
      AttendanceStatus.present => 'Present',
      AttendanceStatus.absent => 'Absent',
      AttendanceStatus.holiday => 'Holiday',
      AttendanceStatus.none => 'No class',
    };

    return Semantics(
      label: 'Day $day, $label',
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: status == AttendanceStatus.none
              ? AppColors.surfaceMuted
              : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Text(
          '$day',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: status == AttendanceStatus.none ? AppColors.textTertiary : color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key, required this.points});

  final List<WeeklyActivityPoint> points;

  @override
  Widget build(BuildContext context) {
    final max = points.fold<int>(1, (m, p) => p.minutes > m ? p.minutes : m);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Minutes practiced', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((p) {
                final h = (p.minutes / max) * 96;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${p.minutes}', style: Theme.of(context).textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Container(
                          height: h.clamp(8, 96),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(p.label, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
