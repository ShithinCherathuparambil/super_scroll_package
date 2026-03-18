import 'package:flutter_test/flutter_test.dart';
import 'package:super_scroll/super_scroll.dart';

void main() {
  group('SuperScrollController Unit Tests', () {
    test('initial state is correct', () {
      final controller = SuperScrollController<String>(
        onFetch: (page) async => const SuperScrollResult(items: [], hasMore: false),
      );

      expect(controller.items, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.hasMore, isTrue);
      expect(controller.error, isNull);
      expect(controller.currentPage, 1);
    });

    test('loadMore updates state correctly on success', () async {
      final controller = SuperScrollController<String>(
        onFetch: (page) async {
          return SuperScrollResult(
            items: List.generate(5, (i) => 'Item $i'),
            hasMore: true,
          );
        },
      );

      await controller.loadMore();

      expect(controller.items.length, 5);
      expect(controller.currentPage, 2);
      expect(controller.hasMore, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
    });

    test('loadMore updates state correctly on error', () async {
      final controller = SuperScrollController<String>(
        onFetch: (page) async {
          throw Exception('Fetch error');
        },
      );

      await controller.loadMore();

      expect(controller.items, isEmpty);
      expect(controller.currentPage, 1);
      expect(controller.error, isNotNull);
      expect(controller.isLoading, isFalse);
    });

    test('refresh resets state and fetches page 1', () async {
      int fetchCount = 0;
      final controller = SuperScrollController<String>(
        onFetch: (page) async {
          fetchCount++;
          return SuperScrollResult(
            items: ['Item $fetchCount'],
            hasMore: true, // Allow for more fetches
          );
        },
      );

      await controller.loadMore();
      expect(controller.items.length, 1);
      expect(controller.currentPage, 2);

      await controller.refresh();

      expect(controller.items.length, 1);
      expect(controller.currentPage, 2);
      expect(fetchCount, 2);
    });

    test('retry calls loadMore again', () async {
      int fetchCount = 0;
      final controller = SuperScrollController<String>(
        onFetch: (page) async {
          fetchCount++;
          if (fetchCount == 1) throw Exception('Error');
          return const SuperScrollResult(items: ['Success'], hasMore: false);
        },
      );

      await controller.loadMore();
      expect(controller.error, isNotNull);

      await controller.loadMore();
      expect(controller.error, isNull);
      expect(controller.items.length, 1);
      expect(fetchCount, 2);
    });
  });
}
