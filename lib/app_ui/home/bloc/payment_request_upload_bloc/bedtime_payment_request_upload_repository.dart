import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_upload_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_request_upload_api_provider.dart';

class BedtimePaymentRequestUploadRepository {
  final BedtimePaymentRequestUploadApiProvider apiProvider;

  BedtimePaymentRequestUploadRepository(this.apiProvider);

  Future<BedtimePaymentRequestUploadResponse> uploadAttachment({
    required int companyId,
    required int projectId,
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await apiProvider.uploadAttachment(
        companyId: companyId,
        projectId: projectId,
        filePath: filePath,
        fileName: fileName,
        onSendProgress: onSendProgress,
      );

      final uploadResponse =
          BedtimePaymentRequestUploadResponse.fromJson(response.data);

      if (uploadResponse.nFlag != 1) {
        throw Exception(uploadResponse.cMessage);
      }

      return uploadResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to upload attachment",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
