import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentRequestUploadApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> uploadAttachment({
    required int companyId,
    required int projectId,
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
    });

    return _dio.post(
      BedtimeApiEndpoints.paymentRequestUpload,
      queryParameters: {
        "companyId": companyId,
        "projectId": projectId,
      },
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
      onSendProgress: onSendProgress,
    );
  }
}
