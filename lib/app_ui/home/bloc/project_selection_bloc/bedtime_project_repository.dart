import 'package:bedtime_stories/app_ui/home/model/bedtime_project_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_project_api_provider.dart';

class BedtimeProjectRepository {
  final BedtimeProjectApiProvider apiProvider;

  BedtimeProjectRepository(this.apiProvider);

  Future<List<BedtimeProject>> getProjects({
    required int companyId,
    required int userId,
    String search = "",
  }) async {
    try {
      final response = await apiProvider.fetchProjects(
        companyId: companyId,
        userId: userId,
        search: search,
      );

      final projectResponse =
          BedtimeProjectResponse.fromJson(response.data);

      if (projectResponse.nFlag != 1) {
        throw Exception(projectResponse.cMessage);
      }

      return projectResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load projects",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
