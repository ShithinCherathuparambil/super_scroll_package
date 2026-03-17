import 'package:flutter_test/flutter_test.dart';
import 'package:super_scroll/super_scroll_controller.dart';

void main() {
  group('SuperScrollController Selection', () {
    late SuperScrollController<String> controller;

    setUp(() {
      controller = SuperScrollController<String>(
        onFetch: (page) async => SuperScrollResult(items: ['A', 'B', 'C'], hasMore: false),
      );
    });

    test('initial state is not selection mode', () {
      expect(controller.isSelectionMode, isFalse);
      expect(controller.selectedItems, isEmpty);
    });

    test('toggleSelectionMode works', () {
      controller.toggleSelectionMode(true);
      expect(controller.isSelectionMode, isTrue);

      controller.toggleSelectionMode(false);
      expect(controller.isSelectionMode, isFalse);
    });

    test('toggleItemSelection adds/removes items', () {
      controller.toggleItemSelection('A');
      expect(controller.isSelected('A'), isTrue);
      expect(controller.selectedItems.length, 1);

      controller.toggleItemSelection('A');
      expect(controller.isSelected('A'), isFalse);
      expect(controller.selectedItems, isEmpty);
    });

    test('clearSelection works', () {
      controller.toggleItemSelection('A');
      controller.toggleItemSelection('B');
      expect(controller.selectedItems.length, 2);

      controller.clearSelection();
      expect(controller.selectedItems, isEmpty);
    });

    test('selection mode false clears items', () {
      controller.toggleSelectionMode(true);
      controller.toggleItemSelection('A');
      expect(controller.selectedItems.length, 1);

      controller.toggleSelectionMode(false);
      expect(controller.selectedItems, isEmpty);
    });
  });
}
