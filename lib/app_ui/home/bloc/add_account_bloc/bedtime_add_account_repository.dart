import 'package:bedtime_stories/app_ui/home/model/bedtime_add_account_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_add_account_api_provider.dart';

class BedtimeAddAccountRepository {
  final BedtimeAddAccountApiProvider apiProvider;

  BedtimeAddAccountRepository(this.apiProvider);

  Future<BedtimeAddAccountResponse> saveAccount({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await apiProvider.saveAccount(payload: payload);
      final saveResponse = BedtimeAddAccountResponse.fromJson(response.data);

      if (saveResponse.nFlag != 1) {
        throw Exception(saveResponse.cMessage);
      }

      return saveResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to create account",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
