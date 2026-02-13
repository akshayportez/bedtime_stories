import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentVoucherApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentVouchers({
    required int companyId,
    required int projectId,
    required int userActionId,
    String search = "",
    String statusFilter = "",
    String dFrom = "",
    String dTo = "",
  }) {
    return _dio.get(
      BedtimeApiEndpoints.paymentVoucher,
      queryParameters: {
        "nCompanyId": companyId,
        "nProjectId": projectId,
        "nUserActionId": userActionId,
        "search": search,
        "statusFilter": statusFilter,
        "dFrom": dFrom,
        "dTo": dTo,
      },
    );
  }
}
