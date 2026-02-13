import 'package:bedtime_stories/app_ui/home/model/bedtime_voucher_report_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_voucher_report_api_provider.dart';

class BedtimeVoucherReportRepository {
  final BedtimeVoucherReportApiProvider apiProvider;

  BedtimeVoucherReportRepository(this.apiProvider);

  Future<List<BedtimeVoucherReportRow>> getVoucherReport({
    required int companyId,
    required String projectIds,
    required String dFrom,
    required String dTo,
    required String accountIds,
    required String categoryIds,
    required String sectionIds,
    required String userIds,
    required String payModes,
  }) async {
    try {
      final response = await apiProvider.fetchVoucherReport(
        companyId: companyId,
        projectIds: projectIds,
        dFrom: dFrom,
        dTo: dTo,
        accountIds: accountIds,
        categoryIds: categoryIds,
        sectionIds: sectionIds,
        userIds: userIds,
        payModes: payModes,
      );

      final voucherReportResponse =
          BedtimeVoucherReportResponse.fromJson(response.data);

      if (voucherReportResponse.nFlag != 1) {
        throw Exception(voucherReportResponse.cMessage);
      }

      return voucherReportResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load voucher report",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
