import 'package:foreign_exchange_currency_converter/data/datasources/local_data_source.dart';
import 'package:foreign_exchange_currency_converter/models/rate_point.dart';

import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import '../datasources/remote_data_source.dart';
import 'currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Currency>> getCurrencies() async {
    //call to get the list of currencies from the data source.
    return await remoteDataSource.fetchCurrencies();
  }

 @override
  Future<ExchangeRate> getRate(String base, String quote) async {
    try {
      //  Try to fetch live data
      final rate = await remoteDataSource.fetchRate(base, quote);
      
      // We need the raw map to cache it. We fetch it again as raw JSON.
      // (If your remoteDataSource.fetchRate already parses it, you can just manually build a JSON map to cache here)
      final rateMap = {
        "base": base,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "rates": { quote: rate.convert(1.0, quote) }
      };
      await localDataSource.cacheRateRawJson(base, quote, rateMap);
      return rate;
    } catch (e) {
      //  If offline/error, fallback to cache
      final cachedJson = await localDataSource.getCachedRateRawJson(base, quote);
      if (cachedJson != null) {
        return ExchangeRate.fromJson(cachedJson);
      }
      rethrow; // If no cache exists, throw error
    }
  }

  @override
  Future<List<RatePoint>> getHistory(
    String base,
    String quote,
    int daysBack,
  ) async {
    // call to fetch the history for the specific pair.
    return await remoteDataSource.fetchHistory(base, quote, daysBack);
  }

  @override
  // Check if cache is older than 1 hour
  Future<bool> isRateStale(String base, String quote) async {
    final timestamp = await localDataSource.getRateTimestamp(base, quote);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp).inHours >= 1;
  }
  
  @override
  // Favorites passthrough
  List<String> getFavorites() => localDataSource.getFavorites();

  @override
  Future<void> toggleFavorite(String pair) => localDataSource.toggleFavorite(pair);
}

