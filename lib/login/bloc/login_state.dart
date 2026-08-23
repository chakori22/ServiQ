part of 'login_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.

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
    String? errorMessage,
    bool? isSuccess,
    bool? isOtpSent,
    String? otp,
    String? otpError,
  }) {
    return LoginState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otp: otp ?? this.otp,
      otpError: otpError ?? this.otpError,
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
