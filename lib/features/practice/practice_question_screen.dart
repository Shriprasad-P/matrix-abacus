import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
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
  final _answerFocus = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _submitting) return;
    final answer = int.tryParse(text);
    if (answer == null) return;

    setState(() => _submitting = true);
    _answerFocus.unfocus();
    await state.submitAnswer(answer);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    _answerController.clear();
    setState(() => _submitting = false);

    final session = state.practiceSession;
    if (session == null) return;

    state.advanceQuestion();
    if (state.practiceSession?.isComplete == true) {
      widget.onCompleted();
    } else if (mounted) {
      _answerFocus.requestFocus();
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
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final session = state.practiceSession;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    if (session == null) {
      return Scaffold(
        body: EmptyState(
          title: 'No active session',
          message: 'Start practice again from the Practice tab.',
          actionLabel: 'Back',
          onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false),
        ),
      );
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
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.practiceGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding,
                AppSpacing.screenPadding + bottomInset * 0.05,
              ),
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
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            children: [
                              Text(
                                q.prompt,
                                style: AppTypography.score(),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${q.operands.join(' ${q.operatorSymbol} ')} = ?',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const AbacusVisualizer(),
                        const SizedBox(height: AppSpacing.lg),
                        AnswerInput(
                          controller: _answerController,
                          focusNode: _answerFocus,
                          enabled: !_submitting && feedback == AnswerFeedback.none,
                          onSubmitted: (_) => _submit(state),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PracticeFeedbackPanel(
                          feedback: feedback,
                          correctAnswer: q.correctAnswer,
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
