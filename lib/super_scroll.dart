import 'package:flutter/material.dart';
import 'super_scroll_controller.dart';

export 'super_scroll_controller.dart';
export 'super_list_view.dart';
export 'super_grid_view.dart';

/// A simple and lightweight pagination widget for Flutter.
/// 
/// [SuperScroll] wraps a scrollable widget and uses a [SuperScrollController]
/// to manage pagination logic automatically.
class SuperScroll extends StatefulWidget {
  /// The scrollable widget to be wrapped (e.g., ListView, GridView).
  /// Note: The child's itemCount should typically be `controller.items.length`.
  final Widget child;

  /// The controller managing the pagination state.
  final SuperScrollController controller;

  /// Distance from the bottom (in pixels) to trigger loading more data.
  /// Defaults to 100.0.
  final double scrollOffset;

  /// Widget to display at the bottom when loading subsequent pages.
  /// If null, a default [CircularProgressIndicator] is used.
  final Widget? newPageProgressIndicator;

  /// Widget to display when the first page is loading.
  /// If null, a default [CircularProgressIndicator] is used.
  final Widget? firstPageProgressIndicator;

  /// Widget to display when an error occurs fetching the first page.
  final Widget? firstPageErrorIndicator;

  /// Widget to display when an error occurs fetching a subsequent page.
  final Widget? newPageErrorIndicator;

  /// Widget to display when no items were found on the first page.
  final Widget? noItemsFoundIndicator;

  /// Widget to display when there are no more items to load.
  final Widget? noMoreItemsIndicator;

  /// An optional ScrollController to monitor the scroll position.
  /// If not provided, an internal one will be created.
  final ScrollController? scrollController;

  const SuperScroll({
    required this.child,
    required this.controller,
    this.scrollOffset = 100.0,
    this.newPageProgressIndicator,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
    this.scrollController,
    super.key,
  });

  @override
  State<SuperScroll> createState() => _SuperScrollState();
}

class _SuperScrollState extends State<SuperScroll> {
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    // Initial load if items are empty, deferred to after build
    if (widget.controller.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.loadMore();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});

    // Check if we need to load more because the viewport is not filled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkIfViewportNeedsFilling();
    });
  }

  void _checkIfViewportNeedsFilling() {
    if (widget.controller.isLoading ||
        !widget.controller.hasMore ||
        widget.controller.error != null) return;

    final scrollController = _effectiveController;
    if (scrollController.hasClients) {
      final position = scrollController.position;
      // If the content doesn't fill the viewport (maxScrollExtent is 0 or very small),
      // or if we are already near the bottom, trigger loadMore.
      if (position.maxScrollExtent <= 0 ||
          position.pixels >= position.maxScrollExtent - widget.scrollOffset) {
        widget.controller.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to load more because the viewport is not filled.
    // We do this after every build to ensure we catch changes in content size.
    // Only trigger if we aren't currently loading, have more, and don't have an error.
    if (!widget.controller.isLoading &&
        widget.controller.hasMore &&
        widget.controller.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkIfViewportNeedsFilling();
      });
    }

    final items = widget.controller.items;
    final isLoading = widget.controller.isLoading;
    final error = widget.controller.error;
    final hasMore = widget.controller.hasMore;

    // Handle First Page Loading
    if (items.isEmpty && isLoading) {
      return Center(
        child: widget.firstPageProgressIndicator ??
            const CircularProgressIndicator(),
      );
    }

    // Handle First Page Error
    if (items.isEmpty && error != null) {
      return widget.firstPageErrorIndicator ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => widget.controller.loadMore(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    // Handle Empty Results
    if (items.isEmpty && !isLoading && !hasMore) {
      return widget.noItemsFoundIndicator ??
          const Center(child: Text('No items found.'));
    }

    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!widget.controller.isLoading &&
                  widget.controller.hasMore &&
                  widget.controller.error == null &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent -
                          widget.scrollOffset) {
                widget.controller.loadMore();
              }
              return false;
            },
            child: widget.child,
          ),
        ),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: widget.newPageProgressIndicator ??
                  const CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: widget.newPageErrorIndicator ??
                Center(
                  child: Column(
                    children: [
                      Text('Error: $error'),
                      TextButton(
                        onPressed: () => widget.controller.loadMore(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
          )
        else if (!hasMore)
          widget.noMoreItemsIndicator ?? const SizedBox.shrink(),
      ],
    );
  }
}
