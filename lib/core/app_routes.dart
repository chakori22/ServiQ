import 'package:go_router/go_router.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/instant/instant_form.dart';
import 'package:local_markerplace/dashboard/presentation/dashboard_page.dart';

import 'package:local_markerplace/core/launch_app.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';
import 'package:local_markerplace/dashboard/presentation/services/service_page.dart';
import 'package:local_markerplace/login/presentation/login_page.dart';
import 'package:local_markerplace/splash/splash_screen.dart';

enum AppRoutes {
  launch("/"),
  splash("/splash"),
  login("/login"),
  home("/home"),
  instantForm("/instantForm"),
  services("/services"),
  posts("/posts");

  final String path;
  const AppRoutes(this.path);

  static AppRoutes fromPath(String path) {
    return AppRoutes.values.firstWhere((route) => route.path == path);
  }
}

List<RouteBase> createRoutes() {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.launch.path,
      builder: (context, state) => const LaunchApp(),
      name: AppRoutes.launch.name,
    ),
    GoRoute(
      path: AppRoutes.splash.path,
      builder: (context, state) => const SplashScreen(),
      name: AppRoutes.splash.name,
    ),
    GoRoute(
      path: AppRoutes.login.path,
      builder: (context, state) => const LoginPage(),
      name: AppRoutes.login.name,
    ),
    GoRoute(
      path: AppRoutes.home.path,
      builder: (context, state) => const DashboardPage(),
      name: AppRoutes.home.name,
    ),
    GoRoute(
      path: AppRoutes.instantForm.path,
      builder: (context, state) => const InstantFormPage(),
      name: AppRoutes.instantForm.name,
    ),
    GoRoute(
      path: AppRoutes.services.path,
      builder: (context, state) => const ServicePage(),
      name: AppRoutes.services.name,
    ),
    GoRoute(
      path: AppRoutes.posts.path,
      builder: (context, state) => const PostPage(),
      name: AppRoutes.posts.name,
    ),
  ];
}

extension GoRouterExt on GoRouter {
  void popUntilNamed(AppRoutes routeName) {
    List routeStacks = [...routerDelegate.currentConfiguration.routes];
    final routePath = routeName.path;
    for (int i = routeStacks.length - 1; i >= 0; i--) {
      RouteBase route = routeStacks[i];
      if (route is GoRoute) {
        if (route.name == routePath) break;
        if (i != 0 && routeStacks[i - 1] is ShellRoute) {
          RouteMatchList matchList = routerDelegate.currentConfiguration;
          restore(matchList.remove(matchList.matches.last));
        } else {
          pop();
        }
      }
    }
  }

  void pushAppRoute(AppRoutes routeName, {Object? extra}) {
    pushNamed(routeName.name, extra: extra);
  }
}
