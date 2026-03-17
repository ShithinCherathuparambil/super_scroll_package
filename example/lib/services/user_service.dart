import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_response.dart';

class UserService {
  final Dio _dio;
  final String? baseUrl;
  final Map<String, String>? headers;

  UserService({Dio? dio, this.baseUrl, this.headers}) : _dio = dio ?? Dio();

  String get _baseUrl => baseUrl ?? dotenv.get('API_URL', fallback: 'https://');

  Future<UserResponse> fetchUsers(int page) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users',
        queryParameters: {'page': page},
        options: Options(
          headers: headers ??
              {
                'x-api-key': dotenv.get('X_API_KEY', fallback: ''),
                'Authorization':
                    'Bearer ${dotenv.get('SESSION_TOKEN', fallback: '')}',
              },
        ),
      );
      log('fetchUsers - ${response.realUri} - ${response.data}');
      if (response.statusCode == 200) {
        return UserResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
