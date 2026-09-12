import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:local_markerplace/me/model/seeker_account.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';
import 'package:local_markerplace/onboarding/model/seeker_profile.dart';
import 'package:local_markerplace/visit/repository/visit_repository.dart';

part 'me_event.dart';
part 'me_state.dart';

/// The Me tab's account.
///
/// The rows count real things — orders booked, chats unread, providers saved
/// — so the account is rebuilt whenever a cart is, rather than only when the
/// tab happens to be built again.
class MeBloc extends Bloc<MeEvent, MeState> {
  final MeRepository meRepository;
  final VisitRepository visitRepository;

  late final StreamSubscription<void> _changes;

  MeBloc({required this.meRepository, required this.visitRepository})
    : super(const MeState.initial()) {
    on<MeRequested>(_onRequested);

    _changes = visitRepository.changes.listen((_) {
      if (!isClosed) add(MeRequested(state.profile));
    });
  }

  @override
  Future<void> close() {
    _changes.cancel();
    return super.close();
  }

  void _onRequested(MeRequested event, Emitter<MeState> emit) {
    emit(
      state.copyWith(
        profile: event.profile,
        account: meRepository.account(profile: event.profile),
        isLoading: false,
      ),
    );
  }
}
