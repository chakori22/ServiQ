import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:local_markerplace/network/api_client.dart';
import 'package:local_markerplace/network/api_response.dart';
import 'package:local_markerplace/network/failure.dart';

import '../model/auth_tokens.dart';
import '../model/otp_request_result.dart';
import '../model/verify_otp_result.dart';

class LoginRepository {
  final APIClient apiClient;

  const LoginRepository({required this.apiClient});

  static const _otpRequestPath = '/api/v1/auth/otp/request';
  static const _otpVerifyPath = '/api/v1/auth/otp/verify';
  static const _tokenRefreshPath = '/api/v1/auth/token/refresh';
  static const _logoutPath = '/api/v1/auth/logout';
  static const _logoutAllPath = '/api/v1/auth/logout-all';

  /// Identifies this app to the backend. The only client type the Flutter app
  /// ever sends.
  static const _clientType = 'MOBILE';

  /// Asks the backend to issue an OTP for [phoneNumber].
  ///
  /// Also used for resends — the endpoint is the same, and the server enforces
  /// the cooldown itself, answering 429 / `OTP_RESEND_TOO_SOON` when a resend
  /// comes too early.
  Future<Either<Failure, OtpRequestResult>> requestOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      final data = await apiClient.post(
        _otpRequestPath,
        data: {'countryCode': countryCode, 'phoneNumber': phoneNumber},
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse.fromJson(data, OtpRequestResult.fromJson);
      final result = response.responseData;
      if (!response.isSuccess || result == null) {
        return Left(response.toFailure());
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }

  /// Exchanges a correct OTP for an access/refresh token pair and the user.
  ///
  /// A wrong code comes back as `INVALID_OTP` with the remaining attempts in
  /// the message, which is passed through to the UI verbatim so the user can
  /// see the count come down.
  Future<Either<Failure, VerifyOtpResult>> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
    required String deviceId,
  }) async {
    try {
      final data = await apiClient.post(
        _otpVerifyPath,
        data: {
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
          'otp': otp,
          'deviceId': deviceId,
          'clientType': _clientType,
        },
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse.fromJson(data, VerifyOtpResult.fromJson);
      final result = response.responseData;
      if (!response.isSuccess || result == null) {
        return Left(response.toFailure());
      }
      return Right(result);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }

  /// Trades a refresh token for a new token pair.
  ///
  /// The backend rotates on every call: the returned refresh token replaces
  /// the one sent, and replaying a spent token is treated as theft and ends
  /// the session (`REFRESH_TOKEN_REUSED`). Callers must therefore persist the
  /// new token before it is used again, and never run two refreshes at once.
  ///
  /// Unlike verification, the response carries tokens only — no user.
  Future<Either<Failure, AuthTokens>> refreshTokens({
    required String refreshToken,
    required String deviceId,
  }) async {
    try {
      final data = await apiClient.post(
        _tokenRefreshPath,
        data: {'refreshToken': refreshToken, 'deviceId': deviceId},
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse.fromJson(data, AuthTokens.fromJson);
      final tokens = response.responseData;
      if (!response.isSuccess || tokens == null) {
        return Left(response.toFailure());
      }
      return Right(tokens);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }

  /// Retires the session on the server.
  ///
  /// The refresh token is the credential being revoked, so it is what the
  /// endpoint takes — the access token that rides along in the header is
  /// incidental and may well have expired already. The response carries no
  /// data, only the envelope, so success is the absence of an error code.
  Future<Either<Failure, Unit>> logout({required String refreshToken}) async {
    try {
      final data = await apiClient.post(
        _logoutPath,
        data: {'refreshToken': refreshToken},
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse<void>.fromJson(data, null);
      if (!response.isSuccess) return Left(response.toFailure());
      return const Right(unit);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }

  /// Retires every session the account has, not only this device's.
  ///
  /// Takes the same credential as [logout] — the refresh token identifies the
  /// account whose sessions are being revoked — but answers with how many
  /// there were, so the user can be told what actually happened rather than a
  /// flat "signed out".
  ///
  /// A missing or unreadable count is reported as zero rather than as a
  /// failure: the sessions are gone either way, and the number is only there
  /// to be shown.
  Future<Either<Failure, int>> logoutAll({required String refreshToken}) async {
    try {
      final data = await apiClient.post(
        _logoutAllPath,
        data: {'refreshToken': refreshToken},
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse<int>.fromJson(
        data,
        (payload) => payload['revokedSessions'] as int? ?? 0,
      );
      if (!response.isSuccess) return Left(response.toFailure());
      return Right(response.responseData ?? 0);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }
}
