import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/state/app_state.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class MatrixAbacusApp extends StatefulWidget {
  const MatrixAbacusApp({super.key});

  @override
  State<MatrixAbacusApp> createState() => _MatrixAbacusAppState();
}

class _MatrixAbacusAppState extends State<MatrixAbacusApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppState _appState;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _router = AppRouter(_navigatorKey);
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        navigatorKey: _navigatorKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _router.onGenerateRoute,
      ),
    );
  }
}
