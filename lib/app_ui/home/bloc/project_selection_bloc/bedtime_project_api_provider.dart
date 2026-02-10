import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeProjectApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchProjects({
    required int companyId,
    required int userId,
    String search = "",
  }) {
    return _dio.get(
      BedtimeApiEndpoints.projectList,
      queryParameters: {
        "nCompanyId": companyId,
        "search": search,
        "nUserId": userId,
      },
    );
  }
}
