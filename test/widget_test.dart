import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matrix_abacus/app/app.dart';
import 'package:matrix_abacus/core/constants/app_constants.dart';

String generatedOtp(WidgetTester tester) {
  final label = tester.widget<Text>(find.textContaining('Development OTP:'));
  final match = RegExp(
    r'Development OTP: (\d{6})',
  ).firstMatch(label.data ?? '');
  return match!.group(1)!;
}

void main() {
  testWidgets('App launches splash then welcome', (tester) async {
    await tester.pumpWidget(const MatrixAbacusApp());
    expect(find.text(AppConstants.appName), findsWidgets);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Mock login reaches parent shell', (tester) async {
    await tester.pumpWidget(const MatrixAbacusApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), generatedOtp(tester));
    await tester.tap(find.text('Verify & continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.textContaining('Priya'), findsWidgets);
    expect(find.text('Selected'), findsWidgets);
  });

  testWidgets('Bottom navigation reaches Progress and Worksheets', (
    tester,
  ) async {
    await tester.pumpWidget(const MatrixAbacusApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), generatedOtp(tester));
    await tester.tap(find.text('Verify & continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Overall progress'), findsWidgets);

    await tester.tap(find.text('Worksheets'));
    await tester.pumpAndSettle();
    expect(find.text('Worksheets'), findsWidgets);
  });

  testWidgets('Admin login reaches the admin dashboard', (tester) async {
    await tester.pumpWidget(const MatrixAbacusApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '9999999999');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), generatedOtp(tester));
    await tester.tap(find.text('Verify & continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Admin dashboard'), findsOneWidget);
    expect(find.text('Manage courses and levels'), findsOneWidget);
  });
}
