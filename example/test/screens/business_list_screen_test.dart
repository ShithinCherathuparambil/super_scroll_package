import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_scroll_example/models/business_model.dart';
import 'package:super_scroll_example/models/business_response.dart';
import 'package:super_scroll_example/screens/business_list_screen.dart';
import 'dart:io';
import '../http_overrides.dart';
import '../mocks.mocks.dart';

void main() {
  late MockBusinessService mockBusinessService;

  setUp(() {
    HttpOverrides.global = TestHttpOverrides();
    mockBusinessService = MockBusinessService();
  });

  testWidgets('BusinessListScreen should render success state', (WidgetTester tester) async {
    when(mockBusinessService.fetchBusinesses(any, search: anyNamed('search')))
        .thenAnswer((_) async => BusinessResponse(
              result: 'success',
              record: [
                BusinessModel(
                  uid: '1',
                  name: 'Business 1',
                  businessType: 'Type A',
                  logo: {},
                ),
              ],
              hasNext: false,
              hasPrevious: false,
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: BusinessListScreen(businessService: mockBusinessService),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Business 1'), findsOneWidget);
    expect(find.text('Type A'), findsOneWidget);
  });

  testWidgets('BusinessListScreen should handle search', (WidgetTester tester) async {
    when(mockBusinessService.fetchBusinesses(any, search: anyNamed('search')))
        .thenAnswer((_) async => BusinessResponse(
              result: 'success',
              record: [],
              hasNext: false,
              hasPrevious: false,
            ));

    await tester.pumpWidget(
      MaterialApp(
        home: BusinessListScreen(businessService: mockBusinessService),
      ),
    );

    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'New Query');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(mockBusinessService.fetchBusinesses(1, search: 'New Query')).called(greaterThanOrEqualTo(1));
  });
}
