import 'package:flutter/material.dart';
import 'super_scroll_controller.dart';
import 'super_scroll_base.dart';

class SuperListView<T> extends StatefulWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;
  final VoidCallback? onRefresh;
  final ScrollController? scrollController;

  /// Indicators for different states
  final Widget? newPageProgressIndicator;
  final Widget? firstPageProgressIndicator;
  final Widget? firstPageErrorIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? noItemsFoundIndicator;
  final Widget? noMoreItemsIndicator;

  const SuperListView.builder({
    super.key,
    required this.controller,
    required this.itemBuilder,
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
  }) : separatorBuilder = null;

  const SuperListView.separated({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.separatorBuilder,
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

  @override
  State<SuperListView<T>> createState() => _SuperListViewState<T>();
}

class _SuperListViewState<T> extends State<SuperListView<T>> {
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

        Widget listView;
        if (widget.separatorBuilder != null) {
          listView = ListView.separated(
            controller: scrollController,
            padding: widget.padding,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            reverse: widget.reverse,
            itemCount: widget.controller.items.length,
            itemBuilder: (context, index) => widget.itemBuilder(
              context,
              widget.controller.items[index],
              index,
            ),
            separatorBuilder: widget.separatorBuilder!,
          );
        } else {
          listView = ListView.builder(
            controller: scrollController,
            padding: widget.padding,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            reverse: widget.reverse,
            itemCount: widget.controller.items.length,
            itemBuilder: (context, index) => widget.itemBuilder(
              context,
              widget.controller.items[index],
              index,
            ),
          );
        }

        Widget content = SuperScroll(
          controller: widget.controller,
          scrollController: scrollController,
          newPageProgressIndicator: widget.newPageProgressIndicator,
          firstPageProgressIndicator: widget.firstPageProgressIndicator,
          firstPageErrorIndicator: widget.firstPageErrorIndicator,
          newPageErrorIndicator: widget.newPageErrorIndicator,
          noItemsFoundIndicator: widget.noItemsFoundIndicator,
          noMoreItemsIndicator: widget.noMoreItemsIndicator,
          child: listView,
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
