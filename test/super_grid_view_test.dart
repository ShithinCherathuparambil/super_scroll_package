import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_scroll/super_scroll.dart';

void main() {
  testWidgets('SuperGridView should render items and handle pagination',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        return SuperScrollResult(
          items: List.generate(20, (i) => 'Item ${((page - 1) * 20) + i}'),
          hasMore: page < 3,
        );
      },
    );

    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperGridView(
            controller: controller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, item, index) => Card(child: Text(item)),
          ),
        ),
      ),
    );

    // Initial load
    await tester.pump(); // Trigger postFrameCallback
    await tester.pumpAndSettle(); // Wait for fetch
    
    expect(fetchCount, 1);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
    expect(controller.items.length, 20);
  });

  testWidgets('SuperGridView should show loading indicator when fetching',
      (WidgetTester tester) async {
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        await Future.delayed(const Duration(seconds: 1));
        return const SuperScrollResult(items: ['Item'], hasMore: false);
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperGridView(
            controller: controller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    await tester.pump(); // Start load
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1)); // Finish load
    await tester.pump(); // Rebuild with items
    expect(find.text('Item'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
