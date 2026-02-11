import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeGetAccountsListApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchAccounts({required int companyId}) {
    return _dio.get(
      BedtimeApiEndpoints.accountList,
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }
}

