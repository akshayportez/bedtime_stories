import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_voucher_api_provider.dart';

class BedtimePaymentVoucherRepository {
  final BedtimePaymentVoucherApiProvider apiProvider;

  BedtimePaymentVoucherRepository(this.apiProvider);

  Future<List<BedtimePaymentVoucher>> getPaymentVouchers({
    required int companyId,
    required int projectId,
    required int userActionId,
    String search = "",
    String statusFilter = "",
    String dFrom = "",
    String dTo = "",
  }) async {
    try {
      final response = await apiProvider.fetchPaymentVouchers(
        companyId: companyId,
        projectId: projectId,
        userActionId: userActionId,
        search: search,
        statusFilter: statusFilter,
        dFrom: dFrom,
        dTo: dTo,
      );

      final paymentResponse =
          BedtimePaymentVoucherResponse.fromJson(response.data);

      if (paymentResponse.nFlag != 1) {
        throw Exception(paymentResponse.cMessage);
      }

      return paymentResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load vouchers",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
