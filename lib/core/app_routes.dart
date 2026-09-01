import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/cart/presentation/cart_page.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/model/services.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/instant/instant_form.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/schedule/schedule_form.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/dashboard/presentation/dashboard_page.dart';

import 'package:local_markerplace/core/launch_app.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';
import 'package:local_markerplace/dashboard/presentation/services/service_page.dart';
import 'package:local_markerplace/dashboard/presentation/your_post/presentation/your_post.dart';
import 'package:local_markerplace/login/presentation/login_page.dart';
import 'package:local_markerplace/splash/splash_screen.dart';

enum AppRoutes {
  launch("/"),
  splash("/splash"),
  login("/login"),
  home("/home"),
  instantForm("/instantForm"),
  scheduleForm("/scheduleForm"),
  services("/services"),
  posts("/posts"),
  yourPosts("/yourPosts"),
  cart("/cart");

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
      path: AppRoutes.scheduleForm.path,
      builder: (context, state) => const ScheduleFormPage(),
      name: AppRoutes.scheduleForm.name,
    ),
    GoRoute(
      path: AppRoutes.services.path,
      // ServicePage reads the DashboardBloc, but this route is built by the
      // root navigator — outside DashboardPage's provider. The dashboard hands
      // its bloc over via `extra` so service selections stay in sync with the
      // home rail and the cart bar. A deep link arrives without one, so fall
      // back to a fresh bloc that loads the services itself.
      builder: (context, state) {
        final dashboardBloc = state.extra;
        if (dashboardBloc is DashboardBloc) {
          return BlocProvider.value(
            value: dashboardBloc,
            child: const ServicePage(),
          );
        }
        return BlocProvider(
          create: (_) =>
              DashboardBloc(dashboardRepository: const DashboardRepository())
                ..add(const OnFetchServiceDetails()),
          child: const ServicePage(),
        );
      },
      name: AppRoutes.services.name,
    ),
    GoRoute(
      path: AppRoutes.posts.path,
      // Reached either from the home rail, with nothing extra, or straight
      // from a create-post form, which hands over the post the user just
      // shared so this page can run the upload and show its progress.
      builder: (context, state) {
        final extra = state.extra;
        return PostPage(uploadingDraft: extra is PostDraft ? extra : null);
      },
      name: AppRoutes.posts.name,
    ),
    GoRoute(
      path: AppRoutes.yourPosts.path,
      builder: (context, state) => const YourPostPage(),
      name: AppRoutes.yourPosts.name,
    ),
    GoRoute(
      path: AppRoutes.cart.path,
      // The services picked on the dashboard travel here as `extra`; the cart
      // prices them itself rather than reading the dashboard's bloc, so it
      // stays usable from anywhere that can name a list of services.
      builder: (context, state) {
        final extra = state.extra;
        return CartPage(
          services: extra is List<ServiceDetails> ? extra : const [],
        );
      },
      name: AppRoutes.cart.name,
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

  /// Swaps the current screen for [routeName] instead of stacking on top of
  /// it — used when leaving a form the user should not come back to, so Back
  /// returns to whatever opened the form.
  void pushReplacementAppRoute(AppRoutes routeName, {Object? extra}) {
    pushReplacementNamed(routeName.name, extra: extra);
  }
}
