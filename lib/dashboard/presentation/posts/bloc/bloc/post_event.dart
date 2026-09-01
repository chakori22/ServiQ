part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();
}

final class OnFetchPostDetails extends PostEvent {
  const OnFetchPostDetails();

  @override
  List<Object> get props => [];
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
