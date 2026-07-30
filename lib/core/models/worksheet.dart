import 'enums.dart';

class Worksheet {
  const Worksheet({
    required this.id,
    required this.title,
    required this.description,
    required this.instructions,
    required this.topic,
    required this.dueDate,
    required this.status,
    required this.progress,
    this.childId,
  });

  final String id;
  final String title;
  final String description;
  final String instructions;
  final String topic;
  final DateTime dueDate;
  final WorksheetStatus status;
  final double progress;
  final String? childId;
}
