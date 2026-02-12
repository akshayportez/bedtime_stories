import 'package:bedtime_stories/app_ui/home/model/bedtime_request_approve_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_request_approve_api_provider.dart';

class BedtimeRequestApproveRepository {
  final BedtimeRequestApproveApiProvider apiProvider;

  BedtimeRequestApproveRepository(this.apiProvider);

  Future<BedtimeRequestApproveResponse> approveRequest({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiProvider.approveRequest(payload: payload);
      final approveResponse =
          BedtimeRequestApproveResponse.fromJson(response.data);

      if (approveResponse.nFlag != 1) {
        throw Exception(approveResponse.cMessage);
      }

      return approveResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to approve request",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
