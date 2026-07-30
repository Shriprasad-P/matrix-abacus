import 'dart:async';

import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/certificate.dart';
import '../models/child_profile.dart';
import '../models/course.dart';
import '../models/enums.dart';
import '../models/parent.dart';
import '../models/payment.dart';
import '../models/practice.dart';
import '../models/result.dart';
import '../models/worksheet.dart';
import '../repositories/matrix_repository.dart';

/// In-memory app state for the UI prototype.
class AppState extends ChangeNotifier {
  AppState({MatrixRepository? repository})
      : _repository = repository ?? MockMatrixRepository();

  final MatrixRepository _repository;

  Parent? parent;
  List<ChildProfile> children = [];
  String? selectedChildId;
  List<Course> courses = [];
  AttendanceSummary? attendance;
  List<Worksheet> worksheets = [];
  List<PracticeResult> results = [];
  List<Certificate> certificates = [];
  List<Announcement> announcements = [];
  PaymentPlan? paymentPlan;
  List<PaymentReceipt> receipts = [];
  PracticeActivity? dailyActivity;
  List<WeeklyActivityPoint> weeklyActivity = [];
  PracticeSessionState? practiceSession;
  PracticeResult? lastPracticeResult;

  bool isAuthenticated = false;
  bool isFirstTimeSetup = false;
  bool isBootstrapping = false;
  bool paymentSuccessVisible = false;

  UiDemoState worksheetsDemoState = UiDemoState.normal;
  UiDemoState certificatesDemoState = UiDemoState.normal;

  Timer? _practiceTimer;

  ChildProfile? get selectedChild {
    if (children.isEmpty) return null;
    final id = selectedChildId ?? children.first.id;
    return children.firstWhere((c) => c.id == id, orElse: () => children.first);
  }

  int get unreadAnnouncements => announcements.where((a) => !a.isRead).length;

