import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentVoucherDetailApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentVoucherDetail({
    required int companyId,
    required int payReqId,
  }) {
    return _dio.get(
      "${BedtimeApiEndpoints.paymentVoucherByRequest}/$payReqId",
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }
}
