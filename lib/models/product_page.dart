import 'product.dart';

class ProductPage {
  final List<Product> products;
  final int total;

  const ProductPage({required this.products, required this.total});

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    return ProductPage(
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}
