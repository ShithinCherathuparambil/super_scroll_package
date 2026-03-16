# Super Scroll

A simple, lightweight, and powerful pagination library for Flutter.

`SuperScroll` makes it easy to add infinite scrolling to your lists or grids. It provides high-level "Super" widgets that handle pagination state, loading indicators, viewport filling, and error handling automatically with minimal boilerplate.

## 🚀 Features

- **One-Stop Widgets**: Use `SuperListView` or `SuperGridView` to implement pagination in seconds.
- **Automatic Viewport Filling**: Automatically triggers `loadMore` until the screen is filled or data ends.
- **Granular Indicators**: Specific widgets for first-page loading, new-page loading, errors, and empty states.
- **Smart Refreshing**: Supports both full-list Refresh (Pull-to-Refresh) and specific page refreshing.
- **Lightweight & Efficient**: Minimal dependencies, optimized for performance with large datasets.

## 📦 Installation

Add `super_scroll` to your `pubspec.yaml`:

```yaml
dependencies:
  super_scroll: ^latest_version
```

## 🛠 Usage

### 1. Initialize the Controller
The `SuperScrollController` manages the pagination state. You provide an `onFetch` callback that handles the actual data fetching logic.

```dart
final _controller = SuperScrollController<UserModel>(
  onFetch: (page) async {
    final response = await _userService.fetchUsers(page);
    return SuperScrollResult(
      items: response.users,
      hasMore: response.hasNextPage,
    );
  },
);
```

### 2. Use SuperListView
`SuperListView` provides a familiar API for paginated lists.

```dart
// Separated list with dividers
SuperListView.separated(
  controller: _controller,
  itemBuilder: (context, user, index) => ListTile(title: Text(user.name)),
  separatorBuilder: (context, index) => const Divider(),
  onRefresh: () => _controller.refresh(),
)
```

### 3. Use SuperGridView
For paginated grids, use `SuperGridView.count` or `SuperGridView.extent`.

```dart
SuperGridView.count(
  controller: _controller,
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemBuilder: (context, item, index) => GridItem(item),
)
```

## 🎨 Advanced Customization

### Granular Pagination Indicators
You can customize exactly what is shown during different states of the pagination lifecycle.

```dart
SuperListView.builder(
  controller: _controller,
  firstPageProgressIndicator: CustomFirstLoadSpinner(),
  newPageProgressIndicator: CustomBottomLoader(),
  firstPageErrorIndicator: MyCustomErrorWidget(onRetry: () => _controller.loadMore()),
  newPageErrorIndicator: MyCustomBottomErrorWidget(),
  noItemsFoundIndicator: Center(child: Text('No results found')),
  noMoreItemsIndicator: Center(child: Text('End of list')),
  itemBuilder: (context, item, index) => MyTile(item),
)
```

### Manual Refresh Management
- **Full Refresh**: `_controller.refresh()` clears all items and reloads from page 1.
- **Page Refresh**: `_controller.refresh(page: 5)` reloads only the 5th page and replaces the corresponding items in the list.

### Raw SuperScroll
If you need a completely custom layout (e.g., inside a `CustomScrollView`), use the base `SuperScroll` widget.

```dart
SuperScroll(
  controller: _controller,
  child: ListView.builder(
    itemCount: _controller.items.length,
    itemBuilder: (context, index) => MyItem(_controller.items[index]),
  ),
)
```

## 📝 Comparison

| Feature | Super Scroll | Infinite Scroll Pagination |
| :--- | :--- | :--- |
| **Boilerplate** | Low (High-level widgets included) | High (Requires customPagedView/Delegate) |
| **Viewport Filling** | Automatic | Manual |
| **Specific Page Refresh**| Yes (`refresh(page: n)`) | No |
| **Weight** | Lightweight | Heavier |

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request or open an issue for any bugs or feature requests.

## 📄 License
MIT License
