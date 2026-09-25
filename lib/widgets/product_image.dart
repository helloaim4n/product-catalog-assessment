import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final double borderRadius;

  const ProductImage({super.key, required this.url, this.borderRadius = 16});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: colors.surfaceContainer,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const SizedBox.expand();
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colors.onSurfaceVariant,
                semanticLabel: 'Image unavailable',
              ),
            );
          },
        ),
      ),
    );
  }
}
