import 'package:flutter/foundation.dart';

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

/// A controller that manages the pagination state for `SuperListView` or `SuperGridView`.
class SuperScrollController<T> extends ChangeNotifier {
  /// Callback to fetch data for a specific page.
  final Future<SuperScrollResult<T>> Function(int page) onFetch;

  List<T> _items = [];
  final Map<int, int> _pageItemCounts = {};
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Object? _error;
  final Set<T> _selectedItems = {};
  bool _isSelectionMode = false;

  SuperScrollController({
    required this.onFetch,
  });

  /// The list of items currently loaded.
  List<T> get items => _items;

  /// Whether the controller is currently loading data.
  bool get isLoading => _isLoading;

  /// Whether there are more items to load.
  bool get hasMore => _hasMore;

  /// The current page number.
  int get currentPage => _currentPage;

  /// The error encountered during the last fetch, if any.
  Object? get error => _error;

  /// The set of selected items.
  Set<T> get selectedItems => _selectedItems;

  /// Whether the controller is in selection mode.
  bool get isSelectionMode => _isSelectionMode;

  /// Toggles selection mode on or off.
  void toggleSelectionMode(bool value) {
    if (_isSelectionMode == value) {
      return;
    }
    _isSelectionMode = value;
    if (!_isSelectionMode) {
      _selectedItems.clear();
    }
    notifyListeners();
  }

  /// Toggles selection for a specific item.
  void toggleItemSelection(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifyListeners();
  }

  /// Selects all currently loaded items.
  void selectAll() {
    _selectedItems.addAll(_items);
    notifyListeners();
  }

  /// Clears all selections.
  void clearSelection() {
    _selectedItems.clear();
    notifyListeners();
  }

  /// Checks if a specific item is selected.
  bool isSelected(T item) => _selectedItems.contains(item);

  /// Loads the next page of data.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await onFetch(_currentPage);
      _items.addAll(result.items);
      _pageItemCounts[_currentPage] = result.items.length;
      _hasMore = result.hasMore;
      _currentPage++;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the data.
  /// If [page] is provided, it re-fetches only that specific page and replaces its items.
  /// If [page] is null, it clears everything and starts over from page 1.
  Future<void> refresh({int? page}) async {
    if (page != null) {
      if (!_pageItemCounts.containsKey(page)) {
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        final result = await onFetch(page);
        
        // Calculate the starting index of the page
        int startIndex = 0;
        for (int i = 1; i < page; i++) {
          startIndex += _pageItemCounts[i] ?? 0;
        }

        // Replace the items for this page
        final oldItemCount = _pageItemCounts[page] ?? 0;
        _items.replaceRange(startIndex, startIndex + oldItemCount, result.items);
        
        // Update the item count for this page
        _pageItemCounts[page] = result.items.length;
      } catch (e) {
        _error = e;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _items = [];
    _pageItemCounts.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    await loadMore();
  }

  /// Clears the items and resets the controller state.
  void reset() {
    _items = [];
    _pageItemCounts.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}
