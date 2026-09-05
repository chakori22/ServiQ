import 'package:local_markerplace/provider/model/provider_profile.dart';
import 'package:local_markerplace/provider/model/provider_review.dart';
import 'package:local_markerplace/provider/model/provider_service.dart';
import 'package:local_markerplace/provider/model/store_product.dart';

/// Profiles for the provider page.
///
/// Seed data drawn from the design, same as the discovery catalogue: there is
/// no provider endpoint yet, so the page reads from here and only this class
/// changes when one lands.
class ProviderRepository {
  const ProviderRepository();

  static const _visitCharge = 'Visit charge ₹99, waived on booking';

  static const _shahnaz = ProviderProfile(
    name: 'Shahnaz RO & Chimney Services',
    badge: ProviderBadge.verified,
    since: 'since May 2026',
    locationLine: 'Shop 46, Crossings Republik Rd',
    rating: 4.6,
    reviewCount: 128,
    ratingBreakdown: [0.72, 0.18, 0.06, 0.02, 0.02],
    about:
        'RO and chimney specialists working across Crossings Republik since '
        '2026. Same-day visits for most jobs.',
    address: 'Shop 46, Crossings Republik Rd,\nGhaziabad 201016',
    hours: 'Mon–Sat · 09:00 – 19:00\nSunday closed',
    serves: 'Ajnara Gen X, Mahagun Mascot,\nPanchsheel Wellington',
    services: [
      ProviderService(
        name: 'AC Servicing',
        fromPrice: 'from ₹499',
        detail: 'Split & window, gas top-up extra',
      ),
      ProviderService(
        name: 'Chimney Deep Clean',
        fromPrice: 'from ₹899',
        detail: 'Filter, motor and duct',
      ),
      ProviderService(
        name: 'RO Filter Change',
        fromPrice: 'from ₹349',
        detail: 'Sediment, carbon and membrane',
      ),
      ProviderService(
        name: 'Water Purifier AMC',
        fromPrice: 'from ₹1,999',
        detail: 'Two visits a year, parts at cost',
      ),
    ],
    products: [
      StoreProduct(
        name: 'RO Filter Set (3 stage)',
        price: '₹1,200',
        stockLabel: 'In stock',
      ),
      StoreProduct(
        name: 'RO Membrane 80 GPD',
        price: '₹1,800',
        stockLabel: 'In stock',
      ),
      StoreProduct(
        name: 'Chimney Baffle Filter',
        price: '₹890',
        stockLabel: 'Only 2 left',
        isLow: true,
      ),
      StoreProduct(
        name: 'Sediment Filter 10"',
        price: '₹350',
        stockLabel: 'In stock',
      ),
      StoreProduct(
        name: 'Carbon Filter Block',
        price: '₹450',
        stockLabel: 'In stock',
      ),
      StoreProduct(
        name: 'Chimney Motor (1200 m³/hr)',
        price: '₹3,400',
        stockLabel: 'In stock',
      ),
    ],
    reviews: [
      ProviderReview(
        author: 'Anita Sharma',
        rating: 5,
        age: '2 weeks ago',
        body:
            'Came the same day and fixed the chimney motor. Fair price, no '
            'upselling.',
      ),
      ProviderReview(
        author: 'Rohit Verma',
        rating: 4,
        age: 'last month',
        body: 'Good work on the AC service. Arrived about an hour late.',
      ),
      ProviderReview(
        author: 'Kavita Singh',
        rating: 5,
        age: 'last month',
        body: 'Third time using them for the RO. Always reliable.',
      ),
    ],
  );

  /// The unbadged case from the design: ID verified, no GSTIN, still bookable.
  static const _imran = ProviderProfile(
    name: 'Imran AC Works',
    badge: ProviderBadge.provider,
    since: 'since May 2026',
    locationLine: 'Works across Ajnara Gen X',
    rating: 4.2,
    reviewCount: 24,
    ratingBreakdown: [0.5, 0.29, 0.13, 0.04, 0.04],
    badgeNote:
        'Imran verified their ID but has no GSTIN. Individuals are not '
        'required to have one.',
    about:
        'AC installation, servicing and gas refills across Ajnara Gen X. '
        'Evening slots available.',
    address: 'Ajnara Gen X, Crossings Republik,\nGhaziabad 201016',
    hours: 'Mon–Sun · 08:00 – 20:00',
    serves: 'Ajnara Gen X',
    services: [
      ProviderService(
        name: 'AC Servicing',
        fromPrice: 'from ₹499',
        detail: _visitCharge,
      ),
      ProviderService(
        name: 'AC Gas Refill',
        fromPrice: 'from ₹1,800',
        detail: _visitCharge,
      ),
    ],
    reviews: [
      ProviderReview(
        author: 'Deepak Rana',
        rating: 4,
        age: '3 weeks ago',
        body: 'Quick AC service, reasonable rate.',
      ),
    ],
  );

  /// The summary list on the profile head shows the visit charge rather than
  /// what each job covers, so it is rewritten here instead of being a second
  /// copy of the catalogue.
  List<ProviderService> summaryServices(ProviderProfile profile) => profile
      .services
      .map(
        (service) => ProviderService(
          name: service.name,
          fromPrice: service.fromPrice,
          detail: _visitCharge,
        ),
      )
      .toList();

  ProviderProfile? byName(String name) {
    for (final profile in [_shahnaz, _imran]) {
      if (profile.name == name) return profile;
    }
    return null;
  }

  /// Falls back to the flagship profile so a tap from anywhere in discovery
  /// lands on a page with content while the endpoint is still missing.
  ProviderProfile forName(String name) => byName(name) ?? _shahnaz;
}
