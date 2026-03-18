import 'package:flutter/material.dart';

/// A function that builds a widget for a given item in the list or grid.
typedef SuperItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

/// A result object returned from the `onFetch` callback.
class SuperScrollResult<T> {
  /// The list of items fetched for the current page.
  final List<T> items;

  /// Whether there are more items to be fetched.
  final bool hasMore;

  const SuperScrollResult({
    required this.items,
    required this.hasMore,
  });
}

/// A controller for [SuperScroll] and its variants.
/// 
/// It manages the list of items, loading state, error state, and selection mode.
class SuperScrollController<T> extends ChangeNotifier {
  /// The callback that fetches new items for a given page.
  final Future<SuperScrollResult<T>> Function(int page) onFetch;

  /// The list of items currently loaded.
  final List<T> items = [];

  /// The list of currently selected items.
  final Set<T> selectedItems = {};

  bool _isSelectionMode = false;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  Object? _error;

  SuperScrollController({required this.onFetch});

  /// Whether the controller is currently loading more items.
  bool get isLoading => _isLoading;

  /// Whether there are more items to load.
  bool get hasMore => _hasMore;

  /// The last error that occurred during fetching, if any.
  Object? get error => _error;

  /// Current page number.
  int get currentPage => _currentPage;

  /// Whether the controller is in selection mode.
  bool get isSelectionMode => _isSelectionMode;

  /// Resets the controller and reloads the first page.
  /// 
  /// If [page] is specified, it refreshes from that page onwards.
  Future<void> refresh({int? page}) async {
    if (page != null && page > 1) {
      return refreshFromPage(page);
    }
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    items.clear();
    selectedItems.clear();
    _isSelectionMode = false;
    notifyListeners();
    return loadMore();
  }

  /// Refreshes a specific page and everything after it.
  Future<void> refreshFromPage(int page) async {
    if (page < 1 || page > _currentPage) return;
    
    _currentPage = page;
    _hasMore = true;
    _error = null;
    
    // In this simplified version, we just reset to the target page and clear items.
    // A more advanced version would only clear items from that page onwards.
    items.clear();
    return loadMore();
  }

  /// Fetches the next page of items.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await onFetch(_currentPage);
      items.addAll(result.items);
      _hasMore = result.hasMore;
      if (_hasMore) {
        _currentPage++;
      }
      _error = null;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Directly sets items (useful for initial state or manual management).
  void setItems(List<T> newItems, {bool hasMore = true}) {
    items.clear();
    items.addAll(newItems);
    _hasMore = hasMore;
    notifyListeners();
  }

  // --- Selection Logic ---

  /// Toggles selection mode on or off.
  void toggleSelectionMode([bool? value]) {
    _isSelectionMode = value ?? !_isSelectionMode;
    if (!_isSelectionMode) {
      selectedItems.clear();
    }
    notifyListeners();
  }

  /// Toggles selection of a specific item.
  /// 
  /// Automatically enables selection mode if not already active.
  void toggleItemSelection(T item) {
    if (!_isSelectionMode) {
      _isSelectionMode = true;
    }
    
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
    
    if (selectedItems.isEmpty) {
      _isSelectionMode = false;
    }
    notifyListeners();
  }

  /// Returns whether a specific item is selected.
  bool isSelected(T item) => selectedItems.contains(item);

  /// Selects all currently loaded items.
  void selectAll() {
    _isSelectionMode = true;
    selectedItems.addAll(items);
    notifyListeners();
  }

  /// Clears the current selection.
  void clearSelection() {
    selectedItems.clear();
    _isSelectionMode = false;
    notifyListeners();
  }
}
