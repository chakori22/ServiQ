import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/presentation/discovery_shell.dart';
import 'package:local_markerplace/network/failure.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
import 'package:local_markerplace/onboarding/repository/onboarding_repository.dart';

/// Stands in for the keychain, which `flutter test` has no access to.
class _FakeProfiles implements OnboardingRepository {
  _FakeProfiles([this.saved]);

  SeekerProfile? saved;
  int writes = 0;

  @override
  Future<Either<Failure, Unit>> saveProfile(SeekerProfile profile) async {
    saved = profile;
    writes++;
    return const Right(unit);
  }

  @override
  Future<SeekerProfile?> readProfile() async => saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> loadFonts() async {
  for (final path in const [
    'assets/fonts/PlusJakartaSans-Medium.ttf',
    'assets/fonts/PlusJakartaSans-Bold.ttf',
    'assets/fonts/PlusJakartaSans-ExtraBold.ttf',
  ]) {
    final loader = FontLoader('Plus Jakarta Sans')
      ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
  }
}

void main() {
  setUpAll(loadFonts);

  Future<void> pumpShell(WidgetTester tester, _FakeProfiles profiles) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DiscoveryShell(profiles: profiles),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a seeker who finished onboarding lands straight on their area', (
    tester,
  ) async {
    final profiles = _FakeProfiles(
      const SeekerProfile(
        fullName: 'Asha',
        locality: 'Mahagun Mascot',
        interestIds: {'electrical'},
      ),
    );

    await pumpShell(tester, profiles);

    // Home, on their area — the picker never appears.
    expect(find.text('What do you need done?'), findsOneWidget);
    expect(find.text('Mahagun Mascot'), findsOneWidget);
    expect(find.text('Where do you need help?'), findsNothing);
  });

  testWidgets('a seeker who skipped onboarding is asked for an area', (
    tester,
  ) async {
    // Skipping saves nothing at all.
    await pumpShell(tester, _FakeProfiles());

    expect(find.text('Where do you need help?'), findsOneWidget);
  });

  testWidgets('a profile saved without an area still reaches the picker', (
    tester,
  ) async {
    // Onboarding can be completed with the locality field left empty.
    final profiles = _FakeProfiles(const SeekerProfile(fullName: 'Asha'));

    await pumpShell(tester, profiles);

    expect(find.text('Where do you need help?'), findsOneWidget);
  });

  testWidgets('changing area in discovery is remembered for the next launch', (
    tester,
  ) async {
    final profiles = _FakeProfiles(
      const SeekerProfile(fullName: 'Asha', locality: 'Ajnara Gen X'),
    );

    await pumpShell(tester, profiles);
    expect(find.text('Ajnara Gen X'), findsOneWidget);

    // Reopen the picker from the header and choose somewhere else.
    await tester.tap(find.text('Ajnara Gen X'));
    await tester.pumpAndSettle();
    expect(find.text('Where do you need help?'), findsOneWidget);

    await tester.tap(find.text('Mahagun Mascot'));
    await tester.pumpAndSettle();

    expect(find.text('Mahagun Mascot'), findsOneWidget);
    expect(profiles.saved?.locality, 'Mahagun Mascot');
    // The rest of the profile survives the write.
    expect(profiles.saved?.fullName, 'Asha');
  });

  testWidgets('picking the area already on file does not rewrite it', (
    tester,
  ) async {
    final profiles = _FakeProfiles(
      const SeekerProfile(fullName: 'Asha', locality: 'Ajnara Gen X'),
    );

    await pumpShell(tester, profiles);
    await tester.tap(find.text('Ajnara Gen X'));
    await tester.pumpAndSettle();
    // The row inside the picker's card, not the header behind it.
    await tester.tap(find.text('Ajnara Gen X').last);
    await tester.pumpAndSettle();

    expect(profiles.writes, 0);
  });
}
