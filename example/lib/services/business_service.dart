import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/business_response.dart';

class BusinessService {
  final Dio _dio;
  final String? baseUrl;
  final Map<String, String>? headers;

  BusinessService({Dio? dio, this.baseUrl, this.headers}) : _dio = dio ?? Dio();

  Future<BusinessResponse> fetchBusinesses(
    int page, {
    String search = '',
  }) async {
    String url = baseUrl ?? '';
    if (url.isEmpty) {
      url = dotenv.maybeGet('BUSSINESS_PAGE_LISTING') ?? '';
    }

    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': 10,
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final effectiveHeaders = headers ??
        {
          'Authorization': 'Bearer ${dotenv.maybeGet('AUTH_TOKEN') ?? ''}',
          'Timezone': 'Asia/Kolkata',
          'Accept-Language': 'en',
        };

    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: effectiveHeaders),
      );

      if (response.statusCode == 200) {
        return BusinessResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load businesses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching businesses: $e');
    }
  }
}
