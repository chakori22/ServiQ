import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:local_markerplace/dashboard/presentation/components/account_menu.dart';
import 'package:local_markerplace/network/auth_session.dart';
import 'package:local_markerplace/network/failure.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

import 'support/fakes.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  bool cleared = false;

  @override
  Future<void> clear() async => cleared = true;

  @override
  Future<SeekerProfile?> readProfile() async => null;

  @override
  Future<Either<Failure, Unit>> saveProfile(SeekerProfile profile) async =>
      const Right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeLoginRepository loginRepository;
  late FakePersistentStore store;
  late AuthSession session;
  late _FakeOnboardingRepository onboarding;

  setUp(() async {
    loginRepository = FakeLoginRepository();
    store = FakePersistentStore();
    onboarding = _FakeOnboardingRepository();
    session = AuthSession(
      store: store,
      repository: loginRepository,
      deviceIdentity: FakeDeviceIdentity(),
    );
    await session.save(
      tokens: testTokens(accessToken: 'a1', refreshToken: 'r1'),
      user: testUser,
    );
  });

  Widget harness() => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AuthSession>.value(value: session),
      RepositoryProvider<OnboardingRepository>.value(value: onboarding),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, _) => const Scaffold(
              body: Center(child: AccountMenuButton()),
            ),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            builder: (_, _) => const Scaffold(body: Text('login screen')),
          ),
        ],
      ),
    ),
  );

  Future<void> openLogoutDialog(WidgetTester tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
  }

  testWidgets('the dialog asks for confirmation before signing out', (
    tester,
  ) async {
    await openLogoutDialog(tester);

    expect(
      find.textContaining('Are you sure you want to logout?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    // Nothing has happened yet — asking is not doing.
    expect(loginRepository.logoutCalls, isEmpty);
    expect(session.isAuthenticated, isTrue);
  });

  testWidgets('Cancel leaves the session alone', (tester) async {
    await openLogoutDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(loginRepository.logoutCalls, isEmpty);
    expect(session.isAuthenticated, isTrue);
    expect(find.text('login screen'), findsNothing);
  });

  testWidgets('the spinner shows in the dialog, not on the header icon', (
    tester,
  ) async {
    // Holds the logout call open so the in-flight frame can be inspected.
    final gate = Completer<void>();
    loginRepository.gate = gate.future;

    await openLogoutDialog(tester);
    await tester.tap(find.text('Log out').last);
    await tester.pump();

    // The waiting is on the control that was pressed...
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    // ...and the header icon is untouched, still a person icon.
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(loginRepository.logoutCalls, ['r1']);
    expect(onboarding.cleared, isTrue);
    expect(find.text('login screen'), findsOneWidget);
  });
}
