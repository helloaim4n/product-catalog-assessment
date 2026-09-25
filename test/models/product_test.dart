import 'package:product_catalog_app_assessment/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a full product from JSON', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Red Lipstick',
      'price': 12.99,
      'thumbnail': 'https://example.com/thumb.jpg',
      'description': 'A classic red.',
      'rating': 4.36,
      'reviews': [{}, {}, {}],
      'images': ['https://example.com/1.jpg'],
    });

    expect(product.id, 1);
    expect(product.title, 'Red Lipstick');
    expect(product.price, 12.99);
    expect(product.rating, 4.36);
    expect(product.reviewCount, 3);
    expect(product.images, ['https://example.com/1.jpg']);
  });

  test('uses defaults for fields the list endpoint leaves out', () {
    final product = Product.fromJson({
      'id': 2,
      'title': 'Eggs',
      'price': 3,
      'thumbnail': 'https://example.com/eggs.jpg',
    });

    expect(product.price, 3.0);
    expect(product.description, '');
    expect(product.reviewCount, 0);
    expect(product.images, ['https://example.com/eggs.jpg']);
  });
}
