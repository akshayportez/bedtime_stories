import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentRequestDetailApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentRequestDetail({
    required int companyId,
    required int payReqId,
  }) {
    return _dio.get(
      "${BedtimeApiEndpoints.paymentRequest}/$payReqId",
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }

  Future<Response> deletePaymentRequest({
    required int companyId,
    required int payReqId,
  }) {
    return _dio.delete(
      "${BedtimeApiEndpoints.paymentRequest}/$payReqId",
      queryParameters: {
        "nCompanyId": companyId,
      },
    );
  }
}
