import 'package:equatable/equatable.dart';

/// The area the feed is for.
class HomeLocality extends Equatable {
  const HomeLocality({
    required this.slug,
    required this.name,
    required this.localityType,
    required this.zoneSlug,
    required this.zoneName,
    required this.providerCount,
    this.lat,
    this.lng,
    this.radiusKm,
  });

  final String slug;
  final String name;

  /// "MARKET" / "SOCIETY".
  final String localityType;

  final String zoneSlug;
  final String zoneName;

  final double? lat;
  final double? lng;
  final double? radiusKm;

  final int providerCount;

  factory HomeLocality.fromJson(Map<String, dynamic> json) => HomeLocality(
    slug: json['slug'] as String? ?? '',
    name: json['name'] as String? ?? '',
    localityType: json['localityType'] as String? ?? '',
    zoneSlug: json['zoneSlug'] as String? ?? '',
    zoneName: json['zoneName'] as String? ?? '',
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    radiusKm: (json['radiusKm'] as num?)?.toDouble(),
    providerCount: (json['providerCount'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [slug, name, zoneSlug, providerCount];
}

/// One category tile.
///
/// The server sends two names: [tradeName] is the job ("Electrician") and
/// [needName] the thing the seeker has ("Electrical & plumbing"). Home shows
/// the trade, because that is what the tiles have always said and what the
/// board's categories match on.
class HomeCategory extends Equatable {
  const HomeCategory({
    required this.id,
    required this.slug,
    required this.tradeName,
    required this.needName,
    required this.icon,
  });

  final int id;
  final String slug;
  final String tradeName;
  final String needName;

  /// A name, not an asset: "wrench", "bolt", "snow".
  final String icon;

  factory HomeCategory.fromJson(Map<String, dynamic> json) => HomeCategory(
    id: (json['id'] as num?)?.toInt() ?? 0,
    slug: json['slug'] as String? ?? '',
    tradeName: json['tradeName'] as String? ?? '',
    needName: json['needName'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
  );

  @override
  List<Object?> get props => [id, slug, tradeName, needName, icon];
}

/// A provider in the "Near you" rail.
class HomeProvider extends Equatable {
  const HomeProvider({
    required this.providerId,
    required this.slug,
    required this.name,
    required this.verified,
    required this.openNow,
    required this.homeService,
    required this.localityName,
    required this.ratingAverage,
    required this.reviewCount,
    this.logoFileId,
    this.responseTimeMinutes,
  });

  final String providerId;
  final String slug;
  final String name;

  /// Null until a logo is uploaded; the card falls back to initials.
  final String? logoFileId;

  final bool verified;
  final bool openNow;

  /// Whether they come to you rather than you going to them.
  final bool homeService;

  /// Null when the provider has not answered enough messages to have one.
  final int? responseTimeMinutes;

  final String localityName;
  final double ratingAverage;
  final int reviewCount;

  /// A new provider has no rating yet — zero means unrated, not bad.
  bool get isRated => reviewCount > 0;

  factory HomeProvider.fromJson(Map<String, dynamic> json) => HomeProvider(
    providerId: json['providerId'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    name: json['name'] as String? ?? '',
    logoFileId: json['logoFileId'] as String?,
    verified: json['verified'] as bool? ?? false,
    openNow: json['openNow'] as bool? ?? false,
    homeService: json['homeService'] as bool? ?? false,
    responseTimeMinutes: (json['responseTimeMinutes'] as num?)?.toInt(),
    localityName: json['localityName'] as String? ?? '',
    ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [providerId, slug, name, ratingAverage];
}

/// Everything home draws, in one payload.
class HomeFeed extends Equatable {
  const HomeFeed({
    required this.locality,
    required this.categories,
    required this.providersNearYou,
    required this.providerCount,
  });

  final HomeLocality locality;
  final List<HomeCategory> categories;
  final List<HomeProvider> providersNearYou;

  /// How many work in the area in total, which can exceed the rail's length.
  final int providerCount;

  factory HomeFeed.fromJson(Map<String, dynamic> json) => HomeFeed(
    locality: HomeLocality.fromJson(_object(json['locality'])),
    categories: [
      for (final entry in _list(json['categories']))
        HomeCategory.fromJson(entry),
    ],
    providersNearYou: [
      for (final entry in _list(json['providersNearYou']))
        HomeProvider.fromJson(entry),
    ],
    providerCount: (json['providerCount'] as num?)?.toInt() ?? 0,
  );

  /// Reads a nested object without asserting its generic type.
  ///
  /// Dio hands back `Map<String, dynamic>`, but a literal written in a test
  /// or a payload decoded elsewhere may be typed more loosely, and a hard
  /// cast turns a missing field into a crash rather than a default.
  static Map<String, dynamic> _object(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static List<Map<String, dynamic>> _list(Object? value) => [
    if (value is List)
      for (final entry in value)
        if (entry is Map) Map<String, dynamic>.from(entry),
  ];

  @override
  List<Object?> get props => [
    locality,
    categories,
    providersNearYou,
    providerCount,
  ];
}
