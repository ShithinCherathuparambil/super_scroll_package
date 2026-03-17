import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:super_scroll_example/models/user_response.dart';
import 'package:super_scroll_example/services/user_service.dart';

void main() {
  late UserService userService;
  late Dio dio;
  late DioAdapter dioAdapter;
  const baseUrl = 'https://api.example.com';

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    userService = UserService(
      dio: dio,
      baseUrl: baseUrl,
      headers: {
        'x-api-key': 'test_key',
        'Authorization': 'Bearer test_token',
      },
    );
  });

  group('UserService Tests', () {
    test('fetchUsers returns UserResponse on success', () async {
      const baseUrl = 'https://api.example.com';
      const page = 1;
      
      dioAdapter.onGet(
        '$baseUrl/users',
        (server) => server.reply(200, {
          'page': 1,
          'per_page': 10,
          'total': 20,
          'total_pages': 2,
          'data': [
            {
              'id': 1,
              'email': 'user1@example.com',
              'first_name': 'User',
              'last_name': '1',
              'avatar': 'avatar1.png'
            },
          ],
        }),
        queryParameters: {'page': page},
      );

      final response = await userService.fetchUsers(page);

      expect(response, isA<UserResponse>());
      expect(response.page, 1);
      expect(response.data?.length, 1);
      expect(response.data?[0].firstName, 'User');
    });

    test('fetchUsers throws exception on error', () async {
      const baseUrl = 'https://api.example.com';
      const page = 1;
      
      dioAdapter.onGet(
        '$baseUrl/users',
        (server) => server.reply(404, {'message': 'Not Found'}),
        queryParameters: {'page': page},
      );

      expect(() => userService.fetchUsers(page), throwsException);
    });
  });
}
