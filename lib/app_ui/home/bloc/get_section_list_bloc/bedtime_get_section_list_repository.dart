import 'package:bedtime_stories/app_ui/home/model/bedtime_get_section_list_response.dart';
import 'package:dio/dio.dart';
import 'bedtime_get_section_list_api_provider.dart';

class BedtimeGetSectionListRepository {
  final BedtimeGetSectionListApiProvider apiProvider;

  BedtimeGetSectionListRepository(this.apiProvider);

  Future<List<BedtimeGetSectionList>> getSections({
    required int companyId,
  }) async {
    try {
      final response = await apiProvider.fetchSections(companyId: companyId);
      final sectionResponse =
          BedtimeGetSectionListResponse.fromJson(response.data);

      if (sectionResponse.nFlag != 1) {
        throw Exception(sectionResponse.cMessage);
      }

      return sectionResponse.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["cMessage"] ?? "Failed to load sections",
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst("Exception:", "").trim(),
      );
    }
  }
}
