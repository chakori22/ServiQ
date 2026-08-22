part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String mobileNumber;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const LoginState({
    required this.mobileNumber,
    required this.isLoading,
    required this.errorMessage,
    required this.isSuccess,
  });

  const LoginState.initial({
    this.mobileNumber = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  LoginState copyWith({
    String? mobileNumber,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [mobileNumber, isLoading, errorMessage, isSuccess];

  bool get isMobileNumberValid => mobileNumber.length == 10;
}
