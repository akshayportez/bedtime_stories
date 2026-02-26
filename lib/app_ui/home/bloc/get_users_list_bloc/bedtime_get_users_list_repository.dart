import 'package:bedtime_stories/app_ui/home/model/bedtime_get_users_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_users_list_api_provider.dart';

class BedtimeGetUsersListRepository {
  final BedtimeGetUsersListApiProvider apiProvider;

  BedtimeGetUsersListRepository(this.apiProvider);

  Future<List<BedtimeGetUsersList>> getUsers({
    required int companyId,
    String search = "",
  }) async {
    try {
      final response = await apiProvider.fetchUsers(
        companyId: companyId,
        search: search,
      );
      final usersResponse = BedtimeGetUsersListResponse.fromJson(response.data);

      if (usersResponse.nFlag != 1) {
        throw Exception(usersResponse.cMessage);
      }

      return usersResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load users",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
