import 'package:local_markerplace/discovery/model/locality.dart';
import 'package:local_markerplace/discovery/model/pending_booking.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/model/service_category.dart';
import 'package:local_markerplace/discovery/model/service_zone.dart';

/// Content for the discovery screens.
///
/// The catalogue below is the seed data drawn in the design — Crossing
/// Republik and its societies, and the providers working in them. There is no
/// discovery endpoint yet, so the screens read from here; swapping this class
/// for an API-backed one is the only change the presentation layer needs, as
/// nothing above it knows where the lists come from.
class DiscoveryRepository {
  const DiscoveryRepository();

  /// Built rather than declared const so a locality's provider count comes
  /// from the providers actually on file. The count is what a row promises
  /// before the seeker taps it, so it must never be able to drift from what
  /// is behind it.
  static Locality _locality(String name, LocalityKind kind) => Locality(
    name: name,
    providerCount: _providers
        .where((provider) => provider.localityName == name)
        .length,
    kind: kind,
  );

  static final _crossingRepublik = ServiceZone(
    name: 'Crossing Republik',
    city: 'Ghaziabad, UP',
    isLive: true,
    localities: [
      _locality('Ajnara Gen X', LocalityKind.society),
      _locality('Mahagun Mascot', LocalityKind.society),
      _locality('Panchsheel Wellington', LocalityKind.society),
      _locality('Mahagun Montage', LocalityKind.society),
      _locality('Ajnara Integrity', LocalityKind.society),
      _locality('Panchsheel Greens', LocalityKind.society),
      _locality('Cloud 9 Towers', LocalityKind.society),
      _locality('Supertech Livingston', LocalityKind.society),
      _locality('Victory Crossroads', LocalityKind.society),
      _locality('Amrapali Princely Estate', LocalityKind.society),
      _locality('Galleria Market 1', LocalityKind.market),
      _locality('Galleria Market 2', LocalityKind.market),
      _locality('Panchsheel Square', LocalityKind.market),
      _locality('Crossing Mall', LocalityKind.market),
      _locality('Shipra Market', LocalityKind.market),
      _locality('Gaur City Centre', LocalityKind.market),
    ],
  );

  static const _comingSoon = <ServiceZone>[
    ServiceZone(name: 'Gaur City 1', city: 'Greater Noida, UP', isLive: false),
    ServiceZone(name: 'Gaur City 2', city: 'Greater Noida, UP', isLive: false),
    ServiceZone(
      name: 'Greater Noida West',
      city: 'Greater Noida, UP',
      isLive: false,
    ),
  ];

  /// Every zone, live ones first. The area picker and the explore list both
  /// render this in that order.
  List<ServiceZone> zones() => [_crossingRepublik, ..._comingSoon];

  ServiceZone? zoneNamed(String name) {
    for (final zone in zones()) {
      if (zone.name == name) return zone;
    }
    return null;
  }

  /// The zone a locality belongs to, used to caption the locality screen.
  ServiceZone? zoneOfLocality(String localityName) {
    for (final zone in zones()) {
      if (zone.localities.any((l) => l.name == localityName)) return zone;
    }
    return null;
  }

  static const _categories = [
    ServiceCategory(
      label: 'Electrician',
      iconAsset: 'assets/images/discovery/cat_electrician.svg',
    ),
    ServiceCategory(
      label: 'Plumber',
      iconAsset: 'assets/images/discovery/cat_plumber.svg',
    ),
    ServiceCategory(
      label: 'AC Repair',
      iconAsset: 'assets/images/discovery/cat_ac_repair.svg',
    ),
    ServiceCategory(
      label: 'RO Repair',
      iconAsset: 'assets/images/discovery/cat_ro_repair.svg',
    ),
    ServiceCategory(
      label: 'Carpenter',
      iconAsset: 'assets/images/discovery/cat_carpenter.svg',
    ),
    ServiceCategory(
      label: 'Appliance',
      iconAsset: 'assets/images/discovery/cat_appliance.svg',
    ),
  ];

  List<ServiceCategory> categories() => _categories;

