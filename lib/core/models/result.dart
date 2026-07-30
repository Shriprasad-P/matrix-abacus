class PracticeResult {
  const PracticeResult({
    required this.id,
    required this.childId,
    required this.title,
    required this.topic,
    required this.score,
    required this.total,
    required this.accuracy,
    required this.avgSpeedSeconds,
    required this.date,
    this.teacherFeedback,
    this.stars = 0,
  });

  final String id;
  final String childId;
  final String title;
  final String topic;
  final int score;
  final int total;
  final double accuracy;
  final double avgSpeedSeconds;
  final DateTime date;
  final String? teacherFeedback;
  final int stars;
}
