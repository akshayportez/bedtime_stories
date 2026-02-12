import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_detail_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_voucher_detail_api_provider.dart';

class BedtimePaymentVoucherDetailRepository {
  final BedtimePaymentVoucherDetailApiProvider apiProvider;

  BedtimePaymentVoucherDetailRepository(this.apiProvider);

  Future<BedtimePaymentVoucherDetailResponse> getPaymentVoucherDetail({
    required int companyId,
    required int payReqId,
  }) async {
    try {
      final response = await apiProvider.fetchPaymentVoucherDetail(
        companyId: companyId,
        payReqId: payReqId,
      );

      final detailResponse =
          BedtimePaymentVoucherDetailResponse.fromJson(response.data);

      if (detailResponse.nFlag != 1) {
        throw Exception(detailResponse.cMessage);
      }

      return detailResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load voucher details",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
