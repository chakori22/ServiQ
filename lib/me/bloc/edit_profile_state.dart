part of 'edit_profile_bloc.dart';

class EditProfileState extends Equatable {
  final String name;
  final Set<String> interests;

  const EditProfileState({required this.name, required this.interests});

  const EditProfileState.initial({this.name = '', this.interests = const {}});

  EditProfileState copyWith({String? name, Set<String>? interests}) {
    return EditProfileState(
      name: name ?? this.name,
      interests: interests ?? this.interests,
    );
  }

  /// A profile with no name on it is not a saved profile.
  bool get canSave => name.trim().isNotEmpty;

  @override
  List<Object?> get props => [name, interests];
}
