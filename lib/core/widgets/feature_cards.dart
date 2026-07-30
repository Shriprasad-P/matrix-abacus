import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../models/announcement.dart';
import '../models/certificate.dart';
import '../models/child_profile.dart';
import '../models/course.dart';
import '../models/enums.dart';
import '../models/worksheet.dart';
import 'common_widgets.dart';

class ChildProfileCard extends StatelessWidget {
  const ChildProfileCard({
    super.key,
    required this.child,
    this.onTap,
    this.onSwitch,
    this.compact = false,
  });

  final ChildProfile child;
  final VoidCallback? onTap;
  final VoidCallback? onSwitch;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              AppAvatar(
                initials: child.initials,
                color: Color(child.avatarColor),
                emoji: child.avatarEmoji,
                size: compact ? AppDimensions.avatarSm : AppDimensions.avatarMd,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${child.className} · ${child.currentLevel}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.streak),
                          const SizedBox(width: 4),
                          Text('${child.streak} day streak', style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onSwitch != null)
                IconButton(
                  tooltip: 'Switch child',
                  onPressed: onSwitch,
                  icon: const Icon(Icons.swap_horiz_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.stat(color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
  });

  final String title;
  final double progress;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              Text('${(progress * 100).round()}%', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: AppColors.surfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.onTap});

  final Course course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(course.color);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(course.title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text('${(course.progress * 100).round()}%'),
                ],
              ),
              const SizedBox(height: 8),
              Text(course.description, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: course.progress,
                  minHeight: 8,
                  color: color,
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: course.levels.map((level) {
                  return StatusChip(
                    label: level.title,
                    color: _levelColor(level.state),
                    icon: _levelIcon(level.state),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _levelColor(LevelState state) {
    switch (state) {
      case LevelState.completed:
        return AppColors.success;
      case LevelState.current:
        return AppColors.primary;
      case LevelState.unlocked:
        return AppColors.warning;
      case LevelState.locked:
        return AppColors.locked;
    }
  }

  IconData _levelIcon(LevelState state) {
    switch (state) {
      case LevelState.completed:
        return Icons.check_circle_rounded;
      case LevelState.current:
        return Icons.play_circle_fill_rounded;
      case LevelState.unlocked:
        return Icons.lock_open_rounded;
      case LevelState.locked:
        return Icons.lock_rounded;
    }
  }
}

class WorksheetCard extends StatelessWidget {
  const WorksheetCard({super.key, required this.worksheet, this.onTap, this.onDownload});

  final Worksheet worksheet;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(worksheet.title, style: Theme.of(context).textTheme.titleMedium)),
                  StatusChip(
                    label: _statusLabel(worksheet.status),
                    color: _statusColor(worksheet.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(worksheet.topic, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${_formatDate(worksheet.dueDate)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('View'),
                  ),
                ],
              ),
              if (worksheet.status == WorksheetStatus.inProgress) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: worksheet.progress, minHeight: 8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(WorksheetStatus status) {
    switch (status) {
      case WorksheetStatus.isNew:
        return 'New';
      case WorksheetStatus.inProgress:
        return 'In progress';
      case WorksheetStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(WorksheetStatus status) {
    switch (status) {
      case WorksheetStatus.isNew:
        return AppColors.primary;
      case WorksheetStatus.inProgress:
        return AppColors.warning;
      case WorksheetStatus.completed:
        return AppColors.success;
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement, this.onTap});

  final Announcement announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: announcement.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: BorderSide(
          color: announcement.isRead ? AppColors.outline : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                announcement.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                color: announcement.isRead ? AppColors.textTertiary : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: announcement.isRead ? FontWeight.w600 : FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!announcement.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  const CertificateCard({super.key, required this.certificate, this.onTap});

  final Certificate certificate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !certificate.earned;
    return Opacity(
      opacity: locked ? 0.7 : 1,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: locked ? AppColors.surfaceMuted : AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.workspace_premium_rounded,
                    color: locked ? AppColors.locked : AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(certificate.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(certificate.description, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      StatusChip(
                        label: locked ? 'Locked' : 'Earned',
                        color: locked ? AppColors.locked : AppColors.success,
                        icon: locked ? Icons.lock_outline : Icons.check_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
