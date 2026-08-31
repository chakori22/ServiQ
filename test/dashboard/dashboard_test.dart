import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/core/app_routes.dart';
import 'package:local_markerplace/dashboard/presentation/components/dashboard_shimmer.dart';
import 'package:local_markerplace/dashboard/presentation/components/service_card.dart';
import 'package:local_markerplace/dashboard/presentation/services/service_page.dart';

Widget _app() => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.home.path,
        routes: createRoutes(),
      ),
    );

void main() {
  testWidgets('dashboard shows shimmer while loading, then real cards',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ServiceCardsShimmer), findsOneWidget);
    expect(find.byType(PostCardsShimmer), findsOneWidget);
    expect(find.byType(YourPostCardsShimmer), findsOneWidget);
    expect(find.byType(ServiceCard), findsNothing);

    // Repository stubs resolve after ~1s.
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(ServiceCardsShimmer), findsNothing);
    expect(find.byType(PostCardsShimmer), findsNothing);
    expect(find.byType(YourPostCardsShimmer), findsNothing);
    expect(find.byType(ServiceCard), findsWidgets);
  });

  testWidgets('View All on Services opens ServicePage without a provider error',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(seconds: 2));

    final header = find
        .ancestor(of: find.text('Services Near Me'), matching: find.byType(Row))
        .first;
    final viewAll =
        find.descendant(of: header, matching: find.byType(TextButton));
    expect(viewAll, findsOneWidget);

    await tester.tap(viewAll);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byType(ServicePage), findsOneWidget);
    expect(find.byType(ServiceCard), findsWidgets);
  });

  testWidgets('deep link to /services stands up its own bloc and loads',
      (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.services.path,
        routes: createRoutes(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ServiceGridShimmerTile), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(find.byType(ServiceCard), findsWidgets);
  });
}
