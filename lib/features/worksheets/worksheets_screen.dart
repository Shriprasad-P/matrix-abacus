import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/worksheet.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class WorksheetsScreen extends StatelessWidget {
  const WorksheetsScreen({super.key, required this.onOpenWorksheet});

  final ValueChanged<String> onOpenWorksheet;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Worksheets',
              subtitle: 'Assigned practice packs for ${state.selectedChild?.name.split(' ').first ?? 'your child'}.',
              action: PopupMenuButton<UiDemoState>(
                tooltip: 'Demo states',
                onSelected: state.setWorksheetsDemoState,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: UiDemoState.normal, child: Text('Normal')),
                  PopupMenuItem(value: UiDemoState.loading, child: Text('Loading')),
                  PopupMenuItem(value: UiDemoState.empty, child: Text('Empty')),
                  PopupMenuItem(value: UiDemoState.error, child: Text('Error')),
                ],
                child: const Icon(Icons.more_vert_rounded),
              ),
            ),
            Expanded(child: _body(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppState state) {
    switch (state.worksheetsDemoState) {
      case UiDemoState.loading:
        return const LoadingSkeleton(lines: 5);
      case UiDemoState.empty:
        return EmptyState(
          title: 'No worksheets',
          message: 'When teachers assign worksheets, they will show up here.',
          actionLabel: 'Refresh',
          onAction: () => state.setWorksheetsDemoState(UiDemoState.normal),
        );
      case UiDemoState.error:
        return ErrorState(
          title: 'Couldn’t load worksheets',
          message: 'Something went wrong in this mock error state.',
          onRetry: () => state.setWorksheetsDemoState(UiDemoState.normal),
        );
      case UiDemoState.normal:
        if (state.worksheets.isEmpty) {
          return const EmptyState(
            title: 'No worksheets',
            message: 'Nothing assigned right now.',
          );
        }
        return ListView.separated(
          itemCount: state.worksheets.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final w = state.worksheets[index];
            return WorksheetCard(
              worksheet: w,
              onTap: () => onOpenWorksheet(w.id),
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mock download: ${w.title}')),
                );
              },
            );
          },
        );
    }
  }
}

class WorksheetDetailsScreen extends StatelessWidget {
  const WorksheetDetailsScreen({super.key, required this.worksheetId});

  final String worksheetId;

  @override
  Widget build(BuildContext context) {
    final worksheets = AppState.of(context).worksheets;
    Worksheet? worksheet;
    for (final w in worksheets) {
      if (w.id == worksheetId) {
        worksheet = w;
        break;
      }
    }
    worksheet ??= worksheets.isNotEmpty ? worksheets.first : null;

    if (worksheet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(title: 'Worksheet not found', message: 'It may have been removed.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Worksheet')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(worksheet.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          StatusChip(label: worksheet.topic, icon: Icons.topic_outlined),
          const SizedBox(height: 16),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(worksheet.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(worksheet.instructions, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ProgressCard(
            title: 'Completion',
            progress: worksheet.progress,
            subtitle: 'Due ${worksheet.dueDate.day}/${worksheet.dueDate.month}/${worksheet.dueDate.year}',
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'View / download',
            icon: Icons.download_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mock file opened')),
              );
            },
          ),
        ],
      ),
    );
  }
}
