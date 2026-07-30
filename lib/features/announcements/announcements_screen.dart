import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key, required this.onOpenAnnouncement});

  final ValueChanged<String> onOpenAnnouncement;

  @override
  Widget build(BuildContext context) {
    final announcements = AppState.of(context).announcements;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: announcements.isEmpty
          ? const EmptyState(
              title: 'No announcements',
              message: 'Centre updates will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: announcements.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = announcements[index];
                return AnnouncementCard(
                  announcement: a,
                  onTap: () => onOpenAnnouncement(a.id),
                );
              },
            ),
    );
  }
}

class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final list = state.announcements;
    final a = list.firstWhere((x) => x.id == announcementId, orElse: () => list.first);

    // Mark read after first frame to avoid notify during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      AppState.read(context).markAnnouncementRead(a.id);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(a.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            '${a.date.day}/${a.date.month}/${a.date.year} · ${a.priority.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          Text(a.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
