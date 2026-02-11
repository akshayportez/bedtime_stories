import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_detail_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_request_detail_api_provider.dart';

class BedtimePaymentRequestDetailRepository {
  final BedtimePaymentRequestDetailApiProvider apiProvider;

  BedtimePaymentRequestDetailRepository(this.apiProvider);

  Future<BedtimePaymentRequestDetailResponse> getPaymentRequestDetail({
    required int companyId,
    required int payReqId,
  }) async {
    try {
      final response = await apiProvider.fetchPaymentRequestDetail(
        companyId: companyId,
        payReqId: payReqId,
      );

      final detailResponse =
          BedtimePaymentRequestDetailResponse.fromJson(response.data);

      if (detailResponse.nFlag != 1) {
        throw Exception(detailResponse.cMessage);
      }

      return detailResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load request details",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }

  Future<void> deletePaymentRequest({
    required int companyId,
    required int payReqId,
  }) async {
    try {
      final response = await apiProvider.deletePaymentRequest(
        companyId: companyId,
        payReqId: payReqId,
      );

      if ((response.data?["nFlag"] ?? 0) != 1) {
        throw Exception(response.data?["cMessage"] ?? "Delete failed");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to delete request",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
