import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/me/model/kyc_document.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';

/// Identity verification: what has been submitted, and what is being
/// submitted now.
///
/// The upload form lives here rather than in the page for the reason the
/// login form does — which document, and which sides of it have been added,
/// is what decides whether the submission can go, and that decision should
/// not be spread across a widget's fields.
class KycBloc extends Bloc<KycEvent, KycState> {
  final MeRepository meRepository;

  KycBloc({required this.meRepository}) : super(const KycState.initial()) {
    on<KycRequested>(_onRequested);
    on<KycTypeSelected>(_onTypeSelected);
    on<KycSideChanged>(_onSideChanged);
  }

  void _onRequested(KycRequested event, Emitter<KycState> emit) {
    final types = meRepository.documentTypes();
    emit(
      state.copyWith(
        documents: meRepository.documents(),
        types: types,
        type: types.isEmpty ? '' : types.first,
        isLoading: false,
      ),
    );
  }

  void _onTypeSelected(KycTypeSelected event, Emitter<KycState> emit) {
    emit(state.copyWith(type: event.type));
  }

  void _onSideChanged(KycSideChanged event, Emitter<KycState> emit) {
    emit(switch (event.side) {
      KycSide.front => state.copyWith(hasFront: event.isAdded),
      KycSide.back => state.copyWith(hasBack: event.isAdded),
    });
  }
}
