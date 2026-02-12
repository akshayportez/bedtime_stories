import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentVoucherSaveApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> savePaymentVoucher({
    required Map<String, dynamic> payload,
  }) {
    return _dio.post(
      BedtimeApiEndpoints.paymentVoucherSave,
      data: payload,
    );
  }
}
