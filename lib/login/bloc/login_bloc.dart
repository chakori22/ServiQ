import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // Ensure `equatable` is added to pubspec.yaml dependencies and run `flutter pub get`.

import '../repository/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginRepository loginRepository})
    : _loginRepository = loginRepository,
      super(const LoginState.initial()) {
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginRepository _loginRepository;

  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(mobileNumber: event.mobileNumber));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isMobileNumberValid) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final success = await _loginRepository.login(state.mobileNumber);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: success,
          errorMessage: success ? null : 'Invalid mobile number',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
