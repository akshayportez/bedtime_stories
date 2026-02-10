import 'package:dio/dio.dart';
import 'bedtime_api_constants.dart';

class BedtimeApiClient {
  static final BedtimeApiClient _instance = BedtimeApiClient._internal();
  late Dio dio;

  factory BedtimeApiClient() => _instance;

  BedtimeApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: BedtimeApiConstants.baseUrl + BedtimeApiConstants.apiPrefix,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }
}
