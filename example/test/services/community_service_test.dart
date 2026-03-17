import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:super_scroll_example/models/community_response.dart';
import 'package:super_scroll_example/services/community_service.dart';

void main() {
  late CommunityService communityService;
  late Dio dio;
  late DioAdapter dioAdapter;
  const baseUrl = 'https://api.example.com';

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    communityService = CommunityService(
      dio: dio,
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer test_token'},
    );
  });

  group('CommunityService Tests', () {
    test('fetchCommunities returns CommunityResponse on success', () async {
      const page = 1;
      
      dioAdapter.onGet(
        baseUrl,
        (server) => server.reply(200, {
          'result': 'success',
          'records': [
            {
              'id': 1,
              'uid': 'community_1',
              'name': 'Community 1',
              'member': 100,
              'post': 50,
              'is_followed': false,
              'speciality_community': true
            },
          ],
          'has_next': true,
          'has_previous': false,
        }),
        queryParameters: {'limit': 10, 'page': page},
      );

      final response = await communityService.fetchCommunities(page);

      expect(response, isA<CommunityResponse>());
      expect(response.result, 'success');
      expect(response.records.length, 1);
      expect(response.hasNext, isTrue);
    });

    test('fetchCommunities throws exception on error', () async {
      const page = 1;
      
      dioAdapter.onGet(
        baseUrl,
        (server) => server.reply(500, {'message': 'Server Error'}),
        queryParameters: {'limit': 10, 'page': page},
      );

      expect(() => communityService.fetchCommunities(page), throwsException);
    });
  });
}
