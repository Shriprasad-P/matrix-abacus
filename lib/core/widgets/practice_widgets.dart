import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../models/enums.dart';

/// Interactive-looking abacus with 5 rods (local mock interactions).
class AbacusVisualizer extends StatefulWidget {
  const AbacusVisualizer({
    super.key,
    this.initialValue = 0,
    this.onChanged,
  });

  final int initialValue;
  final ValueChanged<int>? onChanged;

  @override
  State<AbacusVisualizer> createState() => _AbacusVisualizerState();
}

class _AbacusVisualizerState extends State<AbacusVisualizer> {
  // Each rod: heaven bead (0/1 * 5) + earth beads (0-4).
  late List<_RodState> _rods;

  @override
  void initState() {
    super.initState();
    _rods = List.generate(5, (_) => const _RodState());
    _setFromValue(widget.initialValue.clamp(0, 99999));
  }

  int get value {
    var total = 0;
    for (var i = 0; i < _rods.length; i++) {
      final place = _pow10(_rods.length - 1 - i);
      total += (_rods[i].heaven * 5 + _rods[i].earth) * place;
    }
    return total;
  }

  void _setFromValue(int n) {
    for (var i = 0; i < _rods.length; i++) {
      final place = _pow10(_rods.length - 1 - i);
      final digit = (n ~/ place) % 10;
      _rods[i] = _RodState(heaven: digit >= 5 ? 1 : 0, earth: digit % 5);
    }
  }

  int _pow10(int exp) {
    var r = 1;
    for (var i = 0; i < exp; i++) {
      r *= 10;
    }
    return r;
  }

  void _notify() {
    widget.onChanged?.call(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Abacus visualizer showing $value',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D2B1F), Color(0xFF5A3E2B)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Abacus',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$value',
                    style: AppTypography.stat(color: Colors.white).copyWith(fontSize: 18),
                  ),
                ),
                IconButton(
                  tooltip: 'Reset abacus',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _rods = List.generate(5, (_) => const _RodState()));
                    _notify();
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1C14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(_rods.length, (i) {
                  return Expanded(
                    child: _RodColumn(
                      state: _rods[i],
                      onHeavenTap: () {
                        HapticFeedback.lightImpact();
                        _rods[i] = _rods[i].copyWith(heaven: _rods[i].heaven == 0 ? 1 : 0);
                        _notify();
                      },
                      onEarthTap: (earth) {
                        HapticFeedback.lightImpact();
                        final current = _rods[i].earth;
                        _rods[i] = _rods[i].copyWith(earth: current == earth ? earth - 1 : earth);
                        _notify();
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap beads to count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _RodState {
  const _RodState({this.heaven = 0, this.earth = 0});

  final int heaven;
  final int earth;

  _RodState copyWith({int? heaven, int? earth}) =>
      _RodState(heaven: heaven ?? this.heaven, earth: earth ?? this.earth);
}

class _RodColumn extends StatelessWidget {
  const _RodColumn({
    required this.state,
    required this.onHeavenTap,
    required this.onEarthTap,
  });

  final _RodState state;
  final VoidCallback onHeavenTap;
  final ValueChanged<int> onEarthTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 4, color: const Color(0xFFD7B899)),
              Align(
                alignment: state.heaven == 1 ? Alignment.bottomCenter : Alignment.topCenter,
                child: _Bead(active: state.heaven == 1, onTap: onHeavenTap, color: AppColors.secondary),
              ),
            ],
          ),
        ),
        Container(height: 6, margin: const EdgeInsets.symmetric(vertical: 4), color: const Color(0xFFC9A227)),
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 4, height: double.infinity, color: const Color(0xFFD7B899)),
              ...List.generate(4, (i) {
                final beadValue = i + 1;
                final active = state.earth >= beadValue;
                final top = active ? 8.0 + i * 26 : 110.0 - (3 - i) * 26.0;
                return Positioned(
                  top: top.clamp(0, 90),
                  child: _Bead(
                    active: active,
                    onTap: () => onEarthTap(beadValue),
                    color: AppColors.primaryLight,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bead extends StatelessWidget {
  const _Bead({required this.active, required this.onTap, required this.color});

  final bool active;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: active ? 'Active bead' : 'Inactive bead',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnswerInput extends StatelessWidget {
  const AnswerInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Answer input',
      textField: true,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.stat(),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: 'Your answer',
          prefixIcon: Icon(Icons.edit_rounded),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class PracticeQuestionHeader extends StatelessWidget {
  const PracticeQuestionHeader({
    super.key,
    required this.current,
    required this.total,
    required this.elapsedSeconds,
    this.onPause,
  });

  final int current;
  final int total;
  final int elapsedSeconds;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context) {
    final progress = current / total;
    final mins = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (elapsedSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        Row(
          children: [
            Text('Question $current of $total', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('$mins:$secs', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            if (onPause != null)
              IconButton(
                tooltip: 'Pause',
                onPressed: onPause,
                icon: const Icon(Icons.pause_circle_outline_rounded),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
      ],
    );
  }
}

class SuccessStateView extends StatelessWidget {
  const SuccessStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: AppColors.success),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Correct / incorrect feedback panel for practice answers.
class PracticeFeedbackPanel extends StatelessWidget {
  const PracticeFeedbackPanel({
    super.key,
    required this.feedback,
    required this.correctAnswer,
  });

  final AnswerFeedback feedback;
  final int correctAnswer;

  @override
  Widget build(BuildContext context) {
    if (feedback == AnswerFeedback.none) return const SizedBox.shrink();

    final correct = feedback == AnswerFeedback.correct;
    return Semantics(
      liveRegion: true,
      label: correct ? 'Correct answer' : 'Incorrect. Correct answer is $correctAnswer',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: correct ? AppColors.successSoft : AppColors.errorSoft,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: correct ? AppColors.success.withValues(alpha: 0.35) : AppColors.error.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: correct ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                correct
                    ? 'Nice! That’s correct.'
                    : 'Not quite — the answer is $correctAnswer. Keep going!',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: correct ? AppColors.success : AppColors.error,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
