import 'package:flutter/material.dart';
import 'super_scroll_controller.dart';
import 'super_scroll_base.dart';
import 'super_skeleton.dart';

/// A dependency-free masonry-style grid that supports pagination.
/// 
/// It distributes items across multiple columns.
class SuperMasonryGridView<T> extends StatelessWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool reverse;

  /// Indicators for different states
  final Widget? newPageProgressIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? noMoreItemsIndicator;
  final Widget? firstPageProgressIndicator;
  final Widget? noItemsFoundIndicator;

  const SuperMasonryGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.newPageProgressIndicator,
    this.newPageErrorIndicator,
    this.noMoreItemsIndicator,
    this.firstPageProgressIndicator,
    this.noItemsFoundIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.items;
        final isLoading = controller.isLoading;
        final hasMore = controller.hasMore;
        final error = controller.error;

        if (items.isEmpty && isLoading) {
          return firstPageProgressIndicator ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SuperSkeleton(height: 150, margin: EdgeInsets.only(bottom: 12)),
                      SuperSkeleton(height: 100, margin: EdgeInsets.only(bottom: 12)),
                      SuperSkeleton(height: 200),
                    ],
                  ),
                ),
              );
        }

        if (items.isEmpty && !isLoading && !hasMore) {
          return noItemsFoundIndicator ??
              const Center(child: Text('No items found'));
        }

        // Distribute items into columns (Round-robin for simple in-built version)
        final List<List<T>> columns = List.generate(crossAxisCount, (_) => []);
        for (int i = 0; i < items.length; i++) {
          columns[i % crossAxisCount].add(items[i]);
        }

        final content = SingleChildScrollView(
          controller: scrollController,
          padding: padding,
          physics: physics,
          reverse: reverse,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(crossAxisCount, (colIndex) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: colIndex == 0 ? 0 : crossAxisSpacing / 2,
                        right: colIndex == crossAxisCount - 1 ? 0 : crossAxisSpacing / 2,
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < columns[colIndex].length; i++)
                            Padding(
                              padding: EdgeInsets.only(bottom: mainAxisSpacing),
                              child: itemBuilder(context, columns[colIndex][i], 
                                  items.indexOf(columns[colIndex][i])),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              // Footer items
              if (isLoading)
                newPageProgressIndicator ??
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Center(
                        child: SuperSkeleton(
                          height: 20,
                          width: 200,
                        ),
                      ),
                    ),
              if (error != null)
                newPageErrorIndicator ??
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
              if (!hasMore && items.isNotEmpty)
                noMoreItemsIndicator ?? const SizedBox.shrink(),
            ],
          ),
        );

        return SuperScroll(
          controller: controller,
          scrollController: scrollController,
          showFooter: false,
          child: content,
        );
      },
    );
  }
}
