part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();
}

final class OnFetchPostDetails extends PostEvent {
  const OnFetchPostDetails();

  @override
  List<Object> get props => [];
}
