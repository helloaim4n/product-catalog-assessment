import 'package:product_catalog_app_assessment/services/product_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_api.dart';

void main() {
  late FakeApi fake;
  late ProductApi api;

  setUp(() {
    fake = FakeApi();
    api = ProductApi(fake.client);
  });

  test('lists products with skip and limit', () async {
    final page = await api.getProducts(skip: 20, limit: 20);

    expect(page.products.first.title, 'Linen Sofa 21');
    expect(page.total, 45);
    final url = fake.requests.single;
    expect(url.path, '/products');
    expect(url.queryParameters['skip'], '20');
    expect(url.queryParameters['limit'], '20');
  });

  test('uses the search endpoint when there is a query', () async {
    final page = await api.getProducts(skip: 0, limit: 20, query: 'lamp');

    expect(fake.requests.single.path, '/products/search');
    expect(fake.requests.single.queryParameters['q'], 'lamp');
    expect(page.products.every((p) => p.title.startsWith('Desk Lamp')), isTrue);
  });

  test('throws a network error when offline', () async {
    fake.offline = true;

    expect(
      () => api.getProducts(skip: 0, limit: 20),
      throwsA(
        isA<ApiException>().having(
          (e) => e.isNetworkError,
          'isNetworkError',
          true,
        ),
      ),
    );
  });

  test('throws "not found" for a product that does not exist', () async {
    expect(
      () => api.getProduct(999),
      throwsA(
        isA<ApiException>().having((e) => e.isNotFound, 'isNotFound', true),
      ),
    );
  });
}
