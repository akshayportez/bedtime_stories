import 'package:bedtime_stories/app_ui/home/model/bedtime_get_tax_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_tax_list_api_provider.dart';

class BedtimeGetTaxListRepository {
  final BedtimeGetTaxListApiProvider apiProvider;

  BedtimeGetTaxListRepository(this.apiProvider);

  Future<List<BedtimeGetTaxList>> getTaxes({
    required int companyId,
  }) async {
    try {
      final response = await apiProvider.fetchTaxes(companyId: companyId);
      final taxResponse = BedtimeGetTaxListResponse.fromJson(response.data);

      if (taxResponse.nFlag != 1) {
        throw Exception(taxResponse.cMessage);
      }

      return taxResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load taxes",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
