import 'package:bedtime_stories/app_ui/home/model/bedtime_request_reject_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_request_reject_api_provider.dart';

class BedtimeRequestRejectRepository {
  final BedtimeRequestRejectApiProvider apiProvider;

  BedtimeRequestRejectRepository(this.apiProvider);

  Future<BedtimeRequestRejectResponse> rejectRequest({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiProvider.rejectRequest(payload: payload);
      final rejectResponse = BedtimeRequestRejectResponse.fromJson(response.data);

      if (rejectResponse.nFlag != 1) {
        throw Exception(rejectResponse.cMessage);
      }

      return rejectResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to reject request",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
