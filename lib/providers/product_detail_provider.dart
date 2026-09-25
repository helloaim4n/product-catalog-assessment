import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_api.dart';

/// `autoDispose` frees the product when its screen closes, and `family` keeps
/// one result per product id.
final productDetailProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  id,
) {
  return ref.watch(productApiProvider).getProduct(id);
});
