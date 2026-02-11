import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeGetTaxListApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchTaxes({required int companyId}) {
    return _dio.get(
      BedtimeApiEndpoints.taxList,
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }
}
