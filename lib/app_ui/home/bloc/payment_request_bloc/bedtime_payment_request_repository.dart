import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_request_api_provider.dart';

class BedtimePaymentRequestRepository {
  final BedtimePaymentRequestApiProvider apiProvider;

  BedtimePaymentRequestRepository(this.apiProvider);

  Future<List<BedtimePaymentRequest>> getPaymentRequests({
    required int companyId,
    required int projectId,
    required int userActionId,
    String search = "",
    String statusFilter = "",
    String cStatus = "",
    String dFrom = "",
    String dTo = "",
  }) async {
    try {
      final response = await apiProvider.fetchPaymentRequests(
        companyId: companyId,
        projectId: projectId,
        userActionId: userActionId,
        search: search,
        statusFilter: statusFilter,
        cStatus: cStatus,
        dFrom: dFrom,
        dTo: dTo,
      );

      final paymentResponse =
          BedtimePaymentRequestResponse.fromJson(response.data);

      if (paymentResponse.nFlag != 1) {
        throw Exception(paymentResponse.cMessage);
      }

      return paymentResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load requests",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
