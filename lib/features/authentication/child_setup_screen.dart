import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/models/child_profile.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';

class ChildSetupScreen extends StatefulWidget {
  const ChildSetupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  final _name = TextEditingController();
  final _className = TextEditingController(text: 'Class 2');
  int _age = 7;

  @override
  void dispose() {
    _name.dispose();
    _className.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your child’s name')),
      );
      return;
    }
    final child = ChildProfile(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      age: _age,
      className: _className.text.trim(),
      avatarColor: 0xFF5B67C7,
      avatarEmoji: '🌟',
      currentLevel: 'Level 1 · Getting Started',
      currentCourse: 'Little Abacus',
      streak: 0,
      overallProgress: 0.05,
      accuracy: 0,
      avgSpeedSeconds: 0,
      badges: const ['First Steps'],
    );
    AppState.read(context).addChild(child);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add your child')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Text('First-time setup', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Create a profile so practice and progress stay organised.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Child name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _className,
              decoration: const InputDecoration(labelText: 'Class / grade'),
            ),
            const SizedBox(height: 16),
            Text('Age: $_age', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _age.toDouble(),
              min: 4,
              max: 14,
              divisions: 10,
              label: '$_age',
              onChanged: (v) => setState(() => _age = v.round()),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(label: 'Continue to home', onPressed: _save),
            const SizedBox(height: 12),
            AppSecondaryButton(
              label: 'Skip — use sample children',
              onPressed: widget.onDone,
            ),
          ],
        ),
      ),
    );
  }
}