  static const _providers = [
    ProviderSummary(
      name: 'Shahnaz RO & Chimney Services',
      trade: 'RO Repair · Chimney',
      rating: 4.6,
      reviewCount: 128,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'RK Electricals & Repairs',
      trade: 'Electrician',
      rating: 4.4,
      reviewCount: 40,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Verma Plumbing Works',
      trade: 'Plumber',
      rating: 4.2,
      reviewCount: 31,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'CoolAir AC Service',
      trade: 'AC Repair',
      rating: 4.7,
      reviewCount: 58,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Sharma Carpentry',
      trade: 'Carpenter',
      rating: 4.1,
      reviewCount: 22,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Galleria Home Services',
      trade: 'Cleaning',
      rating: 4.3,
      reviewCount: 47,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Mascot Appliance Care',
      trade: 'Appliance',
      rating: 4.0,
      reviewCount: 19,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Bright Spark Electricals',
      trade: 'Electrician',
      rating: 4.3,
      reviewCount: 26,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Gen X Pest Control',
      trade: 'Pest control',
      rating: 4.5,
      reviewCount: 33,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Ajnara Home Services',
      trade: 'Electrician',
      rating: 4.0,
      reviewCount: 18,
      localityName: 'Ajnara Gen X',
      isOpen: false,
    ),
    ProviderSummary(
      name: 'Kumar Electric Works',
      trade: 'Electrician',
      rating: 4.2,
      reviewCount: 24,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Sai Electricals',
      trade: 'Electrician',
      rating: 4.1,
      reviewCount: 21,
      localityName: 'Ajnara Gen X',
      isOpen: false,
    ),
    ProviderSummary(
      name: 'Verma Electric & Fans',
      trade: 'Electrician',
      rating: 3.9,
      reviewCount: 16,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Gen X Quick Repairs',
      trade: 'Electrician',
      rating: 3.8,
      reviewCount: 12,
      localityName: 'Ajnara Gen X',
      isOpen: true,
    ),

    // --- The rest of Crossing Republik's societies ------------------------
    ProviderSummary(
      name: 'Mascot Electrical Care',
      trade: 'Electrician',
      rating: 4.4,
      reviewCount: 37,
      localityName: 'Mahagun Mascot',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Mascot Plumbing Point',
      trade: 'Plumber',
      rating: 4.1,
      reviewCount: 23,
      localityName: 'Mahagun Mascot',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Sunrise AC Care',
      trade: 'AC Repair',
      rating: 4.5,
      reviewCount: 44,
      localityName: 'Mahagun Mascot',
      isOpen: false,
    ),
    ProviderSummary(
      name: 'Wellington Home Repairs',
      trade: 'Carpenter',
      rating: 4.2,
      reviewCount: 29,
      localityName: 'Panchsheel Wellington',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Panchsheel RO Care',
      trade: 'RO Repair',
      rating: 4.0,
      reviewCount: 17,
      localityName: 'Panchsheel Wellington',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Montage Quick Fix',
      trade: 'Appliance',
      rating: 4.3,
      reviewCount: 21,
      localityName: 'Mahagun Montage',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Integrity Electricals',
      trade: 'Electrician',
      rating: 4.1,
      reviewCount: 14,
      localityName: 'Ajnara Integrity',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Greens Cleaning Crew',
      trade: 'Cleaning',
      rating: 4.6,
      reviewCount: 52,
      localityName: 'Panchsheel Greens',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Greens Plumbing Works',
      trade: 'Plumber',
      rating: 3.9,
      reviewCount: 11,
      localityName: 'Panchsheel Greens',
      isOpen: false,
    ),
    ProviderSummary(
      name: 'Cloud 9 Appliance Hub',
      trade: 'Appliance',
      rating: 4.2,
      reviewCount: 26,
      localityName: 'Cloud 9 Towers',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Livingston Carpentry',
      trade: 'Carpenter',
      rating: 4.4,
      reviewCount: 31,
      localityName: 'Supertech Livingston',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Crossroads Pest Control',
      trade: 'Pest control',
      rating: 4.0,
      reviewCount: 15,
      localityName: 'Victory Crossroads',
      isOpen: true,
    ),

    // --- Markets ----------------------------------------------------------
    ProviderSummary(
      name: 'Galleria Electricals',
      trade: 'Electrician',
      rating: 4.5,
      reviewCount: 63,
      localityName: 'Galleria Market 1',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Galleria Mobile & Appliance',
      trade: 'Appliance',
      rating: 4.2,
      reviewCount: 38,
      localityName: 'Galleria Market 1',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Sharma Hardware & Plumbing',
      trade: 'Plumber',
      rating: 4.3,
      reviewCount: 41,
      localityName: 'Galleria Market 1',
      isOpen: false,
    ),
    ProviderSummary(
      name: 'Galleria AC Point',
      trade: 'AC Repair',
      rating: 4.1,
      reviewCount: 27,
      localityName: 'Galleria Market 2',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Market Cleaning Services',
      trade: 'Cleaning',
      rating: 3.9,
      reviewCount: 19,
      localityName: 'Galleria Market 2',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Square RO Solutions',
      trade: 'RO Repair',
      rating: 4.4,
      reviewCount: 34,
      localityName: 'Panchsheel Square',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Crossing Mall Electricals',
      trade: 'Electrician',
      rating: 4.0,
      reviewCount: 22,
      localityName: 'Crossing Mall',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Shipra Appliance Repairs',
      trade: 'Appliance',
      rating: 4.2,
      reviewCount: 30,
      localityName: 'Shipra Market',
      isOpen: true,
    ),

    // Mahagun Mascot
    ProviderSummary(
      name: 'Mascot Carpentry Studio',
      trade: 'Carpenter',
      rating: 4.2,
      reviewCount: 28,
      localityName: 'Mahagun Mascot',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Fresh Look Cleaners',
      trade: 'Cleaning',
      rating: 4.6,
      reviewCount: 55,
      localityName: 'Mahagun Mascot',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Mascot Pest Shield',
      trade: 'Pest control',
      rating: 4.0,
      reviewCount: 16,
      localityName: 'Mahagun Mascot',
      isOpen: false,
    ),

    // Panchsheel Wellington
    ProviderSummary(
      name: 'Wellington Electric Co',
      trade: 'Electrician',
      rating: 4.5,
      reviewCount: 48,
      localityName: 'Panchsheel Wellington',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Blue Drop Plumbers',
      trade: 'Plumber',
      rating: 4.1,
      reviewCount: 25,
      localityName: 'Panchsheel Wellington',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Wellington AC Experts',
      trade: 'AC Repair',
      rating: 4.4,
      reviewCount: 39,
      localityName: 'Panchsheel Wellington',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Spotless Home Cleaning',
      trade: 'Cleaning',
      rating: 4.3,
      reviewCount: 33,
      localityName: 'Panchsheel Wellington',
      isOpen: false,
    ),

    // Mahagun Montage
    ProviderSummary(
      name: 'Montage Electricals',
      trade: 'Electrician',
      rating: 4.3,
      reviewCount: 30,
      localityName: 'Mahagun Montage',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Montage Plumbing Co',
      trade: 'Plumber',
      rating: 4.0,
      reviewCount: 18,
      localityName: 'Mahagun Montage',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Cool Breeze AC Care',
      trade: 'AC Repair',
      rating: 4.5,
      reviewCount: 42,
      localityName: 'Mahagun Montage',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Montage RO Service',
      trade: 'RO Repair',
      rating: 4.1,
      reviewCount: 20,
      localityName: 'Mahagun Montage',
      isOpen: false,
    ),

    // Ajnara Integrity
    ProviderSummary(
      name: 'Integrity Plumbing',
      trade: 'Plumber',
      rating: 4.2,
      reviewCount: 24,
      localityName: 'Ajnara Integrity',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Integrity AC & RO',
      trade: 'AC Repair · RO Repair',
      rating: 4.4,
      reviewCount: 36,
      localityName: 'Ajnara Integrity',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Neat Nest Cleaning',
      trade: 'Cleaning',
      rating: 4.5,
      reviewCount: 47,
      localityName: 'Ajnara Integrity',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Integrity Woodworks',
      trade: 'Carpenter',
      rating: 3.9,
      reviewCount: 13,
      localityName: 'Ajnara Integrity',
      isOpen: false,
    ),

    // Panchsheel Greens
    ProviderSummary(
      name: 'Greens Electric Point',
      trade: 'Electrician',
      rating: 4.4,
      reviewCount: 41,
      localityName: 'Panchsheel Greens',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Greens AC Service',
      trade: 'AC Repair',
      rating: 4.2,
      reviewCount: 29,
      localityName: 'Panchsheel Greens',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Greens Appliance Care',
      trade: 'Appliance',
      rating: 4.0,
      reviewCount: 21,
      localityName: 'Panchsheel Greens',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Green Shield Pest Control',
      trade: 'Pest control',
      rating: 4.3,
      reviewCount: 27,
      localityName: 'Panchsheel Greens',
      isOpen: false,
    ),

    // Cloud 9 Towers
    ProviderSummary(
      name: 'Cloud 9 Electricals',
      trade: 'Electrician',
      rating: 4.3,
      reviewCount: 34,
      localityName: 'Cloud 9 Towers',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Skyline Plumbing',
      trade: 'Plumber',
      rating: 4.1,
      reviewCount: 22,
      localityName: 'Cloud 9 Towers',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Cloud 9 AC Care',
      trade: 'AC Repair',
      rating: 4.6,
      reviewCount: 51,
      localityName: 'Cloud 9 Towers',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Tower Cleaning Crew',
      trade: 'Cleaning',
      rating: 4.2,
      reviewCount: 26,
      localityName: 'Cloud 9 Towers',
      isOpen: false,
    ),

    // Supertech Livingston
    ProviderSummary(
      name: 'Livingston Electricals',
      trade: 'Electrician',
      rating: 4.2,
      reviewCount: 31,
      localityName: 'Supertech Livingston',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Livingston RO Care',
      trade: 'RO Repair',
      rating: 4.4,
      reviewCount: 38,
      localityName: 'Supertech Livingston',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Quick Fix Appliances',
      trade: 'Appliance',
      rating: 4.0,
      reviewCount: 19,
      localityName: 'Supertech Livingston',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Livingston Plumbers',
      trade: 'Plumber',
      rating: 3.9,
      reviewCount: 14,
      localityName: 'Supertech Livingston',
      isOpen: false,
    ),

    // Victory Crossroads
    ProviderSummary(
      name: 'Victory Electricals',
      trade: 'Electrician',
      rating: 4.5,
      reviewCount: 45,
      localityName: 'Victory Crossroads',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Crossroads Plumbing',
      trade: 'Plumber',
      rating: 4.2,
      reviewCount: 27,
      localityName: 'Victory Crossroads',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Victory AC & Appliance',
      trade: 'AC Repair · Appliance',
      rating: 4.3,
      reviewCount: 35,
      localityName: 'Victory Crossroads',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Crossroads Carpentry',
      trade: 'Carpenter',
      rating: 4.0,
      reviewCount: 17,
      localityName: 'Victory Crossroads',
      isOpen: false,
    ),

    // Galleria Market 1
    ProviderSummary(
      name: 'Galleria Carpentry Works',
      trade: 'Carpenter',
      rating: 4.1,
      reviewCount: 24,
      localityName: 'Galleria Market 1',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Galleria Pest Solutions',
      trade: 'Pest control',
      rating: 4.4,
      reviewCount: 40,
      localityName: 'Galleria Market 1',
      isOpen: false,
    ),

    // Galleria Market 2
    ProviderSummary(
      name: 'Market Electric House',
      trade: 'Electrician',
      rating: 4.3,
      reviewCount: 32,
      localityName: 'Galleria Market 2',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Galleria RO & Purifier',
      trade: 'RO Repair',
      rating: 4.2,
      reviewCount: 28,
      localityName: 'Galleria Market 2',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Galleria Carpenters',
      trade: 'Carpenter',
      rating: 3.9,
      reviewCount: 15,
      localityName: 'Galleria Market 2',
      isOpen: false,
    ),

    // Panchsheel Square
    ProviderSummary(
      name: 'Square Electricals',
      trade: 'Electrician',
      rating: 4.2,
      reviewCount: 26,
      localityName: 'Panchsheel Square',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Square Appliance Hub',
      trade: 'Appliance',
      rating: 4.4,
      reviewCount: 37,
      localityName: 'Panchsheel Square',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Square Plumbing Point',
      trade: 'Plumber',
      rating: 4.0,
      reviewCount: 18,
      localityName: 'Panchsheel Square',
      isOpen: false,
    ),

    // Crossing Mall
    ProviderSummary(
      name: 'Mall AC Services',
      trade: 'AC Repair',
      rating: 4.5,
      reviewCount: 49,
      localityName: 'Crossing Mall',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Mall Appliance Repairs',
      trade: 'Appliance',
      rating: 4.1,
      reviewCount: 23,
      localityName: 'Crossing Mall',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Crossing Cleaning Co',
      trade: 'Cleaning',
      rating: 4.3,
      reviewCount: 30,
      localityName: 'Crossing Mall',
      isOpen: false,
    ),

    // Shipra Market
    ProviderSummary(
      name: 'Shipra Electricals',
      trade: 'Electrician',
      rating: 4.4,
      reviewCount: 43,
      localityName: 'Shipra Market',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Shipra Plumbing Works',
      trade: 'Plumber',
      rating: 4.0,
      reviewCount: 20,
      localityName: 'Shipra Market',
      isOpen: true,
    ),
    ProviderSummary(
      name: 'Shipra RO Care',
      trade: 'RO Repair',
      rating: 4.2,
      reviewCount: 25,
      localityName: 'Shipra Market',
      isOpen: false,
    ),
    // Gaur City Centre is deliberately left with nobody on file: it is the
    // case the "coming soon" row and the empty state exist for.
  ];

