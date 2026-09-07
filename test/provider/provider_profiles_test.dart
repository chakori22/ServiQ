import 'package:flutter_test/flutter_test.dart';

import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/provider/repository/provider_repository.dart';

const providers = ProviderRepository();
const directory = DiscoveryRepository();

void main() {
  group('every listed provider has a page of its own', () {
    test('nobody falls back to the flagship profile', () {
      for (final locality in directory.zones().expand(
        (zone) => zone.localities,
      )) {
        for (final summary in directory.providersIn(locality.name)) {
          final profile = providers.forName(summary.name);
          expect(
            profile.name,
            summary.name,
            reason:
                '${summary.name} should not land on somebody else’s '
                'page',
          );
          expect(profile.services, isNotEmpty);
          expect(profile.rating, summary.rating);
          // The two hand-written profiles give a shop address; a derived one
          // says which area it covers.
          expect(
            profile.locationLine,
            anyOf(contains(summary.localityName), contains('Shop')),
          );
        }
      }
    });

    test('the work matches the trade', () {
      final plumber = providers.forName('Verma Plumbing Works');
      final electrician = providers.forName('RK Electricals & Repairs');
      final carpenter = providers.forName('Sharma Carpentry');

      expect(
        plumber.services.map((s) => s.name),
        everyElement(
          anyOf(
            contains('Tap'),
            contains('Drain'),
            contains('Geyser'),
            contains('Flush'),
            contains('Leak'),
            contains('Bathroom'),
          ),
        ),
      );
      expect(
        electrician.services.map((s) => s.name),
        contains(anyOf('Fan Installation', 'Switchboard & Socket Fix')),
      );
      expect(
        carpenter.services.map((s) => s.name),
        everyElement(
          anyOf(
            contains('Furniture'),
            contains('Door'),
            contains('Shelf'),
            contains('Wardrobe'),
            contains('Woodwork'),
          ),
        ),
      );
    });

    test('two providers in one trade are not the same business', () {
      final one = providers.forName('RK Electricals & Repairs');
      final two = providers.forName('Bright Spark Electricals');

      expect(one.name, isNot(two.name));
      // Same trade, so overlapping work — but not the identical list at the
      // identical prices, which is what made every store read the same.
      expect(
        one.services.map((s) => '${s.name} ${s.fromPrice}').toList(),
        isNot(two.services.map((s) => '${s.name} ${s.fromPrice}').toList()),
      );
    });

    test('a store sells what its trade fits', () {
      final appliance = providers.forName('Mascot Appliance Care');
      expect(appliance.products, isNotEmpty);
      expect(
        appliance.products.map((p) => p.name),
        contains(anyOf('Chimney Baffle Filter', 'Fridge Door Gasket')),
      );

      // A plumber does not stock chimney filters.
      final plumber = providers.forName('Verma Plumbing Works');
      expect(
        plumber.products.map((p) => p.name),
        isNot(contains('Chimney Baffle Filter')),
      );
    });

    test('a profile is the same on every visit', () {
      final first = providers.forName('Greens Cleaning Crew');
      final second = providers.forName('Greens Cleaning Crew');
      expect(first, second);
    });
  });

  group('the services catalogue', () {
    test('quotes the same price the provider page does', () {
      const locality = 'Ajnara Gen X';
      for (final service in providers.servicesIn(locality)) {
        final profile = providers.forName(service.providerName);
        final onProfile = profile.services.firstWhere(
          (s) => s.name == service.name,
        );
        expect(
          service.fromPrice,
          onProfile.fromPrice,
          reason: '${service.providerName} quotes ${service.name} twice',
        );
      }
    });

    test('a category shows only that trade, and several providers', () {
      final electrical = providers.servicesIn(
        'Ajnara Gen X',
        categoryLabel: 'Electrician',
      );
      expect(electrical, isNotEmpty);
      expect(
        electrical.map((s) => s.providerName).toSet().length,
        greaterThan(1),
      );
    });
  });
}
