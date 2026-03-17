import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:super_scroll_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('verify navigation and data loading', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on User List Screen
      expect(find.text('Super Scroll - Users'), findsOneWidget);

      // Wait for data to load (Network might take a bit)
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check if some users are loaded (using text from real API if possible, or just generic check)
      // Since it's a real network call, we look for ListTile widgets
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));

      // Navigate to Communities
      final communityIcon = find.byIcon(Icons.group);
      await tester.tap(communityIcon);
      await tester.pumpAndSettle();

      expect(find.text('Communities'), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Navigate to Businesses
      final businessIcon = find.byIcon(Icons.business);
      await tester.tap(businessIcon);
      await tester.pumpAndSettle();

      expect(find.text('Businesses'), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
    });
  });
}
