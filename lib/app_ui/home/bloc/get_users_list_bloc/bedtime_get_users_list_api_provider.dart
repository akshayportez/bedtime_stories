import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeGetUsersListApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchUsers({
    required int companyId,
    String search = "",
  }) {
    return _dio.get(
      BedtimeApiEndpoints.userList,
      queryParameters: {
        "nCompanyId": companyId,
        "search": search,
      },
    );
  }
}
