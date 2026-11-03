import 'package:foreign_exchange_currency_converter/models/rate_point.dart';

import '../../models/currency.dart';
import '../../models/exchange_rate.dart';

//where BLoC  will get data from.
abstract interface class CurrencyRepository {
  Future<List<Currency>> getCurrencies();
  Future<ExchangeRate> getRate(String base, String quote);
  Future<List<RatePoint>> getHistory(String base, String quote, int daysBack);

  Future<bool> isRateStale(String base, String quote);
List<String> getFavorites();
Future<void> toggleFavorite(String pair);
}