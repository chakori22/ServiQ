import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/me/model/saved_address.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

part 'addresses_event.dart';
part 'addresses_state.dart';

/// The seeker's saved addresses.
///
/// Thin while the list is seeded, and the seam for the endpoint that will
/// replace it — at which point the screen already has somewhere to wait.
class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final MeRepository meRepository;

  AddressesBloc({required this.meRepository})
    : super(const AddressesState.initial()) {
    on<AddressesRequested>(_onRequested);
  }

  void _onRequested(AddressesRequested event, Emitter<AddressesState> emit) {
    emit(state.copyWith(addresses: meRepository.addresses(), isLoading: false));
  }
}
