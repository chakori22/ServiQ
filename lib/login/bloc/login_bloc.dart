import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // Ensure `equatable` is added to pubspec.yaml dependencies and run `flutter pub get`.

import '../../core/device_identity.dart';
import '../../network/auth_session.dart';
import '../repository/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;
  final AuthSession authSession;
  final DeviceIdentity deviceIdentity;

  LoginBloc({
    required this.loginRepository,
    required this.authSession,
    required this.deviceIdentity,
  }) : super(const LoginState.initial()) {
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<CountryCodeChanged>(_onCountryCodeChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
  }

  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(mobileNumber: event.mobileNumber));
  }

  void _onCountryCodeChanged(
    CountryCodeChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(countryCode: event.countryCode));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isMobileNumberValid || state.isLoading) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await _requestOtp(emit);
  }

  /// Shared by the first request and every resend — the backend uses one
  /// endpoint for both and enforces the cooldown itself.
  Future<void> _requestOtp(Emitter<LoginState> emit) async {
    final result = await loginRepository.requestOtp(
      countryCode: state.countryCode,
      phoneNumber: state.mobileNumber,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.errorMessage),
      ),
      (otp) => emit(
        state.copyWith(
          isLoading: false,
          isOtpSent: true,
          errorMessage: null,
          resendAfterSeconds: otp.resendAfterSeconds,
          expiresInSeconds: otp.expiresInSeconds,
          lastOtpSentAt: DateTime.now(),
          devOtp: otp.devOtp,
        ),
      ),
    );
  }

  void _onOtpChanged(OtpChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(otp: event.otp, otpError: null));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isOtpValid || state.isLoading) return;
    emit(state.copyWith(isLoading: true, otpError: null));

    final result = await loginRepository.verifyOtp(
      countryCode: state.countryCode,
      phoneNumber: state.mobileNumber,
      otp: state.otp,
      deviceId: deviceIdentity.deviceId,
    );

    await result.fold(
      // The server's message carries the remaining attempt count, so it is
      // shown as-is rather than replaced with a generic "Invalid OTP".
      (failure) async => emit(
        state.copyWith(isLoading: false, otpError: failure.errorMessage),
      ),
      (verified) async {
        await authSession.save(tokens: verified.tokens, user: verified.user);
        emit(state.copyWith(isLoading: false, isSuccess: true, otpError: null));
      },
    );
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        isLoading: true,
        otp: '',
        otpError: null,
        errorMessage: null,
      ),
    );
    await _requestOtp(emit);
  }
}
