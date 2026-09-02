import 'package:dio/dio.dart';

import 'failure.dart';

/// The envelope every ServiQ endpoint wraps its payload in.
///
/// Both success and error bodies share this shape — a failure is signalled by
/// a non-null [errorCode], and [responseData] may still carry detail (a 429
/// resend rejection, for example, returns `retryAfterSeconds`).
class ApiResponse<T> {
  final String responseCode;
  final String? errorCode;
  final String responseMessage;
  final DateTime? responseTime;
  final T? responseData;

  const ApiResponse({
    required this.responseCode,
    required this.errorCode,
    required this.responseMessage,
    required this.responseTime,
    required this.responseData,
  });

  bool get isSuccess => errorCode == null;

  /// [parseData] is skipped when `responseData` is null, which is how error
  /// bodies such as VALIDATION_ERROR come back.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> data)? parseData,
  ) {
    final data = json['responseData'];
    final rawTime = json['responseTime'] as String?;
    return ApiResponse(
      responseCode: json['responseCode'] as String? ?? '',
      errorCode: json['errorCode'] as String?,
      responseMessage: json['responseMessage'] as String? ?? '',
      responseTime: rawTime == null ? null : DateTime.tryParse(rawTime),
      responseData: (data is Map<String, dynamic> && parseData != null)
          ? parseData(data)
          : null,
    );
  }

  Failure toFailure() =>
      Failure(errorMessage: responseMessage, errorCode: errorCode);
}

/// Turns a thrown [DioException] into a [Failure].
///
/// Dio rejects non-2xx before we get to parse anything, but the server still
/// sends the envelope in the error body — so prefer the server's own message
/// over a generic transport one whenever it is there.
Failure failureFromDioException(DioException exception) {
  final data = exception.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['responseMessage'] as String?;
    if (message != null && message.isNotEmpty) {
      return Failure(
        errorMessage: message,
        errorCode: data['errorCode'] as String?,
      );
    }
  }
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const Failure(
      errorMessage: 'The request timed out. Please try again.',
      errorCode: 'TIMEOUT',
    ),
    DioExceptionType.connectionError => const Failure(
      errorMessage: 'No internet connection. Please check your network.',
      errorCode: 'CONNECTION_ERROR',
    ),
    _ => Failure(errorMessage: exception.message, errorCode: 'NETWORK_ERROR'),
  };
}
