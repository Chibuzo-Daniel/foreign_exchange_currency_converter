// lib/bloc/currency_state.dart
import '../models/currency.dart';
import '../models/exchange_rate.dart';

// four posible states to be displayed in the screen.
enum RateStatus { initial, loading, loaded, error }

class CurrencyState {
  final RateStatus status;
  final List<Currency> currencies;
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final double amount;
  final ExchangeRate? exchangeRate;
  final String? errorMessage;

  const CurrencyState({
    this.status = RateStatus.initial,
    this.currencies = const [],
    this.baseCurrencyCode = 'USD', // Default starting pair
    this.targetCurrencyCode = 'EUR',
    this.amount = 1.0, // Default amount
    this.exchangeRate,
    this.errorMessage,
  });

  // run the conversion from the base currency to the target currency using the exchange rate and ammount entered.
  double? get convertedAmount {
    if (exchangeRate == null) return null;
    return exchangeRate!.convert(amount,targetCurrencyCode);
  }

  //  pulls the rateLabel from the exchangeRate object, if it exists. If not, returns null.
  String? get rateLabel {
    return exchangeRate?.rateLabel(targetCurrencyCode);
  }

  CurrencyState copyWith({
    RateStatus? status,
    List<Currency>? currencies,
    String? baseCurrencyCode,
    String? targetCurrencyCode,
    double? amount,
    ExchangeRate? exchangeRate,
    String? errorMessage,
  }) {
    return CurrencyState(
      status: status ?? this.status,
      currencies: currencies ?? this.currencies,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      amount: amount ?? this.amount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}