import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

import 'package:local_markerplace/login/repository/login_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ServiqApp extends StatelessWidget {
  final String targetLocation;
  const ServiqApp({super.key, required this.targetLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: targetLocation,
        routes: createRoutes(),
      ),
    );
  }
}

Future<Widget> appBuilder(
  String baseUrl, {
  LoginRepository? loginRepository,
  DashboardRepository? dashboardRepository,
}) async {
  final _loginRepository = loginRepository ?? LoginRepository();
  final _dashboardRepository = dashboardRepository ?? DashboardRepository();

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: _loginRepository),
      RepositoryProvider.value(value: _dashboardRepository),
    ],
    child: ServiqApp(targetLocation: AppRoutes.login.path),
  );
}
