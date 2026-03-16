import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/business_response.dart';

class BusinessService {
  final Dio _dio = Dio();

  Future<BusinessResponse> fetchBusinesses(
    int page, {
    String search = '',
  }) async {
    try {
      final response = await _dio.get(
        'https://',
        queryParameters: {'limit': 10, 'page': page, 'search': search},
        options: Options(
          headers: {'Authorization': 'Bearer nlvszclfrgimdxfjmxLcafgsdfdx'},
        ),
      );

      log('fetchBusinesses - ${response.realUri} - ${response.data}');

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
