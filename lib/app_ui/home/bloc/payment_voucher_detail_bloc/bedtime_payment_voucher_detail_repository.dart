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

  Future<void> deletePaymentVoucher({
    required int companyId,
    required int payReqId,
    required int userActionId,
  }) async {
    try {
      final response = await apiProvider.deletePaymentVoucher(
        companyId: companyId,
        payReqId: payReqId,
        userActionId: userActionId,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Failed to delete voucher");
      }

      final nFlag = data["nFlag"];
      final resolvedFlag = nFlag is int
          ? nFlag
          : int.tryParse(nFlag?.toString() ?? "") ?? 0;
      final message = (data["cMessage"] ?? "").toString();

      if (resolvedFlag != 1) {
        throw Exception(message.isEmpty ? "Failed to delete voucher" : message);
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to delete voucher",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
