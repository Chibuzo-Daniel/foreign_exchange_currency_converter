import '../../models/currency.dart';
import '../../models/exchange_rate.dart';

//where BLoC  will get data from.
abstract interface class CurrencyRepository {
  Future<List<Currency>> getCurrencies();
  Future<ExchangeRate> getRate(String base, String quote);
}