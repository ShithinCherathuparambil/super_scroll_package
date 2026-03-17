import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:super_scroll_example/models/business_response.dart';
import 'package:super_scroll_example/services/business_service.dart';

void main() {
  late BusinessService businessService;
  late Dio dio;
  late DioAdapter dioAdapter;
  const baseUrl = 'https://api.example.com';

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    businessService = BusinessService(
      dio: dio,
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer test_token'},
    );
  });

  group('BusinessService Tests', () {
    test('fetchBusinesses returns BusinessResponse on success', () async {
      const page = 1;
      const search = 'test';
      
      dioAdapter.onGet(
        baseUrl,
        (server) => server.reply(200, {
          'result': 'success',
          'record': [
            {
              'uid': 'business_1',
              'name': 'Business 1',
              'business_type': 'Type A',
              'logo': {'url': 'logo.png'}
            },
          ],
          'has_next': true,
          'has_previous': false,
        }),
        queryParameters: {'limit': 10, 'page': page, 'search': search},
      );

      final response = await businessService.fetchBusinesses(page, search: search);

      expect(response, isA<BusinessResponse>());
      expect(response.result, 'success');
      expect(response.record.length, 1);
      expect(response.hasNext, isTrue);
    });

    test('fetchBusinesses throws exception on error', () async {
      const page = 1;
      
      dioAdapter.onGet(
        baseUrl,
        (server) => server.reply(500, {'message': 'Server Error'}),
        queryParameters: {'limit': 10, 'page': page, 'search': ''},
      );

      expect(() => businessService.fetchBusinesses(page), throwsException);
    });
  });
}
