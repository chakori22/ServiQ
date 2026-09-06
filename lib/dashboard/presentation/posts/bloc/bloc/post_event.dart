part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();
}

final class OnFetchPostDetails extends PostEvent {
  const OnFetchPostDetails({this.currentUsername});

  /// The signed-in user's handle. The stub repository puts a few of its
  /// requirements under it so the board's "Mine" chip has something to show
  /// whoever is looking; a real endpoint would return them already owned.
  final String? currentUsername;

  @override
  List<Object> get props => [currentUsername ?? ''];
}

/// The user tapped "Share" on one of the create-post forms. The posts page
/// owns the upload, not the form: the form is popped as soon as it is
/// submitted, so the progress banner has to live somewhere that outlives it.
final class OnStartPostUpload extends PostEvent {
  final PostDraft draft;

  const OnStartPostUpload(this.draft);

  @override
  List<Object> get props => [draft];
}

/// Clears a shown error so the same message can be surfaced again if the
/// next attempt fails the same way.
final class OnDismissAlertMessage extends PostEvent {
  const OnDismissAlertMessage();

  @override
  List<Object> get props => [];
}

/// Somebody offered on a requirement from this device. Only the count lives
/// on the post; the offer itself goes to the offer store.
final class OnOfferMade extends PostEvent {
  final PostDetails post;

  const OnOfferMade(this.post);

  @override
  List<Object> get props => [post.key];
}

/// The seeker who posted a requirement took one of its offers. Nobody else
/// can raise this — the screen only offers the action on your own post.
final class OnOfferAccepted extends PostEvent {
  final PostDetails post;
  final PostOffer offer;

  const OnOfferAccepted(this.post, this.offer);

  @override
  List<Object> get props => [post.key, offer];
}
