import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:local_markerplace/discovery/model/home_feed.dart';
import 'package:local_markerplace/network/api_client.dart';
import 'package:local_markerplace/network/api_response.dart';
import 'package:local_markerplace/network/failure.dart';

/// What home needs to draw itself.
///
/// An interface rather than the concrete repository so a screen can be
/// pumped against a canned feed — a test that reaches the network is not a
/// test of the screen.
abstract class HomeSource {
  Future<Either<Failure, HomeFeed>> home({required String localitySlug});
}

/// Home's feed, from the server.
///
/// One request carries the whole screen — the area, its categories and the
/// providers working in it — so home has a single thing to wait on and a
/// single thing to fail.
class HomeRepository implements HomeSource {
  const HomeRepository({required this.apiClient});

  final APIClient apiClient;

  static const _homePath = '/api/v1/user/home';

  /// The query parameter the endpoint reads. Anything else is ignored and
  /// the server quietly answers for its default area, which is worse than an
  /// error — hence the name being pinned here rather than inlined.
  static const _localityParam = 'locality';

  /// The area's slug, as the endpoint insists on it: lowercase, hyphenated,
  /// nothing else. It matches exactly — "Ajnara Gen X", "ajnara gen x" and
  /// "AJNARA-GEN-X" are all LOCALITY_NOT_FOUND, and only "ajnara-gen-x"
  /// answers — so the conversion belongs here, where every caller goes
  /// through it, rather than in whichever screen happens to be asking.
  static String slugFor(String locality) => locality
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  /// How long home waits before calling it a failure.
  ///
  /// The client's default is two minutes, which for a screen the seeker is
  /// staring at is not a wait but a hang — they would sit in front of a
  /// skeleton with no way to know it had stopped going anywhere. Ten seconds
  /// is long enough for a slow connection and short enough to be honest.
  static const _timeout = Duration(seconds: 10);

  @override
  Future<Either<Failure, HomeFeed>> home({required String localitySlug}) async {
    try {
      final data = await apiClient.get(
        _homePath,
        // Slugged on the way out, so a caller handing over a display name
        // gets the area rather than a not-found.
        queryParameters: {_localityParam: slugFor(localitySlug)},
        options: Options(receiveTimeout: _timeout, sendTimeout: _timeout),
      );

      if (data is! Map<String, dynamic>) {
        return const Left(
          Failure(
            errorMessage: 'Unexpected response from the server.',
            errorCode: 'MALFORMED_RESPONSE',
          ),
        );
      }

      final response = ApiResponse.fromJson(data, HomeFeed.fromJson);
      final feed = response.responseData;
      if (!response.isSuccess || feed == null) {
        return Left(response.toFailure());
      }
      return Right(feed);
    } on DioException catch (e) {
      return Left(failureFromDioException(e));
    } catch (e) {
      return Left(Failure(errorMessage: e.toString()));
    }
  }
}
