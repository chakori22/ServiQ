import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/cart/presentation/cart_page.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/model/post_draft.dart';
import 'package:local_markerplace/dashboard/model/services.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/instant/instant_form.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/schedule/schedule_form.dart';
import 'package:local_markerplace/dashboard/repository/dashboard_repository.dart';
import 'package:local_markerplace/dashboard/presentation/dashboard_page.dart';
import 'package:local_markerplace/discovery/presentation/discovery_shell.dart';
import 'package:local_markerplace/discovery/repository/home_repository.dart';

import 'package:local_markerplace/core/launch_app.dart';
import 'package:local_markerplace/dashboard/presentation/posts/presentation/post_screen.dart';
import 'package:local_markerplace/dashboard/presentation/services/service_page.dart';
import 'package:local_markerplace/dashboard/presentation/your_post/presentation/your_post.dart';
import 'package:local_markerplace/login/presentation/login_page.dart';
import 'package:local_markerplace/login/presentation/verified_page.dart';
import 'package:local_markerplace/onboarding/presentation/onboarding_page.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';
import 'package:local_markerplace/splash/splash_screen.dart';

enum AppRoutes {
  launch("/"),
  splash("/splash"),
  login("/login"),
  verified("/verified"),
  onboarding("/onboarding"),
  home("/home"),
  instantForm("/instantForm"),
  scheduleForm("/scheduleForm"),
  services("/services"),
  posts("/posts"),
  yourPosts("/yourPosts"),
  cart("/cart"),
  discovery("/discovery");

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
      path: AppRoutes.verified.path,
      builder: (context, state) => const VerifiedPage(),
      name: AppRoutes.verified.name,
    ),
    GoRoute(
      path: AppRoutes.onboarding.path,
      builder: (context, state) => const OnboardingPage(),
      name: AppRoutes.onboarding.name,
    ),
    GoRoute(
      path: AppRoutes.home.path,
      builder: (context, state) => const DashboardPage(),
      name: AppRoutes.home.name,
    ),
    GoRoute(
      path: AppRoutes.instantForm.path,
      // The area travels so a posted requirement lands back on its own
      // board rather than on a nameless one.
      builder: (context, state) {
        final extra = state.extra;
        return InstantFormPage(localityName: extra is String ? extra : null);
      },
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
      // Everything the board can be opened with travels in one [PostsArgs]:
      // a freshly shared post to upload, the area it belongs to, and which
      // chip to open on. A deep link arrives with none of them.
      builder: (context, state) {
        final args = switch (state.extra) {
          final PostsArgs args => args,
          // A draft on its own still has to upload. The board used to drop
          // anything that was not a PostsArgs, which meant a form posting
          // the older shape lost its progress banner silently.
          final PostDraft draft => PostsArgs(draft: draft),
          _ => const PostsArgs(),
        };
        return PostPage(
          uploadingDraft: args.draft,
          localityName: args.localityName,
          initialFilter: args.initialFilter,
        );
      },
      name: AppRoutes.posts.name,
    ),
    GoRoute(
      path: AppRoutes.yourPosts.path,
      builder: (context, state) => const YourPostPage(),
      name: AppRoutes.yourPosts.name,
    ),
    GoRoute(
      path: AppRoutes.discovery.path,
      // The discovery flow keeps its own navigator stack for the drill-downs
      // (zone → locality → search), so only its shell needs a route. An area
      // name handed over as `extra` opens straight onto that area; without
      // one the shell reads the area onboarding recorded, and asks only if
      // there is none.
      builder: (context, state) {
        final extra = state.extra;
        return DiscoveryShell(
          initialLocality: extra is String ? extra : null,
          profiles: context.read<OnboardingRepository>(),
          homeRepository: context.read<HomeRepository>(),
        );
      },
      name: AppRoutes.discovery.name,
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

  /// Pushes [routeName], and hands back whatever the pushed screen pops
  /// with. The posts board uses that to tell discovery which tab to show
  /// when its tab bar is used to leave.
  Future<T?> pushAppRoute<T extends Object?>(
    AppRoutes routeName, {
    Object? extra,
  }) {
    return pushNamed<T>(routeName.name, extra: extra);
  }

  /// Replaces the whole stack with [routeName]. Used after sign-in and
  /// sign-out, where every screen behind the new one is no longer reachable.
  void goAppRoute(AppRoutes routeName, {Object? extra}) {
    goNamed(routeName.name, extra: extra);
  }

  /// Swaps the current screen for [routeName] instead of stacking on top of
  /// it — used when leaving a form the user should not come back to, so Back
  /// returns to whatever opened the form.
  void pushReplacementAppRoute(AppRoutes routeName, {Object? extra}) {
    pushReplacementNamed(routeName.name, extra: extra);
  }
}
