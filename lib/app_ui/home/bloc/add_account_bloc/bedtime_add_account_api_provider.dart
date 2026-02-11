import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeAddAccountApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> saveAccount({
    required Map<String, dynamic> payload,
  }) {
    return _dio.post(
      BedtimeApiEndpoints.accountSave,
      data: payload,
    );
  }
}
