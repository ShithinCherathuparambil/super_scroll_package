import 'package:flutter/material.dart';
import 'super_scroll_controller.dart';
import 'super_scroll_base.dart';

class SuperGridView<T> extends StatefulWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;
  final VoidCallback? onRefresh;
  final ScrollController? scrollController;

  /// Widget to display at the bottom when loading subsequent pages.
  final Widget? newPageProgressIndicator;

  /// Widget to display when the first page is loading.
  final Widget? firstPageProgressIndicator;

  /// Widget to display when an error occurs fetching the first page.
  final Widget? firstPageErrorIndicator;

  /// Widget to display when an error occurs fetching a subsequent page.
  final Widget? newPageErrorIndicator;

  /// Widget to display when no items were found on the first page.
  final Widget? noItemsFoundIndicator;

  /// Widget to display when there are no more items to load.
  final Widget? noMoreItemsIndicator;

  const SuperGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.onRefresh,
    this.scrollController,
    this.newPageProgressIndicator,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
  });

  SuperGridView.count({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.onRefresh,
    this.scrollController,
    this.newPageProgressIndicator,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
  }) : gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        );

  SuperGridView.extent({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.onRefresh,
    this.scrollController,
    this.newPageProgressIndicator,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
  }) : gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        );

  @override
  State<SuperGridView<T>> createState() => _SuperGridViewState<T>();
}

class _SuperGridViewState<T> extends State<SuperGridView<T>> {
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());

  @override
  void initState() {
    super.initState();
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
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final scrollController = _effectiveController;

        Widget gridView = GridView.builder(
          controller: scrollController,
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          reverse: widget.reverse,
          gridDelegate: widget.gridDelegate,
          itemCount: widget.controller.items.length,
          itemBuilder: (context, index) => widget.itemBuilder(
            context,
            widget.controller.items[index],
            index,
          ),
        );

        Widget content = SuperScroll(
          controller: widget.controller,
          scrollController: scrollController,
          newPageProgressIndicator: widget.newPageProgressIndicator,
          firstPageProgressIndicator: widget.firstPageProgressIndicator,
          firstPageErrorIndicator: widget.firstPageErrorIndicator,
          newPageErrorIndicator: widget.newPageErrorIndicator,
          noItemsFoundIndicator: widget.noItemsFoundIndicator,
          noMoreItemsIndicator: widget.noMoreItemsIndicator,
          child: gridView,
        );

        if (widget.onRefresh != null) {
          return RefreshIndicator(
            onRefresh: () async => widget.onRefresh!(),
            child: content,
          );
        }

        return content;
      },
    );
  }
}
