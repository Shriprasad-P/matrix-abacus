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

/// Central mock dataset for the UI prototype.
abstract final class MockData {
  static final Parent parent = Parent(
    id: 'p1',
    name: 'Priya Sharma',
    mobile: '+91 98765 43210',
    email: 'priya.sharma@email.com',
  );

  static final Parent admin = Parent(
    id: 'admin1',
    name: 'Matrix Admin',
    mobile: '+91 99999 99999',
    email: 'admin@matrixabacus.com',
    role: 'admin',
  );

  static final List<ChildProfile> children = [
    ChildProfile(
      id: 'c1',
      name: 'Aarav Sharma',
      age: 8,
      className: 'Class 3',
      avatarColor: 0xFF5B67C7,
      avatarEmoji: '🦊',
      currentLevel: 'Level 4 · Addition Mastery',
      currentCourse: 'Foundation Abacus',
      streak: 12,
      overallProgress: 0.68,
      accuracy: 0.86,
      avgSpeedSeconds: 6.4,
      badges: ['First Steps', 'Week Streak', 'Speed Star'],
    ),
    ChildProfile(
      id: 'c2',
      name: 'Anaya Sharma',
      age: 6,
      className: 'Class 1',
      avatarColor: 0xFFF4A261,
      avatarEmoji: '🐰',
      currentLevel: 'Level 2 · Bead Basics',
      currentCourse: 'Little Abacus',
      streak: 5,
      overallProgress: 0.42,
      accuracy: 0.79,
      avgSpeedSeconds: 9.1,
      badges: ['First Steps', 'Curious Learner'],
    ),
    ChildProfile(
      id: 'c3',
      name: 'Vihaan Sharma',
      age: 10,
      className: 'Class 5',
      avatarColor: 0xFF2E9E6A,
      avatarEmoji: '🦁',
      currentLevel: 'Level 7 · Multiplication',
      currentCourse: 'Advanced Abacus',
      streak: 21,
      overallProgress: 0.81,
      accuracy: 0.92,
      avgSpeedSeconds: 4.8,
      badges: ['First Steps', 'Month Streak', 'Accuracy Ace', 'Challenge Champ'],
    ),
  ];

  static List<Course> coursesFor(String childId) {
    if (childId == 'c2') {
      return [
        Course(
          id: 'course_little',
          title: 'Little Abacus',
          description: 'Gentle introduction to beads and numbers.',
          progress: 0.42,
          color: 0xFFF4A261,
          levels: [
            const CourseLevel(id: 'l1', title: 'Number Friends', order: 1, state: LevelState.completed, progress: 1),
            const CourseLevel(id: 'l2', title: 'Bead Basics', order: 2, state: LevelState.current, progress: 0.55),
            const CourseLevel(id: 'l3', title: 'Simple Adds', order: 3, state: LevelState.unlocked, progress: 0),
            const CourseLevel(id: 'l4', title: 'Tiny Takes', order: 4, state: LevelState.locked, progress: 0),
          ],
        ),
      ];
    }
    if (childId == 'c3') {
      return [
        Course(
          id: 'course_adv',
          title: 'Advanced Abacus',
          description: 'Speed, multiplication, and mental visualization.',
          progress: 0.81,
          color: 0xFF2E9E6A,
          levels: [
            const CourseLevel(id: 'a1', title: 'Review Path', order: 1, state: LevelState.completed, progress: 1),
            const CourseLevel(id: 'a2', title: 'Multiplication', order: 2, state: LevelState.current, progress: 0.7),
            const CourseLevel(id: 'a3', title: 'Division Ready', order: 3, state: LevelState.unlocked, progress: 0),
            const CourseLevel(id: 'a4', title: 'Flash Mentals', order: 4, state: LevelState.locked, progress: 0),
          ],
        ),
      ];
    }
    return [
      Course(
        id: 'course_found',
        title: 'Foundation Abacus',
        description: 'Core addition and subtraction with the abacus.',
        progress: 0.68,
        color: 0xFF2F3A8F,
        levels: [
          const CourseLevel(id: 'f1', title: 'Bead Orientation', order: 1, state: LevelState.completed, progress: 1),
          const CourseLevel(id: 'f2', title: 'Single Digit Adds', order: 2, state: LevelState.completed, progress: 1),
          const CourseLevel(id: 'f3', title: 'Friends of 5', order: 3, state: LevelState.completed, progress: 1),
          const CourseLevel(id: 'f4', title: 'Addition Mastery', order: 4, state: LevelState.current, progress: 0.45),
          const CourseLevel(id: 'f5', title: 'Subtraction Path', order: 5, state: LevelState.unlocked, progress: 0),
          const CourseLevel(id: 'f6', title: 'Mixed Practice', order: 6, state: LevelState.locked, progress: 0),
        ],
      ),
      Course(
        id: 'course_speed',
        title: 'Speed Builder',
        description: 'Timed drills to build fluency.',
        progress: 0.25,
        color: 0xFFE9A825,
        levels: [
          const CourseLevel(id: 's1', title: 'Warm-up Rounds', order: 1, state: LevelState.completed, progress: 1),
          const CourseLevel(id: 's2', title: 'Beat the Clock', order: 2, state: LevelState.current, progress: 0.2),
          const CourseLevel(id: 's3', title: 'Flash Sets', order: 3, state: LevelState.locked, progress: 0),
        ],
      ),
    ];
  }

