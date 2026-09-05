import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/network/failure.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
import 'package:local_markerplace/onboarding/presentation/onboarding_page.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

/// Captures what the flow saves without touching the keychain, which is not
/// available under `flutter test`.
class _RecordingRepository implements OnboardingRepository {
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

void main() {
  late _RecordingRepository repository;

  // A real router, because leaving the flow navigates to discovery — with a
  // stub destination so the test does not drag the whole flow in.
  Widget harness() => RepositoryProvider<OnboardingRepository>.value(
    value: repository,
    child: MaterialApp.router(
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

  setUp(() => repository = _RecordingRepository());

  /// The default 800x600 test surface is shorter than a phone, which pushes
  /// each step's button off-screen and out of reach of tap().
  Future<void> pumpFlow(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness());
  }

  testWidgets('walks the three steps and saves what was entered', (
    tester,
  ) async {
    await pumpFlow(tester);

    // Step 1 — categories. The button carries the requirement until one is
    // picked.
    expect(find.text('What do you usually need help with?'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text('Pick at least one'), findsOneWidget);

    await tester.tap(find.text('Electrical'));
    await tester.tap(find.text('Cleaning'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2 — name and locality on one screen.
    expect(find.text('A little about you'), findsOneWidget);
    expect(find.text('STEP 2 OF 3'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField).first, 'Priya Sharma');
    await tester.enterText(find.byType(TextField).last, 'Ajnara Gen X');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and continue'));
    await tester.pumpAndSettle();

    // Saving happens before the closing screen, not on the way out.
    expect(repository.saved, isNotNull);
    expect(repository.saved!.fullName, 'Priya Sharma');
    expect(repository.saved!.locality, 'Ajnara Gen X');
    expect(repository.saved!.interestIds, {'electrical', 'cleaning'});

    // Step 3 — reads the answers back.
    expect(find.text("You're all set"), findsOneWidget);
    expect(find.text('STEP 3 OF 3'), findsOneWidget);
    expect(
      find.text(
        'Showing electrical and cleaning providers in Ajnara Gen X '
        'first.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Start browsing'));
    await tester.pumpAndSettle();
    expect(find.text('discovery'), findsOneWidget);
  });

  testWidgets('stepping back keeps what was already entered', (tester) async {
    await pumpFlow(tester);

    await tester.tap(find.text('Plumbing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Priya Sharma');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
    await tester.pumpAndSettle();
    // Back on the grid, with the earlier choice still selected.
    expect(find.text('What do you usually need help with?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Priya Sharma'), findsOneWidget);
  });

  testWidgets('the closing line keeps acronyms cased correctly', (
    tester,
  ) async {
    await pumpFlow(tester);

    await tester.tap(find.text('AC & RO'));
    await tester.tap(find.text('Cleaning'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Priya Sharma');
    await tester.enterText(find.byType(TextField).last, 'Ajnara Gen X');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and continue'));
    await tester.pumpAndSettle();

    // "AC & RO" must survive the sentence, not arrive as "ac & ro".
    expect(
      find.text(
        'Showing cleaning and AC & RO providers in Ajnara Gen X '
        'first.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Skip leaves for discovery without saving', (tester) async {
    await pumpFlow(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('discovery'), findsOneWidget);
    expect(repository.saved, isNull);
  });
}
