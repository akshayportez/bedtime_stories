import 'package:bedtime_stories/app_ui/home/model/bedtime_get_accounts_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_accounts_list_api_provider.dart';

class BedtimeGetAccountsListRepository {
  final BedtimeGetAccountsListApiProvider apiProvider;

  BedtimeGetAccountsListRepository(this.apiProvider);

  Future<List<BedtimeGetAccountsList>> getAccounts({
    required int companyId,
  }) async {
    try {
      final response = await apiProvider.fetchAccounts(companyId: companyId);
      final accountResponse =
          BedtimeGetAccountsListResponse.fromJson(response.data);

      if (accountResponse.nFlag != 1) {
        throw Exception(accountResponse.cMessage);
      }

      return accountResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load accounts",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}

