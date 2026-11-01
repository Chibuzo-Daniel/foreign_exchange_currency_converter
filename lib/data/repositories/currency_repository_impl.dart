import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import '../datasources/remote_data_source.dart';
import 'currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final RemoteDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Currency>> getCurrencies() async {
    //call to get the list of currencies from the data source.
    return await remoteDataSource.fetchCurrencies();
  }

  @override
  Future<ExchangeRate> getRate(String base, String quote) async {
    // call to fetch the specific pair.
    return await remoteDataSource.fetchRate(base, quote);
  }
}