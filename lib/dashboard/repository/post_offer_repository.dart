import 'package:local_markerplace/dashboard/model/post_details.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';

/// The offers sitting under each requirement.
///
/// There is no offers endpoint yet. A post already says how many it has, so
/// the catalogue below stands in for those, and anything offered on the
/// device this session is kept alongside them — which is what lets the
/// offer-then-accept flow be followed end to end without a backend.
class PostOfferRepository {
  PostOfferRepository();

  /// The one every screen reads, so an offer made on a requirement is there
  /// when its board card is reopened. Tests build their own instead, so one
  /// case cannot leave offers behind for the next.
  static final PostOfferRepository shared = PostOfferRepository();

  /// Offers made on this device, by post key.
  final Map<String, List<PostOffer>> _added = <String, List<PostOffer>>{};

  static const _catalogue = <PostOffer>[
    PostOffer(
      name: 'Shahnaz RO & Chimney',
      badge: OfferBadge.verified,
      price: '₹899',
      timing: 'today, 4–6 pm',
      note: 'Gas top-up included if needed.',
    ),
    PostOffer(
      name: 'Imran AC Works',
      badge: OfferBadge.provider,
      price: '₹700',
      timing: 'today, evening',
      note: 'ID checked. I work in this society.',
    ),
    PostOffer(
      name: 'Rakesh',
      badge: OfferBadge.neighbour,
      price: '₹600',
      timing: 'tomorrow',
      note: 'My cousin does AC work, can send him.',
    ),
  ];

  /// Everything on [post] — the ones it arrived with, then anything offered
  /// here since.
  ///
  /// The post's count is the total, and an offer made here has already been
  /// added to it. The seeded slice is therefore taken from what is left over
  /// — otherwise offering on a post with none conjured a stranger's offer
  /// alongside your own.
  List<PostOffer> offersOn(PostDetails post) {
    final added = _added[post.key] ?? const <PostOffer>[];
    final seeded = (post.acceptCount - added.length).clamp(
      0,
      _catalogue.length,
    );
    return [..._catalogue.take(seeded), ...added];
  }

  /// Records an offer made on this device.
  void add(PostDetails post, PostOffer offer) =>
      _added.putIfAbsent(post.key, () => <PostOffer>[]).add(offer);
}
