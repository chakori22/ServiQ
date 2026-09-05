import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:local_markerplace/network/failure.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
import 'package:local_markerplace/onboarding/presentation/onboarding_page.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

class _Profiles implements OnboardingRepository {
  SeekerProfile? saved;

  @override
  Future<Either<Failure, Unit>> saveProfile(SeekerProfile profile) async {
    saved = profile;
    return const Right(unit);
  }

  @override
  Future<SeekerProfile?> readProfile() async => saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// One handset onboarding has to fit.
class Device {
  const Device(this.name, this.size);

  final String name;
  final Size size;

  @override
  String toString() => '$name (${size.width.toInt()}x${size.height.toInt()})';
}

/// The narrow end is what matters here: the category grid sized its cells
/// from their width, so the labels overflowed the moment a cell got short.
const devices = <Device>[
  Device('iPhone SE 1st gen', Size(320, 568)),
  Device('Android baseline', Size(360, 640)),
  Device('iPhone SE 3rd gen', Size(375, 667)),
  Device('iPhone 14', Size(390, 844)),
  Device('Pixel 7', Size(412, 915)),
];

void main() {
  late _Profiles repository;

  setUp(() => repository = _Profiles());

  Widget harness() => RepositoryProvider<OnboardingRepository>.value(
    value: repository,
    child: MaterialApp.router(
      builder: (context, child) => child!,
      routerConfig: GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            name: 'onboarding',
            builder: (_, _) => const OnboardingPage(),
          ),
          GoRoute(
            path: '/discovery',
            name: 'discovery',
            builder: (_, _) => const Scaffold(body: Text('discovery')),
          ),
        ],
      ),
    ),
  );

  Future<void> pumpAt(
    WidgetTester tester,
    Device device, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = device.size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
  }

  for (final device in devices) {
    testWidgets('the category grid fits on $device', (tester) async {
      await pumpAt(tester, device);

      expect(find.text('What do you usually need help with?'), findsOneWidget);
      // Every label has to be laid out, not clipped off the bottom of its
      // cell — the failure this guards was a 2.9pt overflow on each of the
      // nine tiles.
      expect(find.text('Pest control'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scale in const [1.15, 1.3]) {
    testWidgets('the category grid fits at ${scale}x text', (tester) async {
      await pumpAt(tester, devices.first, textScale: scale);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the details step fits on the narrowest phone', (tester) async {
    await pumpAt(tester, devices.first);

    await tester.tap(find.text('Electrical'));
    await tester.pumpAndSettle();

    // On a 568pt-tall screen the button sits below the fold, so the step has
    // to be scrollable to reach it — which is itself worth asserting.
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('A little about you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
