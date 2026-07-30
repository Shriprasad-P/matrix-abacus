import 'enums.dart';

class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.prompt,
    required this.operands,
    required this.operatorSymbol,
    required this.correctAnswer,
    this.hint,
  });

  final String id;
  final String prompt;
  final List<int> operands;
  final String operatorSymbol;
  final int correctAnswer;
  final String? hint;
}

class PracticeActivity {
  const PracticeActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.encouragement,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final PracticeDifficulty difficulty;
  final String encouragement;
  final List<PracticeQuestion> questions;
}

class PracticeSessionState {
  const PracticeSessionState({
    required this.activity,
    required this.currentIndex,
    required this.correctCount,
    required this.answers,
    required this.elapsedSeconds,
    required this.startedAt,
    this.isPaused = false,
    this.feedback = AnswerFeedback.none,
  });

  final PracticeActivity activity;
  final int currentIndex;
  final int correctCount;
  final List<int?> answers;
  final int elapsedSeconds;
  final DateTime startedAt;
  final bool isPaused;
  final AnswerFeedback feedback;

  PracticeQuestion get currentQuestion => activity.questions[currentIndex];
  int get total => activity.questions.length;
  bool get isComplete => currentIndex >= total;
  double get accuracy => total == 0 ? 0 : correctCount / answers.where((a) => a != null).length.clamp(1, 999);

  PracticeSessionState copyWith({
    int? currentIndex,
    int? correctCount,
    List<int?>? answers,
    int? elapsedSeconds,
    bool? isPaused,
    AnswerFeedback? feedback,
  }) {
    return PracticeSessionState(
      activity: activity,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      answers: answers ?? this.answers,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: startedAt,
      isPaused: isPaused ?? this.isPaused,
      feedback: feedback ?? this.feedback,
    );
  }
}

class WeeklyActivityPoint {
  const WeeklyActivityPoint({required this.label, required this.minutes});

  final String label;
  final int minutes;
}
