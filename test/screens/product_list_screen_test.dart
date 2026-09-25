import 'package:product_catalog_app_assessment/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_api.dart';

void main() {
  late FakeApi fake;

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: fake.overrides, child: const CatalogApp()),
    );
    await settle(tester);
  }

  setUp(() => fake = FakeApi());

  testWidgets('shows products with their prices', (tester) async {
    await startApp(tester);

    expect(find.text('Phone Case 1'), findsOneWidget);
    expect(find.text(r'$10.99'), findsOneWidget);
  });

  testWidgets('shows "No connection" with a Retry that works', (tester) async {
    fake.offline = true;
    await startApp(tester);

    expect(find.text('No connection'), findsOneWidget);

    fake.offline = false;
    await tester.tap(find.text('Retry'));
    await settle(tester);

    expect(find.text('Phone Case 1'), findsOneWidget);
  });

  testWidgets('tapping a product opens its details', (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Desk Lamp 2'));
    await settle(tester);

    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Description of product 2.'), findsOneWidget);
    expect(find.text('(3 reviews)'), findsOneWidget);
  });
}
