import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentRequestApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentRequests({
    required int companyId,
    required int projectId,
    required int userActionId,
    String search = "",
    String statusFilter = "",
    String cStatus = "",
    String dFrom = "",
    String dTo = "",
  }) {
    return _dio.get(
      BedtimeApiEndpoints.paymentRequest,
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
      queryParameters: {
        "nCompanyId": companyId,
        "nProjectId": projectId,
        "nUserActionId": userActionId,
        "search": search,
        "statusFilter": statusFilter,
        "cStatus": cStatus,
        "dFrom": dFrom,
        "dTo": dTo,
      },
    );
  }
}
