import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_save_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_voucher_save_api_provider.dart';

class BedtimePaymentVoucherSaveRepository {
  final BedtimePaymentVoucherSaveApiProvider apiProvider;

  BedtimePaymentVoucherSaveRepository(this.apiProvider);

  Future<BedtimePaymentVoucherSaveResponse> savePaymentVoucher({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiProvider.savePaymentVoucher(payload: payload);
      final saveResponse =
          BedtimePaymentVoucherSaveResponse.fromJson(response.data);

      if (saveResponse.nFlag != 1) {
        throw Exception(saveResponse.cMessage);
      }

      return saveResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to save voucher",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
