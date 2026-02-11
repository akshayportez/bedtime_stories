import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_save_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_request_save_api_provider.dart';

class BedtimePaymentRequestSaveRepository {
  final BedtimePaymentRequestSaveApiProvider apiProvider;

  BedtimePaymentRequestSaveRepository(this.apiProvider);

  Future<BedtimePaymentRequestSaveResponse> savePaymentRequest({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiProvider.savePaymentRequest(payload: payload);
      final saveResponse =
          BedtimePaymentRequestSaveResponse.fromJson(response.data);

      if (saveResponse.nFlag != 1) {
        throw Exception(saveResponse.cMessage);
      }

      return saveResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to save request",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
