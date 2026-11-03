// lib/bloc/currency_state.dart
import 'package:fl_chart/fl_chart.dart'; // handles chart mapping
import '../models/currency.dart';
import '../models/exchange_rate.dart';
import '../models/rate_point.dart'; // handles historical data

// four posible states to be displayed in the screen.
enum RateStatus { initial, loading, loaded, error }

class CurrencyState {
  final RateStatus status;
  final RateStatus historyStatus; // tracks chart loading independently
  final List<Currency> currencies;
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final double amount;
  final ExchangeRate? exchangeRate;
  final List<RatePoint> historyRates; // holds the 7-day data
  final String? errorMessage;
  final String? historyErrorMessage; //Independent chart errors
  final bool isStale;
  final List<String> favorites;

  const CurrencyState({
    this.status = RateStatus.initial,
    this.historyStatus = RateStatus.initial, 
    this.currencies = const [],
    this.baseCurrencyCode = 'USD', // default starting pair
    this.targetCurrencyCode = 'EUR',
    this.amount = 1.0, // default amount
    this.exchangeRate,
    this.historyRates = const [], 
    this.errorMessage,
    this.historyErrorMessage,
    this.isStale = false, 
    this.favorites = const [],
  });

  // run the conversion from the base currency to the target currency using the exchange rate and ammount entered.
  double? get convertedAmount {
    if (exchangeRate == null) return null;
    return exchangeRate!.convert(amount,targetCurrencyCode);
  }

  // pulls the rateLabel from the exchangeRate object, if it exists. If not, returns null.
  String? get rateLabel {
    return exchangeRate?.rateLabel(targetCurrencyCode);
  }

  // map RatePoints to FlSpot for the chart outside the widget tree
  List<FlSpot> get chartSpots {
    List<FlSpot> spots = [];
    for (int i = 0; i < historyRates.length; i++) {
      spots.add(FlSpot(i.toDouble(), historyRates[i].rate));
    }
    return spots;
  }

  CurrencyState copyWith({
    RateStatus? status,
    RateStatus? historyStatus,
    List<Currency>? currencies,
    String? baseCurrencyCode,
    String? targetCurrencyCode,
    double? amount,
    ExchangeRate? exchangeRate,
    List<RatePoint>? historyRates,
    String? errorMessage,
    String? historyErrorMessage,
    bool? isStale, 
    List<String>? favorites,
  }) {
    return CurrencyState(
      status: status ?? this.status,
      historyStatus: historyStatus ?? this.historyStatus,
      currencies: currencies ?? this.currencies,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      amount: amount ?? this.amount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      historyRates: historyRates ?? this.historyRates,
      errorMessage: errorMessage ?? this.errorMessage,
      historyErrorMessage: historyErrorMessage ?? this.historyErrorMessage,
      isStale: isStale ?? this.isStale, 
      favorites: favorites ?? this.favorites, 
    );
  }
}