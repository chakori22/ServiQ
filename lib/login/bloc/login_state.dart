part of 'login_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.
const _unset = Object();

class LoginState extends Equatable {
  final String mobileNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final bool isOtpSent;
  final String otp;
  final String? otpError;

  const LoginState({
    required this.mobileNumber,
    required this.isLoading,
    required this.errorMessage,
    required this.isSuccess,
    required this.isOtpSent,
    required this.otp,
    required this.otpError,
  });

  const LoginState.initial({
    this.mobileNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isOtpSent = false,
    this.otp = '',
    this.otpError,
  });

  LoginState copyWith({
    String? mobileNumber,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? isSuccess,
    bool? isOtpSent,
    String? otp,
    Object? otpError = _unset,
  }) {
    return LoginState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otp: otp ?? this.otp,
      otpError: identical(otpError, _unset)
          ? this.otpError
          : otpError as String?,
    );
  }

  @override
  List<Object?> get props => [
    mobileNumber,
    isLoading,
    errorMessage,
    isSuccess,
    isOtpSent,
    otp,
    otpError,
  ];

  bool get isMobileNumberValid => mobileNumber.length == 10;
  bool get isOtpValid => otp.length == 6;
}
