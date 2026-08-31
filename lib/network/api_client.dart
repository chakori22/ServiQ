import 'dart:async';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

const _defaultConnectTimeout = Duration(minutes: 2);
const _defaultReceiveTimeout = Duration(minutes: 2);

class APIClient {
  final String baseUrl;
  late Dio dio;
  static APIClient? _instance;
  final List<Interceptor> interceptors = [];
  factory APIClient({required String baseUrl}) {
    _instance ??= APIClient._internal(baseUrl: baseUrl);
    return _instance!;
  }

  APIClient._internal({required this.baseUrl}) {
    dio = DioForBrowser();
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..options.headers = {'Content-Type': 'application/json'};

    final adapter = HttpClientAdapter() as BrowserHttpClientAdapter;
    adapter.withCredentials = true;
    dio.httpClientAdapter = adapter;
    if (interceptors.isNotEmpty) {
      dio.interceptors.addAll(interceptors);
    }
  }

  Options createOptions({
    String? method,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    bool? preserveHeaderCase,
    bool? followRedirects,
    ResponseType? responseType,
    String? contentType,
    bool Function(int?)? validateStatus,
    bool? receiveDataWhenStatusError,
    int? maxRedirects,
    bool? persistentConnection,
    FutureOr<List<int>> Function(String, RequestOptions)? requestEncoder,
    FutureOr<String?> Function(List<int>, RequestOptions, ResponseBody?)?
    responseDecoder,
    ListFormat? listFormat,
  }) {
    return Options(
      method: method,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: extra,
      headers: headers,
      preserveHeaderCase: preserveHeaderCase,
      followRedirects: followRedirects,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      maxRedirects: maxRedirects,
      persistentConnection: persistentConnection,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder,
      listFormat: listFormat,
    );
  }

  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> post(
    String uri, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        uri,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> put(
    String uri, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        uri,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  // Removed the public constructor as we now use the factory constructor and internal constructor.
}
