import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/me/model/seeker_account.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// The profile form: the name being typed and the interests being picked.
///
/// Held here rather than in the widget for the reason the login form is —
/// what is in the fields is what decides whether Save can be pressed, and
/// that is state, not decoration.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState.initial()) {
    on<EditProfileOpened>(_onOpened);
    on<ProfileNameChanged>(_onNameChanged);
    on<InterestToggled>(_onInterestToggled);
  }

  void _onOpened(EditProfileOpened event, Emitter<EditProfileState> emit) {
    emit(
      state.copyWith(
        name: event.account.name,
        // Only the interests this app knows about, spelled as the chips do.
        interests: seekerServiceInterests
            .where(
              (interest) => event.account.interests.contains(interest.label),
            )
            .map((interest) => interest.label)
            .toSet(),
      ),
    );
  }

  void _onNameChanged(
    ProfileNameChanged event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onInterestToggled(
    InterestToggled event,
    Emitter<EditProfileState> emit,
  ) {
    final chosen = {...state.interests};
    if (!chosen.remove(event.label)) chosen.add(event.label);
    emit(state.copyWith(interests: chosen));
  }
}
