import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/practice_widgets.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key, required this.onPaymentSuccess});

  final VoidCallback onPaymentSuccess;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final plan = state.paymentPlan;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (plan != null) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current plan', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(plan.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('₹${plan.amount.toStringAsFixed(0)} / ${plan.billingCycle.toLowerCase()}'),
                  const SizedBox(height: 12),
                  StatusChip(
                    label: plan.status == PaymentStatus.paid ? 'Paid' : 'Due',
                    color: plan.status == PaymentStatus.paid ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.dueAmount > 0
                        ? 'Due ₹${plan.dueAmount.toStringAsFixed(0)} by ${plan.nextDueDate.day}/${plan.nextDueDate.month}'
                        : 'Next billing ${plan.nextDueDate.day}/${plan.nextDueDate.month}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: plan.dueAmount > 0 ? 'Pay now (UI only)' : 'Already paid',
              onPressed: plan.dueAmount > 0
                  ? () {
                      state.showPaymentSuccess();
                      onPaymentSuccess();
                    }
                  : null,
            ),
          ],
          const SizedBox(height: 24),
          Text('Receipts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...state.receipts.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title, style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          '${r.date.day}/${r.date.month}/${r.date.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text('₹${r.amount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              const SuccessStateView(
                title: 'Payment successful',
                message: 'This is a mock success state. No real charge was made.',
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Back to payments',
                onPressed: () {
                  AppState.read(context).dismissPaymentSuccess();
                  onDone();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