  static AttendanceSummary attendanceFor(String childId) {
    final now = DateTime.now();
    final days = <AttendanceDay>[];
    var present = 0;
    var absent = 0;
    var holiday = 0;

    for (var i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      AttendanceStatus status;
      if (date.weekday == DateTime.sunday) {
        status = AttendanceStatus.holiday;
        holiday++;
      } else if (i == 3 || i == 11 || (childId == 'c2' && i == 7)) {
        status = AttendanceStatus.absent;
        absent++;
      } else if (date.weekday == DateTime.saturday && i % 5 == 0) {
        status = AttendanceStatus.none;
      } else {
        status = AttendanceStatus.present;
        present++;
      }
      days.add(AttendanceDay(date: date, status: status));
    }

    final tracked = present + absent;
    return AttendanceSummary(
      percentage: tracked == 0 ? 0 : present / tracked,
      presentCount: present,
      absentCount: absent,
      holidayCount: holiday,
      days: days,
    );
  }

  static List<Worksheet> worksheetsFor(String childId) {
    if (childId == 'c2') {
      return [
        Worksheet(
          id: 'w_empty_demo',
          title: 'Counting Beads',
          description: 'Practice counting on the upper and lower beads.',
          instructions: 'Complete all 12 problems. Show your work with beads.',
          topic: 'Basics',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          status: WorksheetStatus.isNew,
          progress: 0,
          childId: childId,
        ),
      ];
    }
    return [
      Worksheet(
        id: 'w1',
        title: 'Friends of 10',
        description: 'Make tens using complementary numbers.',
        instructions: 'Solve each pair. Use the abacus for the first 5, then try mentally.',
        topic: 'Addition',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: WorksheetStatus.inProgress,
        progress: 0.4,
        childId: childId,
      ),
      Worksheet(
        id: 'w2',
        title: 'Column Adds',
        description: 'Two-digit addition with carrying.',
        instructions: 'Write answers clearly. Circle any question you want to review.',
        topic: 'Addition',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        status: WorksheetStatus.isNew,
        progress: 0,
        childId: childId,
      ),
      Worksheet(
        id: 'w3',
        title: 'Weekly Review Pack',
        description: 'Mixed review from Levels 1–3.',
        instructions: 'Complete in one sitting if possible.',
        topic: 'Mixed',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: WorksheetStatus.completed,
        progress: 1,
        childId: childId,
      ),
    ];
  }

  static List<PracticeResult> resultsFor(String childId) {
    return [
      PracticeResult(
        id: 'r1',
        childId: childId,
        title: 'Daily Drill',
        topic: 'Addition',
        score: 8,
        total: 10,
        accuracy: 0.8,
        avgSpeedSeconds: 7.2,
        date: DateTime.now().subtract(const Duration(days: 1)),
        teacherFeedback: 'Great focus today. Watch carrying on question 7.',
        stars: 3,
      ),
      PracticeResult(
        id: 'r2',
        childId: childId,
        title: 'Speed Round',
        topic: 'Mixed Ops',
        score: 9,
        total: 10,
        accuracy: 0.9,
        avgSpeedSeconds: 5.1,
        date: DateTime.now().subtract(const Duration(days: 3)),
        teacherFeedback: 'Excellent speed improvement!',
        stars: 3,
      ),
      PracticeResult(
        id: 'r3',
        childId: childId,
        title: 'Bead Check',
        topic: 'Subtraction',
        score: 6,
        total: 10,
        accuracy: 0.6,
        avgSpeedSeconds: 8.4,
        date: DateTime.now().subtract(const Duration(days: 5)),
        teacherFeedback: 'Practice friends of 5 again this week.',
        stars: 2,
      ),
    ];
  }

  static List<Certificate> certificatesFor(String childId) {
    return [
      Certificate(
        id: 'cert1',
        title: 'Foundation Starter',
        description: 'Completed Levels 1–2 with consistency.',
        earned: true,
        earnedDate: DateTime.now().subtract(const Duration(days: 40)),
        childId: childId,
      ),
      Certificate(
        id: 'cert2',
        title: 'Streak Champion',
        description: 'Maintained a 10-day practice streak.',
        earned: childId != 'c2',
        earnedDate: childId != 'c2' ? DateTime.now().subtract(const Duration(days: 8)) : null,
        childId: childId,
      ),
      Certificate(
        id: 'cert3',
        title: 'Accuracy Ace',
        description: 'Achieve 90%+ accuracy across a week.',
        earned: childId == 'c3',
        earnedDate: childId == 'c3' ? DateTime.now().subtract(const Duration(days: 12)) : null,
        childId: childId,
      ),
      const Certificate(
        id: 'cert4',
        title: 'Level Master',
        description: 'Finish the current course path.',
        earned: false,
      ),
    ];
  }

