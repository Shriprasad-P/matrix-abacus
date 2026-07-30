import 'dart:math';

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

class OtpChallenge {
  const OtpChallenge({
    required this.mobile,
    required this.code,
    required this.expiresAt,
  });

  final String mobile;
  final String code;
  final DateTime expiresAt;
}

/// Repository contract used by the UI. The mock implementation keeps the
/// prototype usable on a phone while the API client is being integrated.
abstract class MatrixRepository {
  Future<Parent> fetchParent({String? mobile});
  Future<List<ChildProfile>> fetchChildren({String? mobile});
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
  Future<OtpChallenge> requestOtp({required String mobile});
  Future<bool> verifyOtp({required String mobile, required String otp});
}

class MockMatrixRepository implements MatrixRepository {
  MockMatrixRepository({this.latency = const Duration(milliseconds: 650)});

  final Duration latency;
  final Map<String, String> _otpCodes = {};

  Future<T> _delay<T>(T value) async {
    await Future<void>.delayed(latency);
    return value;
  }

  @override
  Future<Parent> fetchParent({String? mobile}) {
    if (mobile == '9999999999') return _delay(MockData.admin);
    if (mobile == '9876543210') return _delay(MockData.parent);
    return _delay(
      Parent(
        id: 'p_${mobile ?? 'new'}',
        name: '',
        mobile: mobile ?? '',
        email: '',
      ),
    );
  }

  @override
  Future<List<ChildProfile>> fetchChildren({String? mobile}) {
    if (mobile == '9876543210') return _delay(List.of(MockData.children));
    return _delay(<ChildProfile>[]);
  }

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
  Future<List<PaymentReceipt>> fetchReceipts() =>
      _delay(List.of(MockData.receipts));

  @override
  Future<PracticeActivity> fetchDailyActivity() =>
      _delay(MockData.dailyActivity);

  @override
  Future<List<WeeklyActivityPoint>> fetchWeeklyActivity(String childId) =>
      _delay(MockData.weeklyActivity(childId));

  @override
  Future<OtpChallenge> requestOtp({required String mobile}) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final code = (100000 + Random.secure().nextInt(900000)).toString();
    _otpCodes[mobile] = code;
    return OtpChallenge(
      mobile: mobile,
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<bool> verifyOtp({required String mobile, required String otp}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return _otpCodes[mobile] == otp;
  }
}
