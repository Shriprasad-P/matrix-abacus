import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onGetStarted, required this.onLogin});

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

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
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: AppColors.practiceGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 88, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'A calm space for parents to guide learning — and a playful practice mode for children.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              AppPrimaryButton(label: 'Get started', onPressed: onGetStarted),
              const SizedBox(height: 12),
              AppSecondaryButton(label: 'I already have an account', onPressed: onLogin),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
