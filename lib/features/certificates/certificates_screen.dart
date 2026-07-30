import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/feature_cards.dart';
import '../../../core/widgets/practice_widgets.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key, required this.onOpenCertificate});

  final ValueChanged<String> onOpenCertificate;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          PopupMenuButton<UiDemoState>(
            onSelected: state.setCertificatesDemoState,
            itemBuilder: (_) => const [
              PopupMenuItem(value: UiDemoState.normal, child: Text('Normal')),
              PopupMenuItem(value: UiDemoState.empty, child: Text('Empty')),
              PopupMenuItem(value: UiDemoState.loading, child: Text('Loading')),
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
    switch (state.certificatesDemoState) {
      case UiDemoState.loading:
        return const LoadingSkeleton();
      case UiDemoState.empty:
        return EmptyState(
          title: 'No certificates yet',
          message: 'Keep practicing to unlock achievements.',
          onAction: () => state.setCertificatesDemoState(UiDemoState.normal),
          actionLabel: 'Back to list',
        );
      case UiDemoState.error:
        return ErrorState(
          title: 'Couldn’t load certificates',
          message: 'Mock error state.',
          onRetry: () => state.setCertificatesDemoState(UiDemoState.normal),
        );
      case UiDemoState.normal:
        return ListView.separated(
          itemCount: state.certificates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = state.certificates[index];
            return CertificateCard(
              certificate: c,
              onTap: () => onOpenCertificate(c.id),
            );
          },
        );
    }
  }
}

class CertificateDetailsScreen extends StatelessWidget {
  const CertificateDetailsScreen({super.key, required this.certificateId});

  final String certificateId;

  @override
  Widget build(BuildContext context) {
    final list = AppState.of(context).certificates;
    final cert = list.firstWhere((c) => c.id == certificateId, orElse: () => list.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            if (cert.earned)
              const SuccessStateView(
                title: 'Well earned!',
                message: 'This certificate celebrates steady practice.',
                icon: Icons.workspace_premium_rounded,
              )
            else
              const EmptyState(
                title: 'Still locked',
                message: 'Complete the related milestone to unlock this certificate.',
                icon: Icons.lock_outline_rounded,
              ),
            const SizedBox(height: 24),
            Text(cert.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(cert.description, textAlign: TextAlign.center),
            if (cert.earnedDate != null) ...[
              const SizedBox(height: 8),
              Text('Earned on ${cert.earnedDate!.day}/${cert.earnedDate!.month}/${cert.earnedDate!.year}'),
            ],
            const Spacer(),
            AppPrimaryButton(
              label: cert.earned ? 'Preview / download' : 'Locked',
              onPressed: cert.earned
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mock certificate preview')),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
