import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeRequestApproveApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> approveRequest({
    required Map<String, dynamic> payload,
  }) {
    return _dio.post(
      BedtimeApiEndpoints.requestApprove,
      data: payload,
    );
  }
}
