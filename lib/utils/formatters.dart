import 'package:intl/intl.dart';

final _priceFormat = NumberFormat.simpleCurrency(name: 'USD');

String formatPrice(double price) => _priceFormat.format(price);
