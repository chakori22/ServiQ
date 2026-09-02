part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
}

final class MobileNumberChanged extends LoginEvent {
  final String mobileNumber;

  const MobileNumberChanged(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

final class CountryCodeChanged extends LoginEvent {
  final String countryCode;

  const CountryCodeChanged(this.countryCode);

  @override
  List<Object> get props => [countryCode];
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();

  @override
  List<Object> get props => [];
}

final class OtpChanged extends LoginEvent {
  final String otp;

  const OtpChanged(this.otp);

  @override
  List<Object> get props => [otp];
}

final class OtpSubmitted extends LoginEvent {
  const OtpSubmitted();

  @override
  List<Object> get props => [];
}

final class OtpResendRequested extends LoginEvent {
  const OtpResendRequested();

  @override
  List<Object> get props => [];
}
