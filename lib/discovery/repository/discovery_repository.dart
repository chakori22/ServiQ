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

  static const _crossingRepublik = ServiceZone(
    name: 'Crossing Republik',
    city: 'Ghaziabad, UP',
    isLive: true,
    societyCount: 10,
    marketCount: 6,
    localities: [
      Locality(
        name: 'Ajnara Gen X',
        providerCount: 12,
        kind: LocalityKind.society,
      ),
      Locality(
        name: 'Mahagun Mascot',
        providerCount: 8,
        kind: LocalityKind.society,
      ),
      Locality(
        name: 'Panchsheel Wellington',
        providerCount: 5,
        kind: LocalityKind.society,
      ),
      Locality(
        name: 'Mahagun Montage',
        providerCount: 4,
        kind: LocalityKind.society,
      ),
      Locality(
        name: 'Galleria Market 1',
        providerCount: 9,
        kind: LocalityKind.market,
      ),
      Locality(
        name: 'Galleria Market 2',
        providerCount: 6,
        kind: LocalityKind.market,
      ),
      Locality(
        name: 'Panchsheel Square',
        providerCount: 3,
        kind: LocalityKind.market,
      ),
    ],
  );

  static const _comingSoon = [
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
  List<ServiceZone> zones() => const [_crossingRepublik, ..._comingSoon];

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
  ];

  /// Providers working in [localityName], in the order the design lists them.
  List<ProviderSummary> providersIn(String localityName) => _providers
      .where((provider) => provider.localityName == localityName)
      .toList();

  /// The two providers shown in home's "Near you" rail.
  List<ProviderSummary> nearby({int limit = 2}) =>
      _providers.take(limit).toList();

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
