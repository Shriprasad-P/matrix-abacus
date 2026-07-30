import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class ParentSetupScreen extends StatefulWidget {
  const ParentSetupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ParentSetupScreen> createState() => _ParentSetupScreenState();
}

class _ParentSetupScreenState extends State<ParentSetupScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final parent = AppState.read(context).parent;
    _name = TextEditingController(text: parent?.name ?? '');
    _email = TextEditingController(text: parent?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the parent or guardian name.'),
        ),
      );
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address or leave it blank.'),
        ),
      );
      return;
    }
    final state = AppState.read(context);
    final parent = state.parent;
    if (parent == null) return;
    state.updateParent(parent.copyWith(name: name, email: email));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text(
              'Tell us about you',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We use these details to keep your family account and learning updates organised.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Parent / guardian name',
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address (optional)',
                hintText: 'you@example.com',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mobile number is verified through OTP and cannot be changed here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: 'Continue to child details',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
