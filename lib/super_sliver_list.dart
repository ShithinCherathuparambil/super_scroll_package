import 'package:flutter/material.dart';
import 'super_scroll.dart';

/// A [SliverList] that supports pagination using [SuperScrollController].
class SuperSliverList<T> extends StatelessWidget {
  final SuperScrollController<T> controller;
  final SuperItemBuilder<T> itemBuilder;
  final Widget? newPageProgressIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? noMoreItemsIndicator;

  const SuperSliverList({
    super.key,
    required this.controller,
    required this.itemBuilder,
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
        final hasMore = controller.hasMore;
        final isLoading = controller.isLoading;
        final error = controller.error;

        return SliverList.builder(
          itemCount: items.length + (hasMore || error != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < items.length) {
              return itemBuilder(context, items[index], index);
            }

            // Status indicators at the bottom
            if (error != null) {
              return newPageErrorIndicator ??
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
                  );
            }

            if (isLoading) {
              return newPageProgressIndicator ??
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
            }

            if (!hasMore && items.isNotEmpty) {
              return noMoreItemsIndicator ?? const SizedBox.shrink();
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
