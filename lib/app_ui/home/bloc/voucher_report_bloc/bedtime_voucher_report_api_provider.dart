import 'package:bedtime_stories/core/api/bedtime_api_client.dart';
import 'package:bedtime_stories/core/api/bedtime_api_endpoints.dart';
import 'package:dio/dio.dart';

class BedtimeVoucherReportApiProvider {
  final Dio _dio = BedtimeApiClient().dio;

  Future<Response> fetchVoucherReport({
    required int companyId,
    required String projectIds,
    required String dFrom,
    required String dTo,
    required String accountIds,
    required String categoryIds,
    required String sectionIds,
    required String userIds,
    required String payModes,
  }) {
    return _dio.post(
      BedtimeApiEndpoints.voucherReportGet,
      data: {
        "nCompanyId": companyId,
        "nProjectIds": projectIds,
        "dFrom": dFrom,
        "dTo": dTo,
        "nAccountIds": accountIds,
        "nCategoryIds": categoryIds,
        "nSectionIds": sectionIds,
        "nUserIds": userIds,
        "cPayModes": payModes,
      },
    );
  }
}
