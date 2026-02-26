import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'bedtime_payment_voucher_pdf_api_provider.dart';

class BedtimePaymentVoucherPdfRepository {
  final BedtimePaymentVoucherPdfApiProvider apiProvider;

  BedtimePaymentVoucherPdfRepository(this.apiProvider);

  Future<Uint8List> getPaymentVoucherPdf({
    required int companyId,
    required int payReqId,
    int userActionId = 0,
  }) async {
    try {
      final response = await apiProvider.fetchPaymentVoucherPdf(
        companyId: companyId,
        payReqId: payReqId,
        userActionId: userActionId,
      );

      final data = response.data;
      if (data is Uint8List) return data;
      if (data is List<int>) return Uint8List.fromList(data);
      if (data is List) {
        return Uint8List.fromList(data.cast<int>());
      }

      throw Exception("Failed to load voucher PDF");
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map) {
        message = data["cMessage"]?.toString();
      } else if (data is String && data.trim().isNotEmpty) {
        message = data.trim();
      }

      throw Exception(message ?? "Failed to load voucher PDF");
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
