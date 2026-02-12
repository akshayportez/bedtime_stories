import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeGetBankListApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchBanks({required int companyId}) {
    return _dio.get(
      BedtimeApiEndpoints.bankList,
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }
}
