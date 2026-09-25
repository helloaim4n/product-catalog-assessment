import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

/// [statusCode] is null when the server could not be reached at all, for
/// example with no internet or a timeout.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isNetworkError => statusCode == null;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// The only class that makes HTTP calls, so the rest of the app never deals
/// with URLs or JSON.
class ProductApi {
  static const _baseUrl = 'dummyjson.com';

  static const _listFields = 'id,title,price,thumbnail';

  final http.Client client;

  ProductApi(this.client);

  Future<ProductPage> getProducts({
    required int skip,
    required int limit,
    String query = '',
  }) async {
    final params = {'limit': '$limit', 'skip': '$skip', 'select': _listFields};

    final Uri url;
    if (query.isNotEmpty) {
      url = Uri.https(_baseUrl, '/products/search', {...params, 'q': query});
    } else {
      url = Uri.https(_baseUrl, '/products', params);
    }

    final json = await _get(url);
    return ProductPage.fromJson(json as Map<String, dynamic>);
  }

  Future<Product> getProduct(int id) async {
    final json = await _get(Uri.https(_baseUrl, '/products/$id'));
    return Product.fromJson(json as Map<String, dynamic>);
  }

  Future<dynamic> _get(Uri url) async {
    final http.Response response;
    try {
      response = await client.get(url).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on Exception {
      throw const ApiException('No internet connection.');
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Unexpected response.',
        statusCode: response.statusCode,
      );
    }
  }
}

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(http.Client());
});
