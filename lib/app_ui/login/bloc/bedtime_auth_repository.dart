import 'package:bedtime_stories/app_ui/login/bloc/bedtime_auth_api_provider.dart';
import 'package:bedtime_stories/app_ui/login/models/bedtime_login_response.dart';
import 'package:bedtime_stories/core/storage/bedtime_local_storage.dart';
import 'package:dio/dio.dart';

class BedtimeAuthRepository {
  final BedtimeAuthApiProvider apiProvider;

  BedtimeAuthRepository(this.apiProvider);

  Future<BedtimeLoginResponse> login(
      String username, String password) async {
    try {
      final response = await apiProvider.login(username, password);

      final loginResponse =
          BedtimeLoginResponse.fromJson(response.data);

      if (loginResponse.nFlag != 1) {
        throw Exception(loginResponse.cMessage);
      }

      /// Save user session
      await BedtimeLocalStorage.saveLoginUser(loginResponse);

      return loginResponse;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Login failed",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
