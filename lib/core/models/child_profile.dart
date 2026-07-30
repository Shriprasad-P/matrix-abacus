class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.className,
    this.schoolName = '',
    required this.avatarColor,
    required this.avatarEmoji,
    required this.currentLevel,
    required this.currentCourse,
    required this.streak,
    required this.overallProgress,
    required this.accuracy,
    required this.avgSpeedSeconds,
    required this.badges,
  });

  final String id;
  final String name;
  final int age;
  final String className;
  final String schoolName;
  final int avatarColor;
  final String avatarEmoji;
  final String currentLevel;
  final String currentCourse;
  final int streak;
  final double overallProgress;
  final double accuracy;
  final double avgSpeedSeconds;
  final List<String> badges;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  ChildProfile copyWith({
    String? name,
    int? age,
    String? className,
    String? schoolName,
    int? streak,
    double? overallProgress,
    double? accuracy,
    double? avgSpeedSeconds,
    List<String>? badges,
    String? currentLevel,
    String? currentCourse,
  }) {
    return ChildProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      className: className ?? this.className,
      schoolName: schoolName ?? this.schoolName,
      avatarColor: avatarColor,
      avatarEmoji: avatarEmoji,
      currentLevel: currentLevel ?? this.currentLevel,
      currentCourse: currentCourse ?? this.currentCourse,
      streak: streak ?? this.streak,
      overallProgress: overallProgress ?? this.overallProgress,
      accuracy: accuracy ?? this.accuracy,
      avgSpeedSeconds: avgSpeedSeconds ?? this.avgSpeedSeconds,
      badges: badges ?? this.badges,
    );
  }
}
