import 'package:flutter/material.dart';

import '../providers/product_list_provider.dart';

class ListFooter extends StatelessWidget {
  final ProductListState state;
  final VoidCallback onRetry;

  const ListFooter({super.key, required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget child;
    if (state.loadMoreError != null) {
      child = Column(
        children: [
          Text('Couldn’t load more products.', style: textTheme.titleSmall),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tap to retry'),
          ),
        ],
      );
    } else if (state.hasMore) {
      child = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading more…'),
        ],
      );
    } else {
      child = Text('You’ve reached the end', style: textTheme.bodySmall);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: child),
    );
  }
}
