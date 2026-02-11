import 'package:bedtime_stories/app_ui/home/model/bedtime_get_category_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_category_list_api_provider.dart';

class BedtimeGetCategoryListRepository {
  final BedtimeGetCategoryListApiProvider apiProvider;

  BedtimeGetCategoryListRepository(this.apiProvider);

  Future<List<BedtimeGetCategoryList>> getCategories({
    required int companyId,
  }) async {
    try {
      final response = await apiProvider.fetchCategories(companyId: companyId);
      final categoryResponse =
          BedtimeGetCategoryListResponse.fromJson(response.data);

      if (categoryResponse.nFlag != 1) {
        throw Exception(categoryResponse.cMessage);
      }

      return categoryResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load categories",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