  Future<void> bootstrapAccount({bool firstTime = false}) async {
    isBootstrapping = true;
    notifyListeners();
    parent = await _repository.fetchParent();
    children = await _repository.fetchChildren();
    selectedChildId = children.isNotEmpty ? children.first.id : null;
    announcements = await _repository.fetchAnnouncements();
    paymentPlan = await _repository.fetchPaymentPlan();
    receipts = await _repository.fetchReceipts();
    dailyActivity = await _repository.fetchDailyActivity();
    if (selectedChildId != null) {
      await loadChildScopedData(selectedChildId!);
    }
    isAuthenticated = true;
    isFirstTimeSetup = firstTime;
    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> loadChildScopedData(String childId) async {
    courses = await _repository.fetchCourses(childId);
    attendance = await _repository.fetchAttendance(childId);
    worksheets = await _repository.fetchWorksheets(childId);
    results = await _repository.fetchResults(childId);
    certificates = await _repository.fetchCertificates(childId);
    weeklyActivity = await _repository.fetchWeeklyActivity(childId);
    notifyListeners();
  }

  Future<void> selectChild(String childId) async {
    if (selectedChildId == childId) return;
    selectedChildId = childId;
    notifyListeners();
    await loadChildScopedData(childId);
  }

  Future<bool> verifyOtp(String mobile, String otp) {
    return _repository.verifyOtp(mobile: mobile, otp: otp);
  }

  void addChild(ChildProfile child) {
    children = [...children, child];
    selectedChildId = child.id;
    isFirstTimeSetup = false;
    notifyListeners();
    loadChildScopedData(child.id);
  }

  void updateChild(ChildProfile updated) {
    children = children.map((c) => c.id == updated.id ? updated : c).toList();
    notifyListeners();
  }

  void updateParent(Parent updated) {
    parent = updated;
    notifyListeners();
  }

  void markAnnouncementRead(String id) {
    announcements = announcements
        .map((a) => a.id == id ? a.copyWith(isRead: true) : a)
        .toList();
    notifyListeners();
  }

  void setWorksheetsDemoState(UiDemoState state) {
    worksheetsDemoState = state;
    notifyListeners();
  }

  void setCertificatesDemoState(UiDemoState state) {
    certificatesDemoState = state;
    notifyListeners();
  }

  void showPaymentSuccess() {
    paymentSuccessVisible = true;
    if (paymentPlan != null) {
      paymentPlan = PaymentPlan(
        name: paymentPlan!.name,
        amount: paymentPlan!.amount,
        billingCycle: paymentPlan!.billingCycle,
        status: PaymentStatus.paid,
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        dueAmount: 0,
      );
      receipts = [
        PaymentReceipt(
          id: 'pay_new',
          title: 'July tuition',
          amount: paymentPlan!.amount,
          date: DateTime.now(),
          status: PaymentStatus.paid,
        ),
        ...receipts,
      ];
    }
    notifyListeners();
  }

  void dismissPaymentSuccess() {
    paymentSuccessVisible = false;
    notifyListeners();
  }

  void startPractice(PracticeActivity activity) {
    _practiceTimer?.cancel();
    practiceSession = PracticeSessionState(
      activity: activity,
      currentIndex: 0,
      correctCount: 0,
      answers: List<int?>.filled(activity.questions.length, null),
      elapsedSeconds: 0,
      startedAt: DateTime.now(),
    );
    _practiceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (practiceSession == null || practiceSession!.isPaused) return;
      practiceSession = practiceSession!.copyWith(
        elapsedSeconds: practiceSession!.elapsedSeconds + 1,
      );
      notifyListeners();
    });
    notifyListeners();
  }

  void pausePractice() {
    practiceSession = practiceSession?.copyWith(isPaused: true);
    notifyListeners();
  }

  void resumePractice() {
    practiceSession = practiceSession?.copyWith(isPaused: false);
    notifyListeners();
  }

  void restartPractice() {
    final activity = practiceSession?.activity ?? dailyActivity;
    if (activity == null) return;
    startPractice(activity);
  }

  void clearFeedback() {
    practiceSession = practiceSession?.copyWith(feedback: AnswerFeedback.none);
    notifyListeners();
  }

  Future<bool> submitAnswer(int answer) async {
    final session = practiceSession;
    if (session == null || session.isComplete) return false;

    final correct = session.currentQuestion.correctAnswer == answer;
    final answers = List<int?>.from(session.answers);
    answers[session.currentIndex] = answer;

    practiceSession = session.copyWith(
      answers: answers,
      correctCount: session.correctCount + (correct ? 1 : 0),
      feedback: correct ? AnswerFeedback.correct : AnswerFeedback.incorrect,
    );
    notifyListeners();
    return correct;
  }

  void advanceQuestion() {
    final session = practiceSession;
    if (session == null) return;
    final next = session.currentIndex + 1;
    if (next >= session.total) {
      completePractice();
    } else {
      practiceSession = session.copyWith(
        currentIndex: next,
        feedback: AnswerFeedback.none,
      );
      notifyListeners();
    }
  }

  void completePractice() {
    _practiceTimer?.cancel();
    final session = practiceSession;
    final child = selectedChild;
    if (session == null || child == null) return;

    final answered = session.answers.where((a) => a != null).length;
    final accuracy = answered == 0 ? 0.0 : session.correctCount / answered;
    final avgSpeed = answered == 0 ? 0.0 : session.elapsedSeconds / answered;
    final stars = accuracy >= 0.9 ? 3 : accuracy >= 0.7 ? 2 : accuracy >= 0.5 ? 1 : 0;

    lastPracticeResult = PracticeResult(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      childId: child.id,
      title: session.activity.title,
      topic: 'Daily Practice',
      score: session.correctCount,
      total: session.total,
      accuracy: accuracy,
      avgSpeedSeconds: avgSpeed,
      date: DateTime.now(),
      teacherFeedback: 'Keep practicing — consistency builds confidence.',
      stars: stars,
    );

    results = [lastPracticeResult!, ...results];
    updateChild(
      child.copyWith(
        streak: child.streak + 1,
        accuracy: ((child.accuracy * 0.7) + (accuracy * 0.3)).clamp(0.0, 1.0),
        avgSpeedSeconds: ((child.avgSpeedSeconds * 0.7) + (avgSpeed * 0.3)),
        overallProgress: (child.overallProgress + 0.02).clamp(0.0, 1.0),
      ),
    );
    practiceSession = session.copyWith(
      currentIndex: session.total,
      isPaused: true,
      feedback: AnswerFeedback.none,
    );
    notifyListeners();
  }

  void endPractice() {
    _practiceTimer?.cancel();
    practiceSession = null;
    notifyListeners();
  }

  void logout() {
    _practiceTimer?.cancel();
    isAuthenticated = false;
    parent = null;
    children = [];
    selectedChildId = null;
    practiceSession = null;
    lastPracticeResult = null;
    paymentSuccessVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _practiceTimer?.cancel();
    super.dispose();
  }

  static AppState of(BuildContext context) => AppStateScope.of(context);

  static AppState read(BuildContext context) => AppStateScope.read(context);
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.notifier!;
  }
}
