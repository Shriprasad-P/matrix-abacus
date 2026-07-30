import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/repositories/matrix_repository.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../core/state/app_state.dart';
import '../features/announcements/announcements_screen.dart';
import '../features/attendance/attendance_screen.dart';
import '../features/authentication/account_loading_screen.dart';
import '../features/authentication/child_setup_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/otp_screen.dart';
import '../features/authentication/parent_setup_screen.dart';
import '../features/certificates/certificates_screen.dart';
import '../features/children/child_profile_screen.dart';
import '../features/courses/courses_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/payments/payments_screen.dart';
import '../features/practice/practice_complete_screen.dart';
import '../features/practice/practice_intro_screen.dart';
import '../features/practice/practice_pause_screen.dart';
import '../features/practice/practice_question_screen.dart';
import '../features/results/results_screen.dart';
import '../features/settings/more_screen.dart';
import '../features/shell/parent_shell.dart';
import '../features/worksheets/worksheets_screen.dart';

class AppRouter {
  AppRouter(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState get _nav => navigatorKey.currentState!;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(
          SplashScreen(
            onFinished: () => _nav.pushReplacementNamed(AppRoutes.welcome),
          ),
          settings,
        );
      case AppRoutes.welcome:
        return _page(
          WelcomeScreen(
            onGetStarted: () =>
                _nav.pushNamed(AppRoutes.login, arguments: true),
            onLogin: () => _nav.pushNamed(AppRoutes.login, arguments: false),
          ),
          settings,
        );
      case AppRoutes.login:
        final firstTime = settings.arguments as bool? ?? false;
        return _page(
          LoginScreen(
            onContinue: (mobile) async {
              final challenge = await AppState.read(
                _nav.context,
              ).requestOtp(mobile);
              _nav.pushNamed(
                AppRoutes.otp,
                arguments: {
                  'mobile': mobile,
                  'firstTime': firstTime,
                  'challenge': challenge,
                },
              );
            },
          ),
          settings,
        );
      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final mobile = args['mobile'] as String? ?? '';
        final firstTime = args['firstTime'] as bool? ?? false;
        final challenge = args['challenge'] as OtpChallenge;
        return _page(
          OtpScreen(
            mobile: mobile,
            challenge: challenge,
            onVerified: () => _nav.pushReplacementNamed(
              AppRoutes.accountLoading,
              arguments: {'firstTime': firstTime, 'mobile': mobile},
            ),
          ),
          settings,
        );
      case AppRoutes.accountLoading:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final firstTime = args['firstTime'] as bool? ?? false;
        final mobile = args['mobile'] as String? ?? '';
        return _page(
          AccountLoadingScreen(
            firstTime: firstTime,
            mobile: mobile,
            onReady: () {
              final state = AppState.read(_nav.context);
              if (state.isAdmin) {
                _nav.pushNamedAndRemoveUntil(
                  AppRoutes.adminDashboard,
                  (_) => false,
                );
              } else if (firstTime ||
                  state.parent?.name.trim().isEmpty == true) {
                _nav.pushReplacementNamed(AppRoutes.parentSetup);
              } else if (state.children.isEmpty) {
                _nav.pushReplacementNamed(AppRoutes.childSetup);
              } else {
                _nav.pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
              }
            },
          ),
          settings,
        );
      case AppRoutes.parentSetup:
        return _page(
          ParentSetupScreen(
            onDone: () => _nav.pushReplacementNamed(AppRoutes.childSetup),
          ),
          settings,
        );
      case AppRoutes.childSetup:
        return _page(
          ChildSetupScreen(
            onDone: () {
              if (_nav.canPop()) {
                _nav.pop();
              }
              _nav.pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
            },
          ),
          settings,
        );
      case AppRoutes.shell:
        return _page(_buildShell(), settings);
      case AppRoutes.adminDashboard:
        return _page(
          AdminDashboardScreen(
            onLogout: () {
              AppState.read(_nav.context).logout();
              _nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
            },
          ),
          settings,
        );
      case AppRoutes.childProfile:
        return _page(
          ChildProfileScreen(
            onAddChild: () => _nav.pushNamed(AppRoutes.childSetup),
          ),
          settings,
        );
      case AppRoutes.attendance:
        return _page(const AttendanceScreen(), settings);
      case AppRoutes.courses:
        return _page(const CoursesScreen(), settings);
      case AppRoutes.worksheetDetails:
        final id = settings.arguments as String? ?? '';
        return _page(WorksheetDetailsScreen(worksheetId: id), settings);
      case AppRoutes.results:
        return _page(const ResultsScreen(), settings);
      case AppRoutes.certificates:
        return _page(
          CertificatesScreen(
            onOpenCertificate: (id) =>
                _nav.pushNamed(AppRoutes.certificateDetails, arguments: id),
          ),
          settings,
        );
      case AppRoutes.certificateDetails:
        final id = settings.arguments as String? ?? '';
        return _page(CertificateDetailsScreen(certificateId: id), settings);
      case AppRoutes.announcements:
        return _page(
          AnnouncementsScreen(
            onOpenAnnouncement: (id) =>
                _nav.pushNamed(AppRoutes.announcementDetails, arguments: id),
          ),
          settings,
        );
      case AppRoutes.announcementDetails:
        final id = settings.arguments as String? ?? '';
        return _page(AnnouncementDetailsScreen(announcementId: id), settings);
      case AppRoutes.payments:
        return _page(
          PaymentsScreen(
            onPaymentSuccess: () => _nav.pushNamed(AppRoutes.paymentSuccess),
          ),
          settings,
        );
      case AppRoutes.paymentSuccess:
        return _page(PaymentSuccessScreen(onDone: () => _nav.pop()), settings);
      case AppRoutes.settings:
        return _page(
          SettingsScreen(
            onPrivacy: () => _nav.pushNamed(AppRoutes.privacy),
            onTerms: () => _nav.pushNamed(AppRoutes.terms),
            onHelp: () => _nav.pushNamed(AppRoutes.help),
            onLogout: () {
              AppState.read(_nav.context).logout();
              _nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
            },
          ),
          settings,
        );
      case AppRoutes.privacy:
        return _page(
          const SimpleInfoScreen(
            title: 'Privacy policy',
            body:
                'Matrix Abacus respects family privacy. This prototype stores no personal data on a server. In production, parent and child learning data would be processed according to applicable education and privacy regulations.',
          ),
          settings,
        );
      case AppRoutes.terms:
        return _page(
          const SimpleInfoScreen(
            title: 'Terms and conditions',
            body:
                'This application is a UI/UX prototype. Features such as payments, authentication, and notifications are simulated and do not create binding transactions.',
          ),
          settings,
        );
      case AppRoutes.help:
        return _page(
          const SimpleInfoScreen(
            title: 'Help and support',
            body:
                'Need help? In production this would connect to support chat or email. For this prototype, explore screens from Home and More.',
          ),
          settings,
        );
      case AppRoutes.practiceIntro:
        return _page(
          PracticeIntroScreen(
            onStart: () =>
                _nav.pushReplacementNamed(AppRoutes.practiceQuestion),
          ),
          settings,
        );
      case AppRoutes.practiceQuestion:
        return _page(
          PracticeQuestionScreen(
            onPaused: () => _nav.pushNamed(AppRoutes.practicePause),
            onCompleted: () =>
                _nav.pushReplacementNamed(AppRoutes.practiceComplete),
          ),
          settings,
        );
      case AppRoutes.practicePause:
        return _page(
          PracticePauseScreen(
            onResume: () => _nav.pop(),
            onRestart: () =>
                _nav.pushReplacementNamed(AppRoutes.practiceQuestion),
            onExit: () =>
                _nav.pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false),
          ),
          settings,
        );
      case AppRoutes.practiceComplete:
        return _page(
          PracticeCompleteScreen(
            onPracticeAgain: () =>
                _nav.pushReplacementNamed(AppRoutes.practiceQuestion),
            onReturnHome: () =>
                _nav.pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false),
          ),
          settings,
        );
      default:
        return _page(
          Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  Widget _buildShell() {
    return ParentShell(
      onOpenPractice: () => _nav.pushNamed(AppRoutes.practiceIntro),
      onOpenAttendance: () => _nav.pushNamed(AppRoutes.attendance),
      onOpenCourses: () => _nav.pushNamed(AppRoutes.courses),
      onOpenResults: () => _nav.pushNamed(AppRoutes.results),
      onOpenCertificates: () => _nav.pushNamed(AppRoutes.certificates),
      onOpenAnnouncements: () => _nav.pushNamed(AppRoutes.announcements),
      onOpenPayments: () => _nav.pushNamed(AppRoutes.payments),
      onOpenSettings: () => _nav.pushNamed(AppRoutes.settings),
      onOpenChildProfile: () => _nav.pushNamed(AppRoutes.childProfile),
      onOpenWorksheet: (id) =>
          _nav.pushNamed(AppRoutes.worksheetDetails, arguments: id),
      onOpenAnnouncement: (id) =>
          _nav.pushNamed(AppRoutes.announcementDetails, arguments: id),
      onAddChild: () => _nav.pushNamed(AppRoutes.childSetup),
    );
  }

  MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