  static final List<Announcement> announcements = [
    Announcement(
      id: 'a1',
      title: 'Holiday schedule update',
      body:
          'Centre will be closed next Monday for a public holiday. Practice from home using Daily Drill. Regular classes resume Tuesday.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      priority: AnnouncementPriority.important,
    ),
    Announcement(
      id: 'a2',
      title: 'New worksheets uploaded',
      body: 'Friends of 10 and Column Adds are now available in Worksheets for Aarav and Vihaan.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    Announcement(
      id: 'a3',
      title: 'Parent workshop invite',
      body: 'Join our Saturday workshop on supporting abacus practice at home. 11:00 AM · Online.',
      date: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
    ),
  ];

  static PaymentPlan get currentPlan => PaymentPlan(
    name: 'Family Plus',
    amount: 2499,
    billingCycle: 'Monthly',
    status: PaymentStatus.due,
    nextDueDate: DateTime.now().add(const Duration(days: 4)),
    dueAmount: 2499,
  );

  static final List<PaymentReceipt> receipts = [
    PaymentReceipt(
      id: 'pay1',
      title: 'June tuition',
      amount: 2499,
      date: DateTime.now().subtract(const Duration(days: 28)),
      status: PaymentStatus.paid,
    ),
    PaymentReceipt(
      id: 'pay2',
      title: 'May tuition',
      amount: 2499,
      date: DateTime.now().subtract(const Duration(days: 58)),
      status: PaymentStatus.paid,
    ),
    PaymentReceipt(
      id: 'pay3',
      title: 'April tuition',
      amount: 2499,
      date: DateTime.now().subtract(const Duration(days: 88)),
      status: PaymentStatus.paid,
    ),
  ];

  static PracticeActivity dailyActivity = const PracticeActivity(
    id: 'daily',
    title: 'Daily Drill',
    description: 'A short warm-up to keep skills sharp.',
    estimatedMinutes: 8,
    difficulty: PracticeDifficulty.medium,
    encouragement: 'You are ready. Take your time and trust the beads.',
    questions: [
      PracticeQuestion(
        id: 'q1',
        prompt: 'What is 7 + 5?',
        operands: [7, 5],
        operatorSymbol: '+',
        correctAnswer: 12,
        hint: 'Make 10 first, then add 2.',
      ),
      PracticeQuestion(
        id: 'q2',
        prompt: 'What is 9 + 6?',
        operands: [9, 6],
        operatorSymbol: '+',
        correctAnswer: 15,
      ),
      PracticeQuestion(
        id: 'q3',
        prompt: 'What is 14 − 8?',
        operands: [14, 8],
        operatorSymbol: '−',
        correctAnswer: 6,
      ),
      PracticeQuestion(
        id: 'q4',
        prompt: 'What is 8 + 7?',
        operands: [8, 7],
        operatorSymbol: '+',
        correctAnswer: 15,
      ),
      PracticeQuestion(
        id: 'q5',
        prompt: 'What is 16 − 9?',
        operands: [16, 9],
        operatorSymbol: '−',
        correctAnswer: 7,
      ),
      PracticeQuestion(
        id: 'q6',
        prompt: 'What is 4 + 9?',
        operands: [4, 9],
        operatorSymbol: '+',
        correctAnswer: 13,
      ),
      PracticeQuestion(
        id: 'q7',
        prompt: 'What is 11 + 5?',
        operands: [11, 5],
        operatorSymbol: '+',
        correctAnswer: 16,
      ),
      PracticeQuestion(
        id: 'q8',
        prompt: 'What is 18 − 6?',
        operands: [18, 6],
        operatorSymbol: '−',
        correctAnswer: 12,
      ),
    ],
  );

  static List<WeeklyActivityPoint> weeklyActivity(String childId) {
    final base = childId == 'c3' ? 18 : childId == 'c2' ? 8 : 12;
    return [
      WeeklyActivityPoint(label: 'Mon', minutes: base - 2),
      WeeklyActivityPoint(label: 'Tue', minutes: base + 3),
      WeeklyActivityPoint(label: 'Wed', minutes: base),
      WeeklyActivityPoint(label: 'Thu', minutes: base + 5),
      WeeklyActivityPoint(label: 'Fri', minutes: base - 1),
      WeeklyActivityPoint(label: 'Sat', minutes: base + 8),
      WeeklyActivityPoint(label: 'Sun', minutes: base - 4),
    ];
  }
}
