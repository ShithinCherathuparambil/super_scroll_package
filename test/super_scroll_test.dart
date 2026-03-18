import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_scroll/super_scroll.dart';

void main() {
  testWidgets('SuperScroll should trigger onFetch when scrolled to bottom',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        return SuperScrollResult(
          items: List.generate(10, (i) => 'Item ${((page - 1) * 10) + i}'),
          hasMore: page < 2,
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperScroll(
            controller: controller,
            child: ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(controller.items[index])),
            ),
          ),
        ),
      ),
    );

    // Initial fetch
    await tester.pump();
    expect(fetchCount, 1);
    expect(controller.items.length, 10);

    // Scroll to the bottom
    final listFinder = find.byType(Scrollable);
    await tester.drag(listFinder, const Offset(0, -2000));
    await tester.pump(); // Start fetching
    await tester.pump(); // Finish fetching

    expect(fetchCount, 2);
    expect(controller.items.length, 20);
  });

  testWidgets('SuperScroll should show loading indicator during fetch',
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
          body: SuperScroll(
            controller: controller,
            child: ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) => const ListTile(title: Text('Test')),
            ),
          ),
        ),
      ),
    );

    await tester.pump(); // Start initial load
    expect(find.byType(SuperSkeleton), findsWidgets);

    await tester.pump(const Duration(seconds: 1)); // Finish load
    await tester.pump(); // Rebuild with items
    expect(find.byType(SuperSkeleton), findsNothing);
  });

  testWidgets('SuperListView.builder should render items and handle pagination',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        return SuperScrollResult(
          items: List.generate(20, (i) => 'User ${((page - 1) * 20) + i}'),
          hasMore: page < 3,
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperListView.builder(
            controller: controller,
            itemBuilder: (context, item, index) => ListTile(title: Text(item)),
          ),
        ),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();
    expect(fetchCount, 1);
    expect(find.text('User 0'), findsOneWidget);
    expect(find.text('User 5'), findsOneWidget);

    // Scroll to bottom to trigger next page
    final listFinder = find.byType(Scrollable);
    await tester.drag(listFinder, const Offset(0, -1500));
    await tester.pump(); // Start fetch
    await tester.pumpAndSettle(); // Finish fetch

    expect(controller.items.length, greaterThanOrEqualTo(40));
    expect(find.text('User 20', skipOffstage: false), findsOneWidget);
  });

  testWidgets('SuperScrollController.refresh(page) should update only specific page',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        if (page == 1 && fetchCount > 2) {
          // Second time fetching page 1
          return const SuperScrollResult(items: ['New Item 1', 'New Item 2'], hasMore: true);
        }
        return SuperScrollResult(
          items: List.generate(5, (i) => 'Page $page Item $i'),
          hasMore: true,
        );
      },
    );

    // Load page 1
    await controller.loadMore();
    expect(controller.items.length, 5);
    expect(controller.items[0], 'Page 1 Item 0');

    // Load page 2
    await controller.loadMore();
    expect(controller.items.length, 10);
    expect(controller.items[5], 'Page 2 Item 0');

    // Refresh page 1
    await controller.refresh(page: 1);
    
    // Now page 1 should have 2 items (since we cleared and reloaded page 1).
    expect(controller.items.length, 2); 
    expect(controller.items[0], 'New Item 1');
    expect(controller.items[1], 'New Item 2');
  });

  testWidgets('SuperListView should fill viewport if initial items are not enough',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        // Return only 2 small items per page
        return SuperScrollResult(
          items: ['Page $page Item 1', 'Page $page Item 2'],
          hasMore: page < 5,
        );
      },
    );

    // Set a large screen size to ensure 2 items don't fill it
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperListView.builder(
            controller: controller,
            itemBuilder: (context, item, index) => SizedBox(
              height: 50, // Small height
              child: ListTile(title: Text(item)),
            ),
          ),
        ),
      ),
    );

    // Initial load will trigger
    await tester.pump(); // Start fetch page 1
    await tester.pumpAndSettle(); // Finish fetch page 1
    
    // Give it a chance to detect viewport is not full and trigger page 2
    await tester.pump(); // Trigger the postFrameCallback check
    await tester.pumpAndSettle(); // Finish fetch page 2
    
    await tester.pump(); // Trigger check for page 3
    await tester.pumpAndSettle(); // Finish fetch page 3

    await tester.pump(); // Trigger check for page 4
    await tester.pumpAndSettle(); // Finish fetch page 4

    await tester.pump(); // Trigger check for page 5
    await tester.pumpAndSettle(); // Finish fetch page 5
    
    expect(fetchCount, 5);
    expect(controller.items.length, 10);
    
    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('SuperListView should display granular indicators correctly',
      (WidgetTester tester) async {
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        await Future.delayed(const Duration(seconds: 1));
        if (page == 2) throw Exception('Fetch Page 2 Error');
        return SuperScrollResult(
          items: List.generate(10, (i) => 'Item $i'),
          hasMore: true,
        );
      },
    );

    // 1. Test firstPageProgressIndicator
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperListView.builder(
            controller: controller,
            itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            firstPageProgressIndicator: const Text('First Page Loading...'),
            newPageProgressIndicator: const Text('New Page Loading...'),
            firstPageErrorIndicator: const Text('First Page Error'),
            newPageErrorIndicator: const Text('New Page Error'),
          ),
        ),
      ),
    );

    await tester.pump(); // Start load
    expect(find.text('First Page Loading...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1)); // Finish load
    await tester.pump(); // Rebuild with items
    expect(find.text('Item 0'), findsOneWidget);

    // 2. Test newPageProgressIndicator
    final listFinder = find.byType(Scrollable);
    await tester.drag(listFinder, const Offset(0, -1000));
    await tester.pump(); // Start fetch page 2
    expect(find.text('New Page Loading...'), findsOneWidget);

    // 3. Test newPageErrorIndicator
    await tester.pump(const Duration(seconds: 1)); // Finish fetch page 2 (with error)
    await tester.pump(); // Rebuild with error
    expect(find.text('New Page Error'), findsOneWidget);
  });

  testWidgets('SuperListView should display noItemsFoundIndicator when empty',
      (WidgetTester tester) async {
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        return const SuperScrollResult(items: [], hasMore: false);
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperListView.builder(
            controller: controller,
            itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            noItemsFoundIndicator: const Text('Nothing here!'),
          ),
        ),
      ),
    );

    await tester.pump(); // Start load
    await tester.pumpAndSettle(); // Finish load
    expect(find.text('Nothing here!'), findsOneWidget);
  });

  testWidgets('SuperListView should display firstPageErrorIndicator and allow retry',
      (WidgetTester tester) async {
    int fetchCount = 0;
    final controller = SuperScrollController<String>(
      onFetch: (page) async {
        fetchCount++;
        if (fetchCount == 1) throw Exception('Initial Error');
        return const SuperScrollResult(items: ['Success Item'], hasMore: false);
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperListView.builder(
            controller: controller,
            itemBuilder: (context, item, index) => ListTile(title: Text(item)),
          ),
        ),
      ),
    );

    await tester.pump(); // Start load
    await tester.pumpAndSettle(); // Finish load with error
    
    // Default error widget has 'Retry' button
    expect(find.textContaining('Initial Error'), findsOneWidget);
    final retryButton = find.text('Retry');
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pump(); // Start second fetch
    await tester.pumpAndSettle(); // Finish second fetch
    
    expect(find.text('Success Item'), findsOneWidget);
  });
}
