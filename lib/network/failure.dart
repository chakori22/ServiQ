import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String errorMessage;
  final String? errorCode;

  const Failure({String? errorMessage, this.errorCode})
    : errorMessage = errorMessage ?? 'An unknown error occurred';

  @override
  String toString() {
    return errorMessage;
  }

  @override
  List<Object> get props => [errorMessage, errorCode ?? ''];
}
