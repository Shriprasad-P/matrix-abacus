import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          PopupMenuButton<UiDemoState>(
            tooltip: 'Demo states',
            onSelected: state.setResultsDemoState,
            itemBuilder: (_) => const [
              PopupMenuItem(value: UiDemoState.normal, child: Text('Normal')),
              PopupMenuItem(value: UiDemoState.loading, child: Text('Loading')),
              PopupMenuItem(value: UiDemoState.empty, child: Text('Empty')),
              PopupMenuItem(value: UiDemoState.error, child: Text('Error')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: _body(context, state),
      ),
    );
  }

  Widget _body(BuildContext context, AppState state) {
    switch (state.resultsDemoState) {
      case UiDemoState.loading:
        return const LoadingSkeleton(lines: 4);
      case UiDemoState.empty:
        return EmptyState(
          title: 'No results yet',
          message: 'Complete a practice session to see scores here.',
          icon: Icons.emoji_events_outlined,
          actionLabel: 'Show sample results',
          onAction: () => state.setResultsDemoState(UiDemoState.normal),
        );
      case UiDemoState.error:
        return ErrorState(
          title: 'Couldn’t load results',
          message: 'Mock error state. Try again to restore the list.',
          onRetry: () => state.setResultsDemoState(UiDemoState.normal),
        );
      case UiDemoState.normal:
        if (state.results.isEmpty) {
          return const EmptyState(
            title: 'No results yet',
            message: 'Completed practice sessions will appear here.',
            icon: Icons.emoji_events_outlined,
          );
        }
        return ListView.separated(
          itemCount: state.results.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => ResultCard(result: state.results[index]),
        );
    }
  }
}
