import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/me/model/saved_provider.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

part 'saved_providers_event.dart';
part 'saved_providers_state.dart';

/// The providers the seeker has kept, and the three ways of narrowing them.
class SavedProvidersBloc
    extends Bloc<SavedProvidersEvent, SavedProvidersState> {
  final MeRepository meRepository;

  SavedProvidersBloc({required this.meRepository})
    : super(const SavedProvidersState.initial()) {
    on<SavedProvidersRequested>(_onRequested);
    on<SavedFilterSelected>(_onFilterSelected);
  }

  void _onRequested(
    SavedProvidersRequested event,
    Emitter<SavedProvidersState> emit,
  ) {
    emit(
      state.copyWith(
        providers: meRepository.savedProviders(),
        localityName: event.localityName,
        isLoading: false,
      ),
    );
  }

  void _onFilterSelected(
    SavedFilterSelected event,
    Emitter<SavedProvidersState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }
}
