part of 'your_post_bloc.dart';

sealed class YourPostEvent extends Equatable {
  const YourPostEvent();
}

final class OnFetchPostDetails extends YourPostEvent {
  const OnFetchPostDetails();

  @override
  List<Object> get props => [];
}
