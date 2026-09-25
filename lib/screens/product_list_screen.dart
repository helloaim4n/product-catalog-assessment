import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_list_provider.dart';
import '../widgets/list_footer.dart';
import '../widgets/message_view.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_tile.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  bool _isGrid = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ProductListNotifier get _notifier => ref.read(productListProvider.notifier);

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _notifier.refresh();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Couldn’t refresh. Check your connection.'),
        ),
      );
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 500) {
      _notifier.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchRow(),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _notifier.search('');
                        },
                      ),
              ),
              onChanged: (text) {
                setState(() {});
                _notifier.onSearchChanged(text);
              },
              onSubmitted: _notifier.search,
            ),
          ),
          IconButton(
            tooltip: _isGrid ? 'Show as list' : 'Show as grid',
            icon: Icon(
              _isGrid ? Icons.view_list_outlined : Icons.grid_view_outlined,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return MessageView.error(
        error: state.error!,
        onRetry: _notifier.loadFirstPage,
      );
    }

    if (state.products.isEmpty) {
      return MessageView(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: state.query.isNotEmpty
            ? 'Try another word, or clear the search.'
            : 'Nothing here yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            _isGrid ? _buildGrid(state.products) : _buildList(state.products),
            SliverToBoxAdapter(
              child: ListFooter(state: state, onRetry: _notifier.retryLoadMore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
          childAspectRatio: 0.66,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(
          product: products[index],
          onTap: () => _openProduct(products[index]),
        ),
      ),
    );
  }

  Widget _buildList(List<Product> products) {
    return SliverList.separated(
      itemCount: products.length,
      itemBuilder: (context, index) => ProductListTile(
        product: products[index],
        onTap: () => _openProduct(products[index]),
      ),
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 104),
    );
  }
}
