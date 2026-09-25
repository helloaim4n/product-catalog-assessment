import 'dart:async';
import 'dart:convert';

import 'package:product_catalog_app_assessment/services/product_api.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeApi {
  final requests = <Uri>[];
  bool offline = false;

  Completer<void>? holdNextRequest;

  late final http.Client client = MockClient(_handle);

  List<Override> get overrides => [
    productApiProvider.overrideWithValue(ProductApi(client)),
  ];

  static const _kinds = ['Phone Case', 'Desk Lamp', 'Linen Sofa'];

  final _products = [
    for (var id = 1; id <= 45; id++)
      {
        'id': id,
        'title': '${_kinds[(id - 1) % 3]} $id',
        'price': id * 10 + 0.99,
        'thumbnail': 'https://example.com/$id.jpg',
        'description': 'Description of product $id.',
        'rating': 4.5,
        'reviews': [{}, {}, {}],
        'images': [
          'https://example.com/$id-a.jpg',
          'https://example.com/$id-b.jpg',
        ],
      },
  ];

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request.url);

    final hold = holdNextRequest;
    if (hold != null) {
      holdNextRequest = null;
      await hold.future;
    }
    if (offline) throw http.ClientException('No internet');

    final path = request.url.pathSegments;
    final params = request.url.queryParameters;

    if (path.length == 1) return _page(_products, params);
    if (path[1] == 'search') {
      final query = params['q']!.toLowerCase();
      return _page(
        _products
            .where((p) => '${p['title']}'.toLowerCase().contains(query))
            .toList(),
        params,
      );
    }
    final id = int.parse(path[1]);
    if (id > _products.length) {
      return _json({'message': 'Not found'}, status: 404);
    }
    return _json(_products[id - 1]);
  }

  http.Response _page(
    List<Map<String, Object>> matches,
    Map<String, String> params,
  ) {
    final skip = int.parse(params['skip'] ?? '0');
    final limit = int.parse(params['limit'] ?? '30');
    return _json({
      'products': matches.skip(skip).take(limit).toList(),
      'total': matches.length,
      'skip': skip,
      'limit': limit,
    });
  }

  http.Response _json(Object body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}
