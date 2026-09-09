part of 'home_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null,
// which is what lets a successful fetch clear the failure left by the one
// before it.
const _unset = Object();

class HomeState extends Equatable {
  /// What the server last answered with. Kept across a refresh so the feed
  /// the seeker is reading does not blink out while a newer one is asked for.
  final HomeFeed? feed;

  /// A first load, or a retry: nothing on screen yet, so this is the
  /// skeleton.
  final bool isLoading;

  /// A pull-to-refresh over a feed that is already showing.
  final bool isRefreshing;

  final Failure? failure;

  /// When the failure happened, for the line under the error state.
  final DateTime? failedAt;

  /// The area being asked for — "galleria-market-1".
  final String localitySlug;

  const HomeState({
    required this.feed,
    required this.isLoading,
    required this.isRefreshing,
    required this.failure,
    required this.failedAt,
    required this.localitySlug,
  });

  const HomeState.initial({
    this.feed,
    this.isLoading = true,
    this.isRefreshing = false,
    this.failure,
    this.failedAt,
    this.localitySlug = '',
  });

  HomeState copyWith({
    Object? feed = _unset,
    bool? isLoading,
    bool? isRefreshing,
    Object? failure = _unset,
    Object? failedAt = _unset,
    String? localitySlug,
  }) {
    return HomeState(
      feed: feed == _unset ? this.feed : feed as HomeFeed?,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: failure == _unset ? this.failure : failure as Failure?,
      failedAt: failedAt == _unset ? this.failedAt : failedAt as DateTime?,
      localitySlug: localitySlug ?? this.localitySlug,
    );
  }

  /// The area's name as the server knows it. Null until it has answered, so
  /// the screen can fall back to the name it was opened with.
  String? get localityName => feed?.locality.name;

  List<HomeCategory> get categories => feed?.categories ?? const [];

  List<HomeProvider> get providersNearYou => feed?.providersNearYou ?? const [];

  /// The server has no record of this area at all — it answers
  /// LOCALITY_NOT_FOUND rather than an empty feed.
  ///
  /// Worth its own name because it is not a failure the seeker should be
  /// apologised to for: the area simply is not live yet, which is a different
  /// screen from one that could not load.
  bool get isUnknownLocality => failure?.errorCode == 'LOCALITY_NOT_FOUND';

  /// Being offline and the server faulting read differently on the screen:
  /// one is something the seeker can act on, the other explicitly is not
  /// theirs to fix.
  bool get isOffline =>
      failure?.errorCode == 'CONNECTION_ERROR' ||
      failure?.errorCode == 'TIMEOUT';

  @override
  List<Object?> get props => [
    feed,
    isLoading,
    isRefreshing,
    failure,
    failedAt,
    localitySlug,
  ];
}
