import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_detail_provider.dart';
import '../services/product_api.dart';
import '../utils/formatters.dart';
import '../widgets/image_carousel.dart';
import '../widgets/message_view.dart';
import '../widgets/rating_stars.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(),
      body: productAsync.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          if (error is ApiException && error.isNotFound) {
            return MessageView(
              icon: Icons.search_off_rounded,
              title: 'Product not found',
              message: 'It may have been removed.',
              buttonLabel: 'Back to products',
              onButtonPressed: () => Navigator.of(context).pop(),
            );
          }
          return MessageView.error(
            error: error,
            onRetry: () => ref.invalidate(productDetailProvider(productId)),
          );
        },
        data: (product) => _ProductDetails(product: product),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final Product product;

  const _ProductDetails({required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        ImageCarousel(images: product.images),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, style: textTheme.headlineSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  RatingStars(rating: product.rating),
                  const SizedBox(width: 6),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${product.reviewCount} reviews)',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatPrice(product.price),
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Divider(height: 40),
              Text('Description', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(product.description, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
