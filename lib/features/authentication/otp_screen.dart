import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.mobile,
    required this.onVerified,
  });

  final String mobile;
  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _controller.text.trim();
    if (otp.length < 4) {
      setState(() => _error = 'Enter the 4–6 digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await AppState.read(context).verifyOtp(widget.mobile, otp);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      widget.onVerified();
    } else {
      setState(() => _error = 'Invalid code. Try any 4–6 digits.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final masked = widget.mobile.length >= 4
        ? '******${widget.mobile.substring(widget.mobile.length - 4)}'
        : widget.mobile;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enter verification code', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Code sent to +91 $masked\nPrototype tip: any 4–6 digit OTP works.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: '••••',
                  errorText: _error,
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mock OTP resent')),
                  );
                },
                child: const Text('Resend code'),
              ),
              const Spacer(),
              AppPrimaryButton(label: 'Verify & continue', onPressed: _verify, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
