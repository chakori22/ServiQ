import 'package:local_markerplace/dashboard/model/post_details.dart';

/// What the seeker has done to the board this session.
///
/// The board's bloc is created with the screen and dies with it, while the
/// stub feed hands back the same seeded list every time it is asked. Without
/// somewhere to keep them, a post the seeker just shared and an offer they
/// just accepted were both forgotten the moment they left the board — which
/// is what this holds on to, the same way offers and visits are held.
///
/// A real backend would return all of this and none of it would be needed.
class PostBoardRepository {
  PostBoardRepository();

  static final PostBoardRepository shared = PostBoardRepository();

  /// Posts shared from this device, newest first.
  final List<PostDetails> _published = <PostDetails>[];

  /// Post key to the provider whose offer settled it.
  final Map<String, String> _accepted = <String, String>{};

  /// Post key to offers made from this device, which the seeded feed does
  /// not know about.
  final Map<String, int> _extraOffers = <String, int>{};

  /// Posts the seeker has taken down.
  final Set<String> _closed = <String>{};

  void publish(PostDetails post) => _published.insert(0, post);

  void accept(PostDetails post, String providerName) =>
      _accepted[post.key] = providerName;

  void addOffer(PostDetails post) =>
      _extraOffers[post.key] = (_extraOffers[post.key] ?? 0) + 1;

  void close(PostDetails post) => _closed.add(post.key);

  void reopen(PostDetails post) => _closed.remove(post.key);

  /// Lays the session's changes over a freshly fetched feed.
  List<PostDetails> apply(List<PostDetails> fetched) => [
    for (final post in [..._published, ...fetched]) _withChanges(post),
  ];

  PostDetails _withChanges(PostDetails post) {
    final acceptedBy = _accepted[post.key];
    final extra = _extraOffers[post.key] ?? 0;
    final closed = _closed.contains(post.key);
    if (acceptedBy == null && extra == 0 && !closed) return post;
    return post.copyWith(
      isAccepted: acceptedBy != null ? true : null,
      acceptedBy: acceptedBy,
      acceptCount: post.acceptCount + extra,
      isClosed: closed ? true : null,
    );
  }

  /// Forgets everything, so one test cannot colour the next.
  void clear() {
    _published.clear();
    _accepted.clear();
    _extraOffers.clear();
    _closed.clear();
  }
}
