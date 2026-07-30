import 'enums.dart';

class CourseLevel {
  const CourseLevel({
    required this.id,
    required this.title,
    required this.order,
    required this.state,
    required this.progress,
  });

  final String id;
  final String title;
  final int order;
  final LevelState state;
  final double progress;
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.levels,
    required this.progress,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final List<CourseLevel> levels;
  final double progress;
  final int color;
}
