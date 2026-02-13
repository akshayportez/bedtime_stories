import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimePaymentRequestReportApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchPaymentRequestReport({
    required int companyId,
    required String projectIds,
    required String status,
    required String dFrom,
    required String dTo,
    required String accountIds,
    required String categoryIds,
    required String sectionIds,
    required String userIds,
  }) {
    return _dio.post(
      BedtimeApiEndpoints.paymentRequestReportGet,
      data: {
        "nCompanyId": companyId,
        "nProjectIds": projectIds,
        "cStatus": status,
        "dFrom": dFrom,
        "dTo": dTo,
        "nAccountIds": accountIds,
        "nCategoryIds": categoryIds,
        "nSectionIds": sectionIds,
        "nUserIds": userIds,
      },
    );
  }
}
