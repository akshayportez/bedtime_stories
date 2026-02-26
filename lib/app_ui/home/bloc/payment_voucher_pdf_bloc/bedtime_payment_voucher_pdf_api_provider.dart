import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentVoucherPdfApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentVoucherPdf({
    required int companyId,
    required int payReqId,
    int userActionId = 0,
  }) {
    return _dio.get(
      "${BedtimeApiEndpoints.paymentVoucherPdf}/$payReqId",
      queryParameters: {
        "nCompanyId": companyId,
        "nUserActionId": userActionId,
      },
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
  }
}
