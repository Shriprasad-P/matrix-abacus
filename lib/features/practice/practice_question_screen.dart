import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/practice_widgets.dart';

class PracticeQuestionScreen extends StatefulWidget {
  const PracticeQuestionScreen({
    super.key,
    required this.onPaused,
    required this.onCompleted,
  });

  final VoidCallback onPaused;
  final VoidCallback onCompleted;

  @override
  State<PracticeQuestionScreen> createState() => _PracticeQuestionScreenState();
}

class _PracticeQuestionScreenState extends State<PracticeQuestionScreen> {
  final _answerController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _submitting) return;
    final answer = int.tryParse(text);
    if (answer == null) return;

    setState(() => _submitting = true);
    await state.submitAnswer(answer);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    _answerController.clear();
    setState(() => _submitting = false);

    final session = state.practiceSession;
    if (session == null) return;

    if (session.currentIndex + 1 >= session.total && session.feedback != AnswerFeedback.none) {
      state.advanceQuestion();
      widget.onCompleted();
    } else {
      state.advanceQuestion();
      if (state.practiceSession?.isComplete == true) {
        widget.onCompleted();
      }
    }
  }

  Future<void> _confirmExit(BuildContext context, AppState state) async {
    final ok = await showAppConfirmDialog(
      context: context,
      title: 'Leave practice?',
      message: 'Your current session progress will be discarded.',
      confirmLabel: 'Exit',
      isDestructive: true,
    );
    if (ok && context.mounted) {
      state.endPractice();
      Navigator.of(context).pushNamedAndRemoveUntil('/app', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final session = state.practiceSession;

    if (session == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    if (session.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onCompleted());
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = session.currentQuestion;
    final feedback = session.feedback;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context, state);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.practiceGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  PracticeQuestionHeader(
                    current: session.currentIndex + 1,
                    total: session.total,
                    elapsedSeconds: session.elapsedSeconds,
                    onPause: () {
                      state.pausePractice();
                      widget.onPaused();
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            children: [
                              Text(
                                q.prompt,
                                style: AppTypography.score(),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${q.operands.join(' ${q.operatorSymbol} ')} = ?',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AbacusVisualizer(),
                        const SizedBox(height: 16),
                        AnswerInput(
                          controller: _answerController,
                          enabled: !_submitting && feedback == AnswerFeedback.none,
                          onSubmitted: (_) => _submit(state),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: feedback == AnswerFeedback.none
                              ? const SizedBox.shrink()
                              : Container(
                                  key: ValueKey(feedback),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: feedback == AnswerFeedback.correct
                                        ? AppColors.successSoft
                                        : AppColors.errorSoft,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        feedback == AnswerFeedback.correct
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: feedback == AnswerFeedback.correct
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feedback == AnswerFeedback.correct
                                              ? 'Nice! That’s correct.'
                                              : 'Not quite — the answer is ${q.correctAnswer}. Keep going!',
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  AppPrimaryButton(
                    label: 'Submit',
                    onPressed: (_submitting || feedback != AnswerFeedback.none)
                        ? null
                        : () => _submit(state),
                    isLoading: _submitting,
                  ),
                  TextButton(
                    onPressed: () => _confirmExit(context, state),
                    child: const Text('Exit activity'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
