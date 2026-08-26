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
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
  }

  final LoginRepository _loginRepository;

  // TODO: replace with the real OTP issued by the backend.
  static const _validOtp = '111111';

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
          isOtpSent: success,
          errorMessage: success ? null : 'Invalid mobile number',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(otp: event.otp, otpError: ""));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isOtpValid) return;
    emit(state.copyWith(isLoading: true, otpError: null));
    await Future.delayed(const Duration(milliseconds: 600));
    final isValid = state.otp == _validOtp;
    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: isValid,
        otpError: isValid ? null : 'Invalid OTP',
      ),
    );
  }

  void _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(otp: '', otpError: null));
  }
}
