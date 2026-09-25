import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/product_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ProviderScope(
      retry: (retryCount, error) => null,
      child: const CatalogApp(),
    ),
  );
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ProductListScreen(),
    );
  }
}
