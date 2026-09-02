part of 'login_bloc.dart';

// Sentinel so copyWith can tell "not passed" apart from an explicit null.
// Without it a nullable field could only ever be set, never cleared, so a
// stale error would survive the next successful attempt.
const _unset = Object();

class LoginState extends Equatable {
  final String mobileNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final bool isOtpSent;
  final String otp;
  final String? otpError;

  /// Dialling code sent alongside the number; the UI only offers India today.
  final String countryCode;

  /// Cooldown the server told us to enforce before another OTP may be asked
  /// for. Zero until the first successful request comes back.
  final int resendAfterSeconds;

  /// Lifetime of the OTP currently in play, per the server.
  final int expiresInSeconds;

  /// When the most recent OTP was successfully issued. The OTP screen keys its
  /// countdown off this, so a resend that returns the same cooldown still
  /// registers as a distinct state and restarts the timer.
  final DateTime? lastOtpSentAt;

  /// OTP echoed back by the backend while it runs with the `log` provider,
  /// where nothing is actually delivered to the handset. Null in production.
  final String? devOtp;

  const LoginState({
    required this.mobileNumber,
    required this.isLoading,
    required this.errorMessage,
    required this.isSuccess,
    required this.isOtpSent,
    required this.otp,
    required this.otpError,
    required this.countryCode,
    required this.resendAfterSeconds,
    required this.expiresInSeconds,
    required this.lastOtpSentAt,
    required this.devOtp,
  });

  const LoginState.initial({
    this.mobileNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isOtpSent = false,
    this.otp = '',
    this.otpError,
    this.countryCode = '+91',
    this.resendAfterSeconds = 0,
    this.expiresInSeconds = 0,
    this.lastOtpSentAt,
    this.devOtp,
  });

  LoginState copyWith({
    String? mobileNumber,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? isSuccess,
    bool? isOtpSent,
    String? otp,
    Object? otpError = _unset,
    String? countryCode,
    int? resendAfterSeconds,
    int? expiresInSeconds,
    DateTime? lastOtpSentAt,
    Object? devOtp = _unset,
  }) {
    return LoginState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otp: otp ?? this.otp,
      otpError: otpError == _unset ? this.otpError : otpError as String?,
      countryCode: countryCode ?? this.countryCode,
      resendAfterSeconds: resendAfterSeconds ?? this.resendAfterSeconds,
      expiresInSeconds: expiresInSeconds ?? this.expiresInSeconds,
      lastOtpSentAt: lastOtpSentAt ?? this.lastOtpSentAt,
      devOtp: devOtp == _unset ? this.devOtp : devOtp as String?,
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
    countryCode,
    resendAfterSeconds,
    expiresInSeconds,
    lastOtpSentAt,
    devOtp,
  ];

  bool get isMobileNumberValid => mobileNumber.length == 10;
  bool get isOtpValid => otp.length == 6;
}
