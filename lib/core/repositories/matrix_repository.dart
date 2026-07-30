import '../mock/mock_data.dart';
import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/certificate.dart';
import '../models/child_profile.dart';
import '../models/course.dart';
import '../models/parent.dart';
import '../models/payment.dart';
import '../models/practice.dart';
import '../models/result.dart';
import '../models/worksheet.dart';

/// Mock repository layer. Swap implementations for real API clients later.
abstract class MatrixRepository {
  Future<Parent> fetchParent();
  Future<List<ChildProfile>> fetchChildren();
  Future<List<Course>> fetchCourses(String childId);
  Future<AttendanceSummary> fetchAttendance(String childId);
  Future<List<Worksheet>> fetchWorksheets(String childId);
  Future<List<PracticeResult>> fetchResults(String childId);
  Future<List<Certificate>> fetchCertificates(String childId);
  Future<List<Announcement>> fetchAnnouncements();
  Future<PaymentPlan> fetchPaymentPlan();
  Future<List<PaymentReceipt>> fetchReceipts();
  Future<PracticeActivity> fetchDailyActivity();
  Future<List<WeeklyActivityPoint>> fetchWeeklyActivity(String childId);
  Future<bool> verifyOtp({required String mobile, required String otp});
}

class MockMatrixRepository implements MatrixRepository {
  MockMatrixRepository({this.latency = const Duration(milliseconds: 650)});

  final Duration latency;

  Future<T> _delay<T>(T value) async {
    await Future<void>.delayed(latency);
    return value;
  }

  @override
  Future<Parent> fetchParent() => _delay(MockData.parent);

  @override
  Future<List<ChildProfile>> fetchChildren() => _delay(List.of(MockData.children));

  @override
  Future<List<Course>> fetchCourses(String childId) =>
      _delay(MockData.coursesFor(childId));

  @override
  Future<AttendanceSummary> fetchAttendance(String childId) =>
      _delay(MockData.attendanceFor(childId));

  @override
  Future<List<Worksheet>> fetchWorksheets(String childId) =>
      _delay(MockData.worksheetsFor(childId));

  @override
  Future<List<PracticeResult>> fetchResults(String childId) =>
      _delay(MockData.resultsFor(childId));

  @override
  Future<List<Certificate>> fetchCertificates(String childId) =>
      _delay(MockData.certificatesFor(childId));

  @override
  Future<List<Announcement>> fetchAnnouncements() =>
      _delay(List.of(MockData.announcements));

  @override
  Future<PaymentPlan> fetchPaymentPlan() => _delay(MockData.currentPlan);

  @override
  Future<List<PaymentReceipt>> fetchReceipts() => _delay(List.of(MockData.receipts));

  @override
  Future<PracticeActivity> fetchDailyActivity() => _delay(MockData.dailyActivity);

  @override
  Future<List<WeeklyActivityPoint>> fetchWeeklyActivity(String childId) =>
      _delay(MockData.weeklyActivity(childId));

  @override
  Future<bool> verifyOtp({required String mobile, required String otp}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    // Any 4–6 digit OTP is accepted in the prototype.
    return otp.length >= 4 && otp.length <= 6 && RegExp(r'^\d+$').hasMatch(otp);
  }
}
