import 'package:dio/dio.dart';
import '../../../core/api/bedtime_api_client.dart';
import '../../../core/api/bedtime_api_endpoints.dart';

class BedtimeAuthApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> login(String username, String password) {
    return _dio.post(
      BedtimeApiEndpoints.login,
      data: {
        "cUsername": username,
        "cPassword": password,
        "nCompanyId": 1,
      },
    );
  }
}
