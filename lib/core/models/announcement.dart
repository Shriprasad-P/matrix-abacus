import 'enums.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    this.priority = AnnouncementPriority.normal,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final AnnouncementPriority priority;

  Announcement copyWith({bool? isRead}) {
    return Announcement(
      id: id,
      title: title,
      body: body,
      date: date,
      isRead: isRead ?? this.isRead,
      priority: priority,
    );
  }
}
