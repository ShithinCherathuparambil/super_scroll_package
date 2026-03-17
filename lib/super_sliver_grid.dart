import 'package:flutter/material.dart';
import 'super_scroll.dart';

/// A [SliverGrid] that supports pagination using [SuperScrollController].
class SuperSliverGrid<T> extends StatelessWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget? newPageProgressIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? noMoreItemsIndicator;

  const SuperSliverGrid({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.newPageProgressIndicator,
    this.newPageErrorIndicator,
    this.noMoreItemsIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.items;

        return SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index], index);
          },
        );
      },
    );
  }
}

/// A helper class to wrap SuperSliverGrid with loading indicators.
/// This returns a list of slivers to be used in [CustomScrollView.slivers].
class SuperSliverGridGroup<T> extends StatelessWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget? newPageProgressIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? noMoreItemsIndicator;

  const SuperSliverGridGroup({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.newPageProgressIndicator,
    this.newPageErrorIndicator,
    this.noMoreItemsIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasMore = controller.hasMore;
        final isLoading = controller.isLoading;
        final error = controller.error;

        return SliverMainAxisGroup(
          slivers: [
            SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemCount: controller.items.length,
              itemBuilder: (context, index) =>
                  itemBuilder(context, controller.items[index], index),
            ),
            if (isLoading)
              SliverToBoxAdapter(
                child:
                    newPageProgressIndicator ??
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
              ),
            if (error != null)
              SliverToBoxAdapter(
                child:
                    newPageErrorIndicator ??
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('Error loading more items'),
                            TextButton(
                              onPressed: () => controller.loadMore(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            if (!hasMore && controller.items.isNotEmpty)
              SliverToBoxAdapter(
                child: noMoreItemsIndicator ?? const SizedBox.shrink(),
              ),
          ],
        );
      },
    );
  }
}
