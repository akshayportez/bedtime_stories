import 'package:bedtime_stories/app_ui/home/model/bedtime_get_bank_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_bank_list_api_provider.dart';

class BedtimeGetBankListRepository {
  final BedtimeGetBankListApiProvider apiProvider;

  BedtimeGetBankListRepository(this.apiProvider);

  Future<List<BedtimeGetBankList>> getBanks({
    required int companyId,
  }) async {
    try {
      final response = await apiProvider.fetchBanks(companyId: companyId);
      final bankResponse = BedtimeGetBankListResponse.fromJson(response.data);

      if (bankResponse.nFlag != 1) {
        throw Exception(bankResponse.cMessage);
      }

      return bankResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load banks",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
