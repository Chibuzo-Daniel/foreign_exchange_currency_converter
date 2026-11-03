import 'package:dio/dio.dart';
import 'package:foreign_exchange_currency_converter/models/rate_point.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import 'package:intl/intl.dart';

// the exception based on the status code

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

// the interface
abstract interface class RemoteDataSource {
  Future<List<Currency>> fetchCurrencies();
  Future<ExchangeRate> fetchRate(String base, String quote);
  Future<List<RatePoint>> fetchHistory(String base, String quote, int daysBack);
}

// the implementation
class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio client;
  RemoteDataSourceImpl({required this.client});

  // check for server errors.
  void _checkStatus(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message = response.data['message'] ?? 'Unknown API Error';
      throw ApiException(
        statusCode: response.statusCode ?? 500,
        message: message.toString(),
      );
    }
  }

  @override
  Future<List<Currency>> fetchCurrencies() async {
    // build the full URL
    final url = '${ApiConstants.baseUrl}/currencies';

    // get requst from the server
    final response = await client.get(url);

    // check server response
    _checkStatus(response);

    var data = response.data;

    //check if data is a string
    if (data is String) {
      data = jsonDecode(data);
    }
    // The response is  a List
    List<Currency> currencies = [];

    if (data is Map) {
      data.forEach((key, value) {
        currencies.add(Currency(code: key.toString(), name: value.toString()));
      });
    } else if (data is Iterable) {
      for (var item in data) {
        if (item is Map) {
          currencies.add(
            Currency(
              code: item['iso_code']?.toString() ?? 'Unknown',
              name: item['name']?.toString() ?? 'Unknown Currency',
              symbol: item['symbol']?.toString() ?? '',
            ),
          );
        }
      }
      return currencies;
    }

    return currencies;
  }

  @override
  Future<ExchangeRate> fetchRate(String baseCode, String targetCode) async {
    // Build the exact URL for the specific pair (e.g., /rate/USD/EUR)
    final url = '${ApiConstants.baseUrl}/rate/$baseCode/$targetCode';

    // get request from the server
    final response = await client.get(url);

    // check server response
    _checkStatus(response);

    // The response is a single object (Map)
    final Map<String, dynamic> rateMap = Map<String, dynamic>.from(
      response.data,
    );

    if (!rateMap.containsKey('rates') &&
        rateMap.containsKey('quote') &&
        rateMap.containsKey('rate')) {
      rateMap['rates'] = {
        rateMap['quote'].toString(): (rateMap['rate'] as num).toDouble(),
      };
    }
    // pass the map to our model and return the translated exchangeRate object.
    return ExchangeRate.fromJson(rateMap);
  }

@override
  Future<List<RatePoint>> fetchHistory(String baseCode, String targetCode, int daysBack) async {
    // Automatically compute the 'from' and 'to' dates per the rubric
    final toDate = DateTime.now();
    final fromDate = toDate.subtract(Duration(days: daysBack));
    
    final formatter = DateFormat('yyyy-MM-dd');
    final fromStr = formatter.format(fromDate);
    final toStr = formatter.format(toDate);

    // Build URL exactly as specified in the Tier 2 guide
    final url = '${ApiConstants.baseUrl}/rates?base=$baseCode&quotes=$targetCode&from=$fromStr&to=$toStr';

    final response = await client.get(url);
    _checkStatus(response);

// The API returns a JSON array of daily rate objects.

    var data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }
    List<RatePoint> history = [];
    

    if (data is List) {
      for (var item in data) {
        if (item is Map) {
          // Extract the date
          final dateStr = item['date']?.toString() ?? '';
          if (dateStr.isEmpty) continue;

          // Extract the rate (checking for either 'rate' or the specific currency code)
          double rate = 0.0;
          if (item.containsKey('rate')) {
            rate = (item['rate'] as num?)?.toDouble() ?? 0.0;
          } else if (item.containsKey(targetCode)) {
            rate = (item[targetCode] as num?)?.toDouble() ?? 0.0;
          }

          // Build the point directly
          history.add(RatePoint(
            date: DateTime.parse(dateStr),
            rate: rate,
          ));
        }
      }
    }
    
    // Ensure the data is sorted from oldest to newest for the chart
    history.sort((a, b) => a.date.compareTo(b.date));

    return history;
  }
}
