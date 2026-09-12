part of 'edit_profile_bloc.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();
}

/// Fill the form from the account it is editing.
final class EditProfileOpened extends EditProfileEvent {
  final SeekerAccount account;

  const EditProfileOpened(this.account);

  @override
  List<Object> get props => [account];
}

final class ProfileNameChanged extends EditProfileEvent {
  final String name;

  const ProfileNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

final class InterestToggled extends EditProfileEvent {
  final String label;

  const InterestToggled(this.label);

  @override
  List<Object> get props => [label];
}
