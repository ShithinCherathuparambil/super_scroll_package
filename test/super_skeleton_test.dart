import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_scroll/super_skeleton.dart';

void main() {
  testWidgets('SuperSkeleton renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuperSkeleton(width: 100, height: 20),
        ),
      ),
    );

    expect(find.byType(SuperSkeleton), findsOneWidget);
    
    // Check if it's animating
    await tester.pump(const Duration(milliseconds: 500));
    // SuperSkeleton uses FadeTransition, which is hard to test specifically for opacity 
    // values in a simple way, but we can verify it pumps without error.
  });

  testWidgets('SuperSkeleton shapes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SuperSkeleton.circle(size: 50),
              SuperSkeleton.rectangle(width: 100, height: 20),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SuperSkeleton), findsNWidgets(2));
  });
}
