import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';

import 'package:local_markerplace/login/repository/login_repository.dart';
import 'package:local_markerplace/core/device_identity.dart';
import 'package:local_markerplace/network/api_client.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/logging_interceptor.dart';
import 'package:local_markerplace/network/token_refresh_interceptor.dart';
import 'package:local_markerplace/network/token_store.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

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
  TokenStore? tokenStore,
  OnboardingRepository? onboardingRepository,
}) async {
  final apiClient = APIClient(baseUrl: baseUrl);
  final _loginRepository =
      loginRepository ?? LoginRepository(apiClient: apiClient);
  final _dashboardRepository = dashboardRepository ?? DashboardRepository();
  final _onboardingRepository = onboardingRepository ?? OnboardingRepository();

  // Has to be loaded before anything can refresh or verify — both endpoints
  // take the device id.
  final deviceIdentity = DeviceIdentity();
  await deviceIdentity.load();

  final authSession = AuthSession(
    store: tokenStore ?? SecureTokenStore(),
    repository: _loginRepository,
    deviceIdentity: deviceIdentity,
  );
  // Signs every request once the session holds a token.
  apiClient.addInterceptor(AuthInterceptor(authSession));
  // Renews the 15-minute access token and replays whatever hit the 401.
  apiClient.addInterceptor(
    TokenRefreshInterceptor(session: authSession, dio: apiClient.dio),
  );
  // Added after the auth interceptor so the logged headers include the
  // Authorization the request actually goes out with.
  apiClient.addInterceptor(LoggingInterceptor());

  // Reads the stored refresh token and, if there is one, exchanges it for a
  // live session. Has to finish before the router picks its initial location.
  final bootstrap = await authSession.bootstrap();

  // A restored session still has to have been through onboarding — a user who
  // verified but closed the app mid-setup would otherwise land on a dashboard
  // that knows neither their locality nor what they came for.
  final hasProfile = bootstrap == AuthBootstrapResult.signedIn &&
      await _onboardingRepository.readProfile() != null;

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: _loginRepository),
      RepositoryProvider.value(value: _dashboardRepository),
      RepositoryProvider.value(value: authSession),
      RepositoryProvider.value(value: deviceIdentity),
      RepositoryProvider.value(value: _onboardingRepository),
    ],
    // A refreshed session skips the login screen entirely; a missing or
    // rejected token lands on it.
    child: ServiqApp(
      targetLocation: switch (bootstrap) {
        AuthBootstrapResult.signedIn when hasProfile => AppRoutes.home.path,
        AuthBootstrapResult.signedIn => AppRoutes.onboarding.path,
        _ => AppRoutes.login.path,
      },
    ),
  );
}
