import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_api.dart';

class ProductListState {
  final List<Product> products;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final Object? loadMoreError;

  final String query;

  const ProductListState({
    this.products = const [],
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.loadMoreError,
    this.query = '',
  });

  bool get hasMore => products.length < total;

  ProductListState copyWith({
    List<Product>? products,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    Object? loadMoreError,
    String? query,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
      query: query ?? this.query,
    );
  }
}

class ProductListNotifier extends Notifier<ProductListState> {
  static const pageSize = 20;
  static const searchDelay = Duration(milliseconds: 350);

  Timer? _searchTimer;

  ProductApi get _api => ref.read(productApiProvider);

  @override
  ProductListState build() {
    ref.onDispose(() => _searchTimer?.cancel());
    Future.microtask(loadFirstPage);
    return const ProductListState(isLoading: true);
  }

  Future<void> loadFirstPage() async {
    final query = state.query;
    state = state.copyWith(
      products: [],
      total: 0,
      isLoading: true,
      clearError: true,
      clearLoadMoreError: true,
    );

    try {
      final page = await _api.getProducts(
        skip: 0,
        limit: pageSize,
        query: query,
      );
      // The user may have searched for something else while we waited.
      // If so, this answer is out of date, so ignore it.
      if (!_isStillCurrent(query)) return;
      state = state.copyWith(
        products: page.products,
        total: page.total,
        isLoading: false,
      );
    } catch (error) {
      if (!_isStillCurrent(query)) return;
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> loadMore() async {
    // Don't start a second request, and after a failure wait for the user
    // to tap "Tap to retry" instead of retrying on every scroll.
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.loadMoreError != null) {
      return;
    }

    final query = state.query;
    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await _api.getProducts(
        skip: state.products.length,
        limit: pageSize,
        query: query,
      );
      // TODO: if refresh() replaced the list while this page was loading,
      // this appends page 3 after the new page 1 and products 21–40 go
      // missing. Ignore pages that belong to an older list.
      if (!_isStillCurrent(query)) return;
      state = state.copyWith(
        products: [...state.products, ...page.products],
        total: page.total,
        isLoadingMore: false,
      );
    } catch (error) {
      if (!_isStillCurrent(query)) return;
      state = state.copyWith(isLoadingMore: false, loadMoreError: error);
    }
  }

  Future<void> retryLoadMore() {
    state = state.copyWith(clearLoadMoreError: true);
    return loadMore();
  }

  Future<void> refresh() async {
    final query = state.query;
    final page = await _api.getProducts(skip: 0, limit: pageSize, query: query);
    if (!_isStillCurrent(query)) return;
    state = state.copyWith(
      products: page.products,
      total: page.total,
      clearError: true,
      clearLoadMoreError: true,
    );
  }

  /// Called on every keystroke. Waits until typing pauses, so we send one
  /// request instead of one per letter.
  void onSearchChanged(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDelay, () => search(text));
  }

  void search(String text) {
    _searchTimer?.cancel();
    final query = text.trim();
    if (query == state.query && state.error == null) {
      return;
    }
    state = state.copyWith(query: query);
    loadFirstPage();
  }

  bool _isStillCurrent(String query) {
    return ref.mounted && state.query == query;
  }
}

final productListProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
      ProductListNotifier.new,
    );
