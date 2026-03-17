import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_scroll_example/models/user_model.dart';
import 'package:super_scroll_example/models/user_response.dart';
import 'package:super_scroll_example/screens/user_list_screen.dart';
import 'dart:io';
import '../http_overrides.dart';
import '../mocks.mocks.dart';

void main() {
  late MockUserService mockUserService;

  setUp(() {
    HttpOverrides.global = TestHttpOverrides();
    mockUserService = MockUserService();
  });

  testWidgets('UserListScreen should render success state', (WidgetTester tester) async {
    when(mockUserService.fetchUsers(any)).thenAnswer((_) async => UserResponse(
          page: 1,
          perPage: 10,
          total: 10,
          totalPages: 1,
          data: [
            UserModel(id: 1, firstName: 'John', lastName: 'Doe', email: 'john@example.com'),
            UserModel(id: 2, firstName: 'Jane', lastName: 'Smith', email: 'jane@example.com'),
          ],
        ));

    await tester.pumpWidget(
      MaterialApp(
        home: UserListScreen(userService: mockUserService),
      ),
    );

    // Initial load
    await tester.pump(); // Start fetch
    await tester.pumpAndSettle(); // Finish fetch

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('UserListScreen should show error state and allow retry', (WidgetTester tester) async {
    int fetchCount = 0;
    when(mockUserService.fetchUsers(any)).thenAnswer((_) async {
      fetchCount++;
      if (fetchCount == 1) throw Exception('Initial Error');
      return UserResponse(
        page: 1,
        perPage: 10,
        total: 1,
        totalPages: 1,
        data: [UserModel(id: 1, firstName: 'Success', lastName: 'User')],
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: UserListScreen(userService: mockUserService),
      ),
    );

    await tester.pump(); // Start load
    await tester.pumpAndSettle(); // Finish load with error

    expect(find.textContaining('Initial Error'), findsOneWidget);
    final retryButton = find.text('Retry');
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pump(); // Start second fetch
    await tester.pumpAndSettle(); // Finish second fetch

    expect(find.text('Success User'), findsOneWidget);
  });
}
