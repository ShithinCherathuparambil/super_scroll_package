import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_scroll_example/models/community_model.dart';
import 'package:super_scroll_example/models/community_response.dart';
import 'package:super_scroll_example/screens/community_list_screen.dart';
import 'dart:io';
import '../http_overrides.dart';
import '../mocks.mocks.dart';

void main() {
  late MockCommunityService mockCommunityService;

  setUp(() {
    HttpOverrides.global = TestHttpOverrides();
    mockCommunityService = MockCommunityService();
  });

  testWidgets('CommunityListScreen should render success state', (WidgetTester tester) async {
    when(mockCommunityService.fetchCommunities(any))
        .thenAnswer((_) async => CommunityResponse(
              result: 'success',
              records: [
                CommunityModel(
                  id: 1,
                  uid: 'c1',
                  name: 'Community 1',
                  member: 10,
                  post: 5,
                  isFollowed: true,
                  specialityCommunity: false,
                ),
              ],
              hasNext: false,
              hasPrevious: false,
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: CommunityListScreen(communityService: mockCommunityService),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Community 1'), findsOneWidget);
    expect(find.text('10 Members • 5 Posts'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget); // isFollowed icon
  });
}
