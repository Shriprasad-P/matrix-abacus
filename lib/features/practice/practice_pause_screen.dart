import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class PracticePauseScreen extends StatelessWidget {
  const PracticePauseScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('Paused', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Take a breath. Your progress is waiting right here.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  AppState.read(context).resumePractice();
                  onResume();
                },
              ),
              const SizedBox(height: 10),
              AppPrimaryButton(
                label: 'Restart',
                icon: Icons.refresh_rounded,
                onPressed: () async {
                  final ok = await showAppConfirmDialog(
                    context: context,
                    title: 'Restart activity?',
                    message: 'This clears answers from the current session.',
                    confirmLabel: 'Restart',
                  );
                  if (!context.mounted) return;
                  if (ok) {
                    AppState.read(context).restartPractice();
                    onRestart();
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final ok = await showAppConfirmDialog(
                    context: context,
                    title: 'Exit activity?',
                    message: 'You can start again anytime from Practice.',
                    confirmLabel: 'Exit',
                    isDestructive: true,
                  );
                  if (!context.mounted) return;
                  if (ok) {
                    AppState.read(context).endPractice();
                    onExit();
                  }
                },
                child: const Text('Exit activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
