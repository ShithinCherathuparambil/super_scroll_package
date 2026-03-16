import 'dart:developer';
import 'package:dio/dio.dart';
import '../models/community_response.dart';

class CommunityService {
  final Dio _dio = Dio();

  Future<CommunityResponse> fetchCommunities(int page) async {
    try {
      final response = await _dio.get(
        'https://',
        queryParameters: {'limit': 10, 'page': page},
        options: Options(
          headers: {'Authorization': 'Bearer sdacdfcxnaufhkuaefxa'},
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
