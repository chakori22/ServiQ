import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/repository/home_repository.dart';
import 'package:local_markerplace/network/api_client.dart';

/// Hits the real dev backend, area by area. Tagged so it can be excluded:
/// `flutter test --exclude-tags live`.
///
/// The three cases here are the three answers home has to be able to draw,
/// and they are asserted against the server rather than a fixture so that a
/// change on that side shows up as a failing test instead of a screen that
/// quietly says the wrong thing.
void main() {
  _slugs();

  final repository = HomeRepository(
    apiClient: APIClient(baseUrl: 'http://13.207.78.186:8080'),
  );

  test('galleria-market-1 is live and has a provider', () async {
    final result = await repository.home(localitySlug: 'galleria-market-1');

    result.fold((failure) => fail('expected a feed, got: $failure'), (feed) {
      expect(feed.locality.slug, 'galleria-market-1');
      expect(feed.locality.name, 'Galleria Market 1');
      expect(feed.locality.zoneName, 'Crossing Republik');
      expect(feed.categories, isNotEmpty);
      expect(feed.providersNearYou, isNotEmpty);
      // Home only draws six of them, however many come back.
      expect(feed.categories.length, greaterThanOrEqualTo(6));
    });
  }, tags: 'live');

  test('ajnara-gen-x is live with nobody listed yet', () async {
    final result = await repository.home(localitySlug: 'ajnara-gen-x');

    result.fold((failure) => fail('expected a feed, got: $failure'), (feed) {
      expect(feed.locality.name, 'Ajnara Gen X');
      // The trades are still there — the area is covered, just empty.
      expect(feed.categories, isNotEmpty);
      expect(feed.providersNearYou, isEmpty);
      expect(feed.locality.providerCount, 0);
    });
  }, tags: 'live');

  test('gaur-city-1 is not covered and says so by code', () async {
    final result = await repository.home(localitySlug: 'gaur-city-1');

    result.fold(
      (failure) {
        // The code is what home branches on to show "Coming soon to your
        // neighbourhood" instead of an error.
        expect(failure.errorCode, 'LOCALITY_NOT_FOUND');
      },
      (feed) => fail(
        'expected LOCALITY_NOT_FOUND, got a feed for ${feed.locality.name}',
      ),
    );
  }, tags: 'live');

  test('a display name is slugged on the way out', () async {
    // The endpoint matches the slug exactly: "Ajnara Gen X", "ajnara gen x"
    // and "AJNARA-GEN-X" all answer LOCALITY_NOT_FOUND against it. The
    // repository converts, so the area comes back either way.
    final result = await repository.home(localitySlug: 'Ajnara Gen X');

    result.fold(
      (failure) => fail('expected a feed, got: $failure'),
      (feed) => expect(feed.locality.slug, 'ajnara-gen-x'),
    );
  }, tags: 'live');

  test(
    'an unknown slug is not found rather than silently substituted',
    () async {
      final result = await repository.home(localitySlug: 'not-a-real-place');

      result.fold(
        (failure) => expect(failure.errorCode, 'LOCALITY_NOT_FOUND'),
        (feed) =>
            fail('expected LOCALITY_NOT_FOUND, got ${feed.locality.slug}'),
      );
    },
    tags: 'live',
  );
}

/// The conversion on its own — the part that stops a display name reaching
/// the endpoint as one. No network, so it runs in the ordinary suite.
void _slugs() {
  test('slugFor lowercases and hyphenates the way the endpoint wants', () {
    expect(HomeRepository.slugFor('Ajnara Gen X'), 'ajnara-gen-x');
    expect(HomeRepository.slugFor('  Galleria Market 1 '), 'galleria-market-1');
    expect(HomeRepository.slugFor('Cloud 9 Towers'), 'cloud-9-towers');
    expect(HomeRepository.slugFor('AJNARA-GEN-X'), 'ajnara-gen-x');
    // Already a slug, so untouched.
    expect(HomeRepository.slugFor('ajnara-gen-x'), 'ajnara-gen-x');
    expect(HomeRepository.slugFor(''), '');
  });
}
