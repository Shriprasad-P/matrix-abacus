import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matrix_abacus/app/app.dart';
import 'package:matrix_abacus/core/constants/app_constants.dart';

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

    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Verify & continue'));
    await tester.pump(); // start loading
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.textContaining('Priya'), findsWidgets);
  });
}
