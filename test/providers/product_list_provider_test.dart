import 'dart:async';

import 'package:product_catalog_app_assessment/providers/product_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_api.dart';

void main() {
  late FakeApi fake;
  late ProviderContainer container;

  ProductListState state() => container.read(productListProvider);
  ProductListNotifier notifier() =>
      container.read(productListProvider.notifier);

  // Lets pending requests finish.
  Future<void> wait() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    fake = FakeApi();
    container = ProviderContainer(overrides: fake.overrides);
    addTearDown(container.dispose);
    state(); 
    await wait();
  });

  test('loads the first 20 products', () {
    expect(state().isLoading, isFalse);
    expect(state().products, hasLength(20));
    expect(state().total, 45);
    expect(state().hasMore, isTrue);
  });

  test('loadMore adds the next page until everything is loaded', () async {
    await notifier().loadMore();
    expect(state().products, hasLength(40));

    await notifier().loadMore();
    expect(state().products, hasLength(45));
    expect(state().hasMore, isFalse);
    expect(fake.requests.map((url) => url.queryParameters['skip']), [
      '0',
      '20',
      '40',
    ]);
  });

  test('a failed page keeps the products and waits for Tap to retry', () async {
    fake.offline = true;
    await notifier().loadMore();

    expect(state().products, hasLength(20));
    expect(state().loadMoreError, isNotNull);

    // Scrolling again does not retry by itself...
    await notifier().loadMore();
    expect(fake.requests, hasLength(2));

    // ...but Tap to retry does.
    fake.offline = false;
    await notifier().retryLoadMore();
    expect(state().products, hasLength(40));
  });

  test('search waits until typing pauses, then sends one request', () async {
    notifier().onSearchChanged('l');
    notifier().onSearchChanged('la');
    notifier().onSearchChanged('lamp');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final searches = fake.requests.where(
      (url) => url.path == '/products/search',
    );
    expect(searches.map((url) => url.queryParameters['q']), ['lamp']);
    expect(
      state().products.every((p) => p.title.startsWith('Desk Lamp')),
      isTrue,
    );
  });

  test('an old search that answers late is ignored', () async {
    fake.holdNextRequest = Completer<void>();
    final slowAnswer = fake.holdNextRequest!;

    notifier().search('phone'); // held
    notifier().search('lamp'); // answers first
    await wait();
    slowAnswer.complete(); // "phone" answers last
    await wait();

    expect(state().query, 'lamp');
    expect(
      state().products.every((p) => p.title.startsWith('Desk Lamp')),
      isTrue,
    );
  });

  test('a failed first load can be retried', () async {
    fake.offline = true;
    await notifier().loadFirstPage();
    expect(state().error, isNotNull);

    fake.offline = false;
    await notifier().loadFirstPage();
    expect(state().error, isNull);
    expect(state().products, hasLength(20));
  });
}
