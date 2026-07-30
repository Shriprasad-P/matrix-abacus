import 'enums.dart';

class AttendanceDay {
  const AttendanceDay({
    required this.date,
    required this.status,
  });

  final DateTime date;
  final AttendanceStatus status;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.percentage,
    required this.presentCount,
    required this.absentCount,
    required this.holidayCount,
    required this.days,
  });

  final double percentage;
  final int presentCount;
  final int absentCount;
  final int holidayCount;
  final List<AttendanceDay> days;
}
