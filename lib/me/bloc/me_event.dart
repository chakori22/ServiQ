part of 'me_bloc.dart';

sealed class MeEvent extends Equatable {
  const MeEvent();
}

/// Build the account from the profile behind it. Null profile means there is
/// none on file yet, and the account falls back to what it can say without
/// one.
final class MeRequested extends MeEvent {
  final SeekerProfile? profile;

  const MeRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}
