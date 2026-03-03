String getApiClientTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    // Basic error handling logic
    return Exception(e.message ?? 'An unknown network error occurred');
  }
}
""";

String getDioFactoryTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class DioFactory {
  static Dio getDio() {
    Dio dio = Dio();

    dio.options
      ..baseUrl = AppConfig.baseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.add(sl<AppInterceptor>());
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ));

    return dio;
  }
}
""";

String getAppInterceptorTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Add auth tokens or custom headers here
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Centralized error handling
    super.onError(err, handler);
  }
}
""";

String getApiServiceTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;
}
""";

String getApiConstantsTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class ApiConstants {
  static const String baseUrl = 'https://api.example.com/';
}
""";

String getFailureTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
""";

String getNetworkInfoTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.none) == false;
  }
}
""";
