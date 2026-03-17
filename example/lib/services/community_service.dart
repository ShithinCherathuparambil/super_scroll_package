import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/community_response.dart';

class CommunityService {
  final Dio _dio;
  final String? baseUrl;
  final Map<String, String>? headers;

  CommunityService({Dio? dio, this.baseUrl, this.headers}) : _dio = dio ?? Dio();

  Future<CommunityResponse> fetchCommunities(int page) async {
    try {
      final response = await _dio.get(
        baseUrl ?? 'https://',
        queryParameters: {'limit': 10, 'page': page},
        options: Options(
          headers: headers ?? {'Authorization': 'Bearer sdacdfcxnaufhkuaefxa'},
        ),
      );

      log('fetchCommunities - ${response.realUri} - ${response.data}');

      if (response.statusCode == 200) {
        return CommunityResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load communities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching communities: $e');
    }
  }
}
