import 'package:dio/dio.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../models/currency.dart';
import '../../models/exchange_rate.dart';

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
}
