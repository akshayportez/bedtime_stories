import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_report_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_payment_request_report_api_provider.dart';

class BedtimePaymentRequestReportRepository {
  final BedtimePaymentRequestReportApiProvider apiProvider;

  BedtimePaymentRequestReportRepository(this.apiProvider);

  Future<List<BedtimePaymentRequestReportRow>> getPaymentRequestReport({
    required int companyId,
    required String projectIds,
    required String status,
    required String dFrom,
    required String dTo,
    required String accountIds,
    required String categoryIds,
    required String sectionIds,
    required String userIds,
  }) async {
    try {
      final response = await apiProvider.fetchPaymentRequestReport(
        companyId: companyId,
        projectIds: projectIds,
        status: status,
        dFrom: dFrom,
        dTo: dTo,
        accountIds: accountIds,
        categoryIds: categoryIds,
        sectionIds: sectionIds,
        userIds: userIds,
      );

      final reportResponse =
          BedtimePaymentRequestReportResponse.fromJson(response.data);

      if (reportResponse.nFlag != 1) {
        throw Exception(reportResponse.cMessage);
      }

      return reportResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ??
            "Failed to load payment request report",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
