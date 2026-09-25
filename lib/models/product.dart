/// List requests only ask for id, title, price and thumbnail, so the detail
/// fields have defaults.
class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.description = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] as String? ?? '';
    final images = (json['images'] as List<dynamic>? ?? [])
        .map((image) => image as String)
        .toList();

    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      thumbnail: thumbnail,
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      reviewCount: (json['reviews'] as List<dynamic>? ?? []).length,
      images: images.isNotEmpty ? images : [thumbnail],
    );
  }
}