  /// Providers working in [localityName], in the order the design lists them.
  List<ProviderSummary> providersIn(String localityName) => _providers
      .where((provider) => provider.localityName == localityName)
      .toList();

  /// The providers shown in home's "Near you" rail — the ones working in the
  /// seeker's own area, not simply the first on file.
  List<ProviderSummary> nearby(String localityName, {int limit = 6}) =>
      providersIn(localityName).take(limit).toList();

  /// Providers matching [query], optionally narrowed to one [trade] and to
  /// those rated at least [minRating]. Matching is a plain case-insensitive
  /// contains over the name and the trade — enough for the seed catalogue, and
  /// the shape a search endpoint would replace.
  List<ProviderSummary> search(
    String query, {
    String? trade,
    double? minRating,
    String? localityName,
  }) {
    final needle = query.trim().toLowerCase();
    return _providers.where((provider) {
      if (localityName != null && provider.localityName != localityName) {
        return false;
      }
      if (trade != null && !_tradesOf(provider).contains(trade)) return false;
      if (minRating != null && provider.rating < minRating) return false;
      if (needle.isEmpty) return true;
      return provider.name.toLowerCase().contains(needle) ||
          provider.trade.toLowerCase().contains(needle);
    }).toList();
  }

  /// The trades offered in [localityName], used for the search filter chips.
  ///
  /// A provider's trade line can name more than one — "RO Repair · Chimney" —
  /// so it is split apart here and each part offered as its own chip.
  List<String> tradesIn(String localityName) {
    final trades = <String>{};
    for (final provider in providersIn(localityName)) {
      trades.addAll(_tradesOf(provider));
    }
    return trades.toList();
  }

  static List<String> _tradesOf(ProviderSummary provider) =>
      provider.trade.split('·').map((trade) => trade.trim()).toList();

  /// The booking waiting to be paid for, or null when there is none.
  PendingBooking? pendingBooking() => const PendingBooking(
    providerName: 'Shahnaz RO & Chimney',
    summary: '2 services · 3 parts',
    amount: '₹3,797',
  );
}
