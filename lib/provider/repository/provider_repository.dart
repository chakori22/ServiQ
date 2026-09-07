import 'package:local_markerplace/discovery/model/catalogue_service.dart';
import 'package:local_markerplace/discovery/model/provider_summary.dart';
import 'package:local_markerplace/discovery/repository/discovery_repository.dart';
import 'package:local_markerplace/provider/model/provider_profile.dart';
import 'package:local_markerplace/provider/model/provider_review.dart';
import 'package:local_markerplace/provider/model/provider_service.dart';
import 'package:local_markerplace/provider/model/store_product.dart';
import 'package:local_markerplace/provider/model/trade_catalogue.dart';

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
        detail:
            'Sediment, pre-carbon and post-carbon. Fits most domestic RO '
            'units. Sold as a set of three.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'RO Membrane 80 GPD',
        price: '₹1,800',
        stockLabel: 'In stock',
        detail:
            'Replaces the membrane when output drops or the water starts '
            'tasting flat. Lasts two to three years.',
        fittingName: 'RO Service & Repair',
        fittingFrom: '₹499',
      ),
      StoreProduct(
        name: 'Chimney Baffle Filter',
        price: '₹890',
        stockLabel: 'Only 2 left',
        isLow: true,
        detail:
            'Stainless steel baffles for a 60 cm chimney. Dishwasher safe, '
            'sold as a pair.',
        fittingName: 'Chimney Deep Clean',
        fittingFrom: '₹899',
      ),
      StoreProduct(
        name: 'Sediment Filter 10"',
        price: '₹350',
        stockLabel: 'In stock',
        detail:
            'Spun polypropylene, 5 micron. The first stage — change it every '
            'six months in hard water.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Carbon Filter Block',
        price: '₹450',
        stockLabel: 'In stock',
        detail:
            'Takes out chlorine and smell before the water reaches the '
            'membrane.',
        fittingName: 'RO Filter Change',
        fittingFrom: '₹349',
      ),
      StoreProduct(
        name: 'Chimney Motor (1200 m³/hr)',
        price: '₹3,400',
        stockLabel: 'In stock',
        detail:
            'Copper winding, one year warranty. Suits most wall-mounted '
            'chimneys up to 90 cm.',
        fittingName: 'Chimney Deep Clean',
        fittingFrom: '₹899',
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

  /// The page for [name].
  ///
  /// Two providers are written out by hand because the design draws them and
  /// the rest of the seed refers to them. Every other business in the
  /// directory is built from its trade and its own name, so an electrician
  /// sells electrical work and a plumber sells plumbing — and two
  /// electricians do not sell an identical list at identical prices.
  ProviderProfile forName(String name) =>
      byName(name) ?? _fromDirectory(name) ?? _shahnaz;

  /// Every job bookable in [localityName], flattened out of the providers
  /// who work there.
  ///
  /// It is built from the profiles rather than kept as a list of its own, so
  /// the price a seeker sees on the services screen is by construction the
  /// price on the provider's page. The two used to be written separately and
  /// quietly disagreed.
  List<CatalogueService> servicesIn(
    String localityName, {
    String? categoryLabel,
  }) {
    final catalogue = <CatalogueService>[];
    for (final provider in _directory.providersIn(localityName)) {
      final category = provider.trade.split('·').first.trim();
      if (categoryLabel != null && category != categoryLabel) continue;
      final profile = forName(provider.name);
      for (final service in profile.services) {
        catalogue.add(
          CatalogueService(
            name: service.name,
            detail: service.detail,
            fromPrice: service.fromPrice,
            categoryLabel: category,
            providerName: provider.name,
            rating: provider.rating,
            isVerifiedProvider: provider.isVerified,
          ),
        );
      }
    }
    return catalogue;
  }

  ProviderProfile? _fromDirectory(String name) {
    final summary = _directory.byName(name);
    if (summary == null) return null;
    return _derive(summary);
  }

  static const DiscoveryRepository _directory = DiscoveryRepository();

  /// Builds a page for a provider the directory knows but nobody has written
  /// out.
  ///
  /// Everything varies with the business's own name, so the page is stable
  /// between visits and different from its neighbours': which jobs they
  /// take, what they stock, what they charge, when they open and what people
  /// said about them.
  static ProviderProfile _derive(ProviderSummary summary) {
    final catalogue = TradeCatalogue.of(summary.trade);
    final seed = _seedOf(summary.name);

    // A provider offers most of their trade's work but not all of it, taken
    // from a different point in the list each time.
    final services = _rotate(
      catalogue.services,
      seed,
    ).take(3 + seed % 3).map((service) => _priced(service, seed)).toList();

    // Some businesses keep a counter and some only do call-outs, which is
    // why a third of them have no store at all.
    final products = seed % 3 == 0
        ? const <StoreProduct>[]
        : _rotate(catalogue.products, seed ~/ 2).take(3 + seed % 4).toList();

    return ProviderProfile(
      name: summary.name,
      badge: summary.isVerified
          ? ProviderBadge.verified
          : ProviderBadge.provider,
      // Always a date that has already happened — a business trading
      // "since Nov 2026" when it is September reads as a bug.
      since: 'since ${_months[seed % _months.length]} 202${2 + seed % 3}',
      locationLine: 'Works across ${summary.localityName}',
      rating: summary.rating,
      reviewCount: summary.reviewCount,
      ratingBreakdown: _breakdownFor(summary.rating),
      badgeNote: summary.isVerified
          ? null
          : '${summary.name.split(' ').first} verified their ID but has no '
                'GSTIN. Individuals are not required to have one.',
      about: catalogue.about.replaceAll('{area}', summary.localityName),
      address:
          '${summary.localityName}, Crossings Republik,\nGhaziabad '
          '201016',
      hours: _hours[seed % _hours.length],
      serves: summary.localityName,
      services: services,
      products: products,
      reviews: _reviewsFor(catalogue, seed),
    );
  }

  /// Prices move a little between businesses — the same job is not quoted to
  /// the rupee by every provider in the society.
  static ProviderService _priced(ProviderService service, int seed) {
    final base = _rupeesIn(service.fromPrice);
    if (base == 0) return service;
    // Between 10% under and 15% over, rounded to something a person would
    // actually write down.
    final adjusted = (base * (90 + seed % 26) / 100 / 10).round() * 10;
    return ProviderService(
      name: service.name,
      fromPrice: 'from ₹${_grouped(adjusted)}',
      detail: service.detail,
    );
  }

  static List<ProviderReview> _reviewsFor(TradeCatalogue catalogue, int seed) {
    final lines = _rotate(catalogue.reviews, seed).take(2).toList();
    return [
      for (final (index, body) in lines.indexed)
        ProviderReview(
          author: _authors[(seed + index) % _authors.length],
          rating: index == 0 ? 5 : 4,
          age: _ages[(seed + index) % _ages.length],
          body: body,
        ),
    ];
  }

  /// A rating's shape: the higher it is, the more of it sits on five stars.
  static List<double> _breakdownFor(double rating) {
    final top = ((rating - 3) / 2).clamp(0.15, 0.85);
    final second = (1 - top) * 0.55;
    final rest = 1 - top - second;
    return [top, second, rest * 0.5, rest * 0.3, rest * 0.2];
  }

  /// Starts the list at a different place for each business, so neighbours
  /// in the same trade lead with different work.
  static List<T> _rotate<T>(List<T> items, int seed) {
    if (items.isEmpty) return items;
    final at = seed % items.length;
    return [...items.skip(at), ...items.take(at)];
  }

  /// FNV-1a over the name — stable across launches, unlike hashCode.
  static int _seedOf(String name) {
    var hash = 0x811c9dc5;
    for (final unit in name.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  static int _rupeesIn(String price) {
    final digits = RegExp(r'[\d,]+').firstMatch(price)?.group(0);
    if (digits == null) return 0;
    return int.tryParse(digits.replaceAll(',', '')) ?? 0;
  }

  static String _grouped(int amount) {
    final whole = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return buffer.toString();
  }

  static const _months = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];

  static const _hours = [
    'Mon–Sun · 08:00 – 20:00',
    'Mon–Sat · 09:00 – 19:00',
    'Mon–Sun · 07:00 – 21:00',
    'Mon–Sat · 10:00 – 18:00',
  ];

  static const _authors = [
    'Anita Sharma',
    'Rohit Verma',
    'Deepak Rana',
    'Meera Nair',
    'Sanjay Gupta',
    'Farah Khan',
    'Vikram Singh',
  ];

  static const _ages = [
    '3 days ago',
    'a week ago',
    '2 weeks ago',
    'last month',
    '3 weeks ago',
  ];
}
