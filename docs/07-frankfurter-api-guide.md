# Frankfurter API — Integration Guide

> **Who this is for:** This document is a practical reference for mentees integrating the Frankfurter exchange-rate API into their Flutter project. It picks up where [`02-tier-1-base.md`](02-tier-1-base.md) and [`03-tier-2-intermediate.md`](03-tier-2-intermediate.md) leave off — the tier documents tell you *what* to build; this document shows you *how* to talk to the API and wire it into your architecture.

---

## Table of Contents

1. [Why Frankfurter?](#1-why-frankfurter)
2. [Base URL and API Version](#2-base-url-and-api-version)
3. [Endpoints You Need](#3-endpoints-you-need)
4. [Real JSON Responses](#4-real-json-responses)
5. [Model Classes](#5-model-classes)
6. [Remote Data Source](#6-remote-data-source)
7. [Repository Layer](#7-repository-layer)
8. [BLoC Wiring](#8-bloc-wiring)
9. [Error Handling](#9-error-handling)
10. [Loading States in the UI](#10-loading-states-in-the-ui)
11. [Folder Structure Recap](#11-folder-structure-recap)
12. [End-to-End Worked Example](#12-end-to-end-worked-example)
13. [Tier 2 — History Chart Endpoint](#13-tier-2--history-chart-endpoint)

---

## 1. Why Frankfurter?

| Property | Detail |
|---|---|
| **API key required?** | No — call the API from day one, no registration |
| **Usage quota?** | No hard daily or monthly caps |
| **Historical data?** | Yes — daily rates back to 1948, no mock fallbacks needed |
| **Currencies supported** | 201 currencies from 84 central banks |
| **Official site** | https://frankfurter.dev |
| **Base URL (v2)** | `https://api.frankfurter.dev/v2` |

---

## 2. Base URL and API Version

This project targets **v2** of the Frankfurter API. Define the base URL as a constant so it never appears as a magic string in your code:

```dart
// lib/core/constants/api_constants.dart

abstract final class ApiConstants {
  static const String baseUrl = 'https://api.frankfurter.dev/v2';
}
```

> **Tip:** Keeping constants in a dedicated file means a URL change is a one-line fix anywhere in the project.

---

## 3. Endpoints You Need

### 3.1 — List All Currencies (Tier 1)

Fetches every currency the API supports, including its ISO code and human-readable name.

```
GET /currencies
```

**Full URL:**
```
https://api.frankfurter.dev/v2/currencies
```

**When to call it:** Once, on app start. Store the list so the user can pick from a dropdown.

---

### 3.2 — Latest Exchange Rate for a Pair (Tier 1)

Fetches the current rate between exactly two currencies. This is the primary endpoint for your converter.

```
GET /rate/{base}/{quote}
```

**Full URL example** (USD to EUR):
```
https://api.frankfurter.dev/v2/rate/USD/EUR
```

**When to call it:** Every time the user selects a new currency pair or taps "refresh".

---

### 3.3 — Latest Rates for Multiple Targets (Tier 1 and 2)

Fetches the latest rate from one base currency to several target currencies at once. Used for the multi-currency comparison list in Tier 2.

```
GET /rates?base={base}&quotes={quote1},{quote2},...
```

**Full URL example** (USD to EUR, GBP, JPY, and NGN):
```
https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR,GBP,JPY,NGN
```

---

### 3.4 — Time-Series / 7-Day History (Tier 2)

Fetches daily rates for a currency pair over a date range. Used for the history chart.

```
GET /rates?base={base}&quotes={quote}&from={YYYY-MM-DD}&to={YYYY-MM-DD}
```

**Full URL example** (7 days of USD to EUR):
```
https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR&from=2026-07-10&to=2026-07-17
```

---

## 4. Real JSON Responses

These are live, unmodified responses from the API so you know exactly what shapes to parse.

### 4.1 — `/currencies` Response

Returns a JSON array. Each element has these fields:

```json
[
  {
    "iso_code": "USD",
    "iso_numeric": "840",
    "name": "United States Dollar",
    "symbol": "$",
    "start_date": "1948-06-21",
    "end_date": "2026-07-17"
  },
  {
    "iso_code": "EUR",
    "iso_numeric": "978",
    "name": "Euro",
    "symbol": "EUR",
    "start_date": "1999-01-04",
    "end_date": "2026-07-17"
  }
]
```

> **Note:** The array contains 201 items. For your dropdown you only need `iso_code` and `name`. `symbol` is a bonus for display polish.

---

### 4.2 — `/rate/{base}/{quote}` Response

Returns a single JSON object:

```json
{
  "date": "2026-07-17",
  "base": "USD",
  "quote": "EUR",
  "rate": 0.87241
}
```

---

### 4.3 — `/rates?base=...&quotes=...` Response

Returns a JSON array — one object per requested target currency:

```json
[
  { "date": "2026-07-17", "base": "USD", "quote": "EUR", "rate": 0.87241 },
  { "date": "2026-07-17", "base": "USD", "quote": "GBP", "rate": 0.74187 },
  { "date": "2026-07-17", "base": "USD", "quote": "JPY", "rate": 162.37  },
  { "date": "2026-07-17", "base": "USD", "quote": "NGN", "rate": 1388.28 }
]
```

---

### 4.4 — Time-Series Response

Same array structure, but with one entry per calendar day in the range. Weekends repeat the last business-day rate:

```json
[
  { "date": "2026-07-10", "base": "USD", "quote": "EUR", "rate": 0.87398 },
  { "date": "2026-07-11", "base": "USD", "quote": "EUR", "rate": 0.87398 },
  { "date": "2026-07-12", "base": "USD", "quote": "EUR", "rate": 0.87398 },
  { "date": "2026-07-13", "base": "USD", "quote": "EUR", "rate": 0.87511 },
  { "date": "2026-07-14", "base": "USD", "quote": "EUR", "rate": 0.87536 },
  { "date": "2026-07-15", "base": "USD", "quote": "EUR", "rate": 0.87490 },
  { "date": "2026-07-16", "base": "USD", "quote": "EUR", "rate": 0.87260 },
  { "date": "2026-07-17", "base": "USD", "quote": "EUR", "rate": 0.87241 }
]
```

> **Tip for the chart:** Weekend entries duplicate the last Friday rate. That is expected — simply plot all dates as-is. The flat segment on weekends is accurate.

---

## 5. Model Classes

Never pass raw `Map<String, dynamic>` between layers. Define typed models and parse JSON in one place.

### 5.1 — `Currency`

```dart
// lib/models/currency.dart

class Currency {
  final String code;    // e.g. "USD"
  final String name;    // e.g. "United States Dollar"
  final String symbol;  // e.g. "$"

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  /// Builds a Currency from one element of the /currencies JSON array.
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['iso_code'] as String,
      name: json['name'] as String,
      symbol: (json['symbol'] as String?) ?? '',
    );
  }

  /// Derives an emoji flag from the first two letters of the currency code.
  /// Works for most major currencies; commodities (XAU, XAG) will not match.
  String get flagEmoji {
    final countryCode = code.substring(0, 2);
    return countryCode.split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) - 0x41 + 0x1F1E6);
    }).join();
  }

  @override
  String toString() => '$code — $name';
}
```

---

### 5.2 — `ExchangeRate`

```dart
// lib/models/exchange_rate.dart

class ExchangeRate {
  final String base;          // e.g. "USD"
  final String quote;         // e.g. "EUR"
  final double rate;          // e.g. 0.87241
  final DateTime lastUpdated; // parsed from the "date" field

  const ExchangeRate({
    required this.base,
    required this.quote,
    required this.rate,
    required this.lastUpdated,
  });

  /// Parses the response from GET /rate/{base}/{quote}.
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      base: json['base'] as String,
      quote: json['quote'] as String,
      rate: (json['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['date'] as String),
    );
  }

  /// Converts [amount] in the base currency to the quote currency.
  double convert(double amount) => amount * rate;

  /// Human-readable label, e.g. "1 USD = 0.8724 EUR".
  String get rateLabel => '1 $base = ${rate.toStringAsFixed(4)} $quote';
}
```

---

### 5.3 — `RatePoint` (Tier 2 — History Chart)

Holds one data point from the time-series endpoint.

```dart
// lib/models/rate_point.dart

class RatePoint {
  final DateTime date;
  final double rate;

  const RatePoint({required this.date, required this.rate});

  /// Parses one element from the time-series array.
  factory RatePoint.fromJson(Map<String, dynamic> json) {
    return RatePoint(
      date: DateTime.parse(json['date'] as String),
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
```

---

## 6. Remote Data Source

The data source is the **only** place in your app that makes HTTP calls. No widget, BLoC, or repository should ever call `http.get(...)` directly.

```dart
// lib/data/datasources/remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import '../../models/rate_point.dart';

abstract interface class RemoteDataSource {
  Future<List<Currency>> fetchCurrencies();
  Future<ExchangeRate> fetchRate(String base, String quote);
  Future<List<ExchangeRate>> fetchRates(String base, List<String> quotes);
  Future<List<RatePoint>> fetchHistory(String base, String quote, int days);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client _client;

  RemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Currency>> fetchCurrencies() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/currencies');
    final response = await _client.get(uri);
    _checkStatus(response);

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Currency.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExchangeRate> fetchRate(String base, String quote) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/rate/$base/$quote');
    final response = await _client.get(uri);
    _checkStatus(response);

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return ExchangeRate.fromJson(data);
  }

  @override
  Future<List<ExchangeRate>> fetchRates(
      String base, List<String> quotes) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/rates'
      '?base=$base'
      '&quotes=${quotes.join(",")}',
    );
    final response = await _client.get(uri);
    _checkStatus(response);

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ExchangeRate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RatePoint>> fetchHistory(
      String base, String quote, int days) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days - 1));

    // Format a DateTime as YYYY-MM-DD
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}'
        '-${d.month.toString().padLeft(2, '0')}'
        '-${d.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/rates'
      '?base=$base'
      '&quotes=$quote'
      '&from=${fmt(from)}'
      '&to=${fmt(to)}',
    );

    final response = await _client.get(uri);
    _checkStatus(response);

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => RatePoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Throws [ApiException] for any non-2xx status code.
  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    // The API returns {"message": "..."} on error responses.
    String message = 'HTTP ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {}

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

/// Thrown when the Frankfurter API returns a non-2xx HTTP status.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
```

> **Why inject `http.Client`?** It makes the class testable — in unit tests you pass a `MockClient` that returns fake JSON without hitting the real network.

---

## 7. Repository Layer

The repository sits between the data source and the BLoC. It is where you add caching (Tier 2) and translate low-level exceptions into domain errors the BLoC can handle.

```dart
// lib/data/repositories/currency_repository.dart

import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import '../../models/rate_point.dart';

/// Abstract contract — the BLoC depends on this, not on the concrete impl.
abstract interface class CurrencyRepository {
  Future<List<Currency>> getCurrencies();
  Future<ExchangeRate> getRate(String base, String quote);
  Future<List<ExchangeRate>> getRates(String base, List<String> quotes);
  Future<List<RatePoint>> getHistory(String base, String quote, int days);
}
```

```dart
// lib/data/repositories/currency_repository_impl.dart

import '../datasources/remote_data_source.dart';
import 'currency_repository.dart';
import '../../models/currency.dart';
import '../../models/exchange_rate.dart';
import '../../models/rate_point.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final RemoteDataSource _remoteDataSource;

  CurrencyRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Currency>> getCurrencies() =>
      _remoteDataSource.fetchCurrencies();

  @override
  Future<ExchangeRate> getRate(String base, String quote) =>
      _remoteDataSource.fetchRate(base, quote);

  @override
  Future<List<ExchangeRate>> getRates(String base, List<String> quotes) =>
      _remoteDataSource.fetchRates(base, quotes);

  @override
  Future<List<RatePoint>> getHistory(String base, String quote, int days) =>
      _remoteDataSource.fetchHistory(base, quote, days);
}
```

> **For Tier 2 caching:** Add a `SharedPreferences` or `Hive` dependency to `CurrencyRepositoryImpl`. Before calling the data source, check if a cached rate exists and is younger than 1 hour. Only hit the network when the cache is stale or empty.

---

## 8. BLoC Wiring

The BLoC receives events, calls the repository, and emits states. It never touches HTTP or JSON directly.

### Events

```dart
// lib/bloc/currency_event.dart

abstract class CurrencyEvent {}

class LoadCurrencies extends CurrencyEvent {}

class SelectBaseCurrency extends CurrencyEvent {
  final String code;
  SelectBaseCurrency(this.code);
}

class SelectTargetCurrency extends CurrencyEvent {
  final String code;
  SelectTargetCurrency(this.code);
}

class SetAmount extends CurrencyEvent {
  final double amount;
  SetAmount(this.amount);
}

class SwapCurrencies extends CurrencyEvent {}

class FetchRates extends CurrencyEvent {}
```

### State

```dart
// lib/bloc/currency_state.dart

import '../models/currency.dart';
import '../models/exchange_rate.dart';

enum RateStatus { initial, loading, loaded, error }

class CurrencyState {
  final List<Currency> currencies;
  final String baseCurrencyCode;
  final String targetCurrencyCode;
  final double amount;
  final ExchangeRate? exchangeRate;
  final RateStatus status;
  final String? errorMessage;

  const CurrencyState({
    this.currencies = const [],
    this.baseCurrencyCode = 'USD',
    this.targetCurrencyCode = 'EUR',
    this.amount = 1.0,
    this.exchangeRate,
    this.status = RateStatus.initial,
    this.errorMessage,
  });

  /// Converted result — null until a rate has been fetched.
  double? get convertedAmount =>
      exchangeRate != null ? exchangeRate!.convert(amount) : null;

  /// Human-readable rate string, e.g. "1 USD = 0.8724 EUR".
  String? get rateLabel => exchangeRate?.rateLabel;

  CurrencyState copyWith({
    List<Currency>? currencies,
    String? baseCurrencyCode,
    String? targetCurrencyCode,
    double? amount,
    ExchangeRate? exchangeRate,
    RateStatus? status,
    String? errorMessage,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      amount: amount ?? this.amount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

### BLoC

```dart
// lib/bloc/currency_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/currency_repository.dart';
import '../data/datasources/remote_data_source.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyRepository _repository;

  CurrencyBloc(this._repository) : super(const CurrencyState()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<SelectBaseCurrency>(_onSelectBase);
    on<SelectTargetCurrency>(_onSelectTarget);
    on<SetAmount>(_onSetAmount);
    on<SwapCurrencies>(_onSwap);
    on<FetchRates>(_onFetchRates);
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(state.copyWith(status: RateStatus.loading));
    try {
      final currencies = await _repository.getCurrencies();
      emit(state.copyWith(currencies: currencies, status: RateStatus.loaded));
      add(FetchRates()); // fetch rates for the default pair immediately
    } on SocketException {
      emit(state.copyWith(
        status: RateStatus.error,
        errorMessage: 'No internet connection.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: RateStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: RateStatus.error,
        errorMessage: 'Could not load currencies. Please try again.',
      ));
    }
  }

  Future<void> _onFetchRates(
    FetchRates event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(state.copyWith(status: RateStatus.loading));
    try {
      final rate = await _repository.getRate(
        state.baseCurrencyCode,
        state.targetCurrencyCode,
      );
      emit(state.copyWith(
        exchangeRate: rate,
        status: RateStatus.loaded,
        errorMessage: null,
      ));
    } on SocketException {
      emit(state.copyWith(
        status: RateStatus.error,
        errorMessage: 'No internet connection.',
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(status: RateStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: RateStatus.error,
        errorMessage: 'Could not fetch rate. Please try again.',
      ));
    }
  }

  void _onSelectBase(
      SelectBaseCurrency event, Emitter<CurrencyState> emit) {
    emit(state.copyWith(baseCurrencyCode: event.code));
    add(FetchRates());
  }

  void _onSelectTarget(
      SelectTargetCurrency event, Emitter<CurrencyState> emit) {
    emit(state.copyWith(targetCurrencyCode: event.code));
    add(FetchRates());
  }

  void _onSetAmount(SetAmount event, Emitter<CurrencyState> emit) {
    // No network call needed — conversion is local arithmetic on the stored rate.
    emit(state.copyWith(amount: event.amount));
  }

  void _onSwap(SwapCurrencies event, Emitter<CurrencyState> emit) {
    emit(state.copyWith(
      baseCurrencyCode: state.targetCurrencyCode,
      targetCurrencyCode: state.baseCurrencyCode,
      exchangeRate: null, // clear stale rate before refreshing
    ));
    add(FetchRates());
  }
}
```

---

## 9. Error Handling

### What can go wrong?

| Scenario | Type | How to detect |
|---|---|---|
| No internet | `SocketException` | `on SocketException` catch clause |
| Bad currency code (typo) | `ApiException` (404) | `statusCode == 404` |
| Malformed query parameter | `ApiException` (400) | `statusCode == 400` |
| API server error | `ApiException` (500+) | `statusCode >= 500` |
| Request timeout | `TimeoutException` | `.timeout(duration)` on the future |

### The rule: never let an error reach a widget unseen

Every failure path must produce a state with `status: RateStatus.error` and a human-readable `errorMessage`. The widget shows that message. A raw exception string or a blank screen is always a bug.

---

## 10. Loading States in the UI

Use Dart's `switch` expression on `RateStatus` so the compiler forces you to handle every case:

```dart
BlocBuilder<CurrencyBloc, CurrencyState>(
  builder: (context, state) {
    return switch (state.status) {
      RateStatus.initial => const Center(
          child: Text('Select currencies to get started'),
        ),
      RateStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      RateStatus.error => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                // Always give the user a way to retry without restarting.
                onPressed: () =>
                    context.read<CurrencyBloc>().add(FetchRates()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      RateStatus.loaded => ConversionResult(state: state),
    };
  },
)
```

> **Rule of thumb:** Every error state needs a Retry button. Do not make a user restart the app to recover from a temporary network blip.

---

## 11. Folder Structure Recap

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart             <- base URL constant
├── models/
│   ├── currency.dart                      <- Currency model
│   ├── exchange_rate.dart                 <- ExchangeRate model
│   └── rate_point.dart                    <- RatePoint (Tier 2)
├── data/
│   ├── datasources/
│   │   └── remote_data_source.dart        <- HTTP calls + ApiException
│   └── repositories/
│       ├── currency_repository.dart       <- abstract interface
│       └── currency_repository_impl.dart  <- concrete implementation
├── bloc/
│   ├── currency_bloc.dart                 <- event handlers
│   ├── currency_event.dart                <- event classes
│   └── currency_state.dart               <- state class + RateStatus enum
├── widgets/
│   ├── currency_dropdown.dart
│   ├── amount_input.dart
│   ├── conversion_result.dart
│   └── rate_info.dart
├── screens/
│   └── converter_screen.dart
└── main.dart                              <- dependency injection
```

---

## 12. End-to-End Worked Example

This traces a complete user journey: **app launches, currencies load, user picks USD to NGN, enters 50, sees the result.**

### Step 1 — Dependency injection in `main.dart`

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bloc/currency_bloc.dart';
import 'bloc/currency_event.dart';
import 'data/datasources/remote_data_source.dart';
import 'data/repositories/currency_repository_impl.dart';
import 'screens/converter_screen.dart';

void main() => runApp(const FxConverterApp());

class FxConverterApp extends StatelessWidget {
  const FxConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Dependency chain: http.Client -> DataSource -> Repository -> BLoC
      create: (_) => CurrencyBloc(
        CurrencyRepositoryImpl(
          RemoteDataSourceImpl(client: http.Client()),
        ),
      )..add(LoadCurrencies()), // first API call on startup
      child: const MaterialApp(
        title: 'FX Converter',
        home: ConverterScreen(),
      ),
    );
  }
}
```

### Step 2 — BLoC handles `LoadCurrencies`

1. Emits `status: RateStatus.loading` → UI shows a `CircularProgressIndicator`.
2. Calls `repository.getCurrencies()` which calls `dataSource.fetchCurrencies()`.
3. HTTP GET `https://api.frankfurter.dev/v2/currencies` returns a 201-item array.
4. Each item is parsed into a `Currency` object via `Currency.fromJson(...)`.
5. Emits `status: RateStatus.loaded, currencies: [...]`.
6. Dispatches `FetchRates()` for the default pair (USD to EUR).

### Step 3 — User selects NGN as the target

The dropdown dispatches:
```dart
context.read<CurrencyBloc>().add(SelectTargetCurrency('NGN'));
```

BLoC handler:
```dart
void _onSelectTarget(SelectTargetCurrency event, Emitter<CurrencyState> emit) {
  emit(state.copyWith(targetCurrencyCode: 'NGN'));
  add(FetchRates()); // fires a new HTTP request
}
```

### Step 4 — Rate is fetched

HTTP GET:
```
https://api.frankfurter.dev/v2/rate/USD/NGN
```

API response:
```json
{ "date": "2026-07-17", "base": "USD", "quote": "NGN", "rate": 1388.28 }
```

BLoC emits:
```dart
state.copyWith(
  exchangeRate: ExchangeRate(base: 'USD', quote: 'NGN', rate: 1388.28, ...),
  status: RateStatus.loaded,
)
```

### Step 5 — User types 50

```dart
context.read<CurrencyBloc>().add(SetAmount(50.0));
```

The BLoC stores the new amount and re-emits state. **No network call happens.** The conversion is pure arithmetic using the already-stored rate.

### Step 6 — Widget displays the result

```dart
BlocBuilder<CurrencyBloc, CurrencyState>(
  builder: (context, state) {
    final result = state.convertedAmount; // 50.0 * 1388.28 = 69414.0
    return Text(
      result != null
          ? '${result.toStringAsFixed(2)} ${state.targetCurrencyCode}'
          : '--',
      style: Theme.of(context).textTheme.headlineLarge,
    );
  },
)
```

**Displayed:** `69414.00 NGN`

The `convertedAmount` getter on `CurrencyState` does the maths:
```dart
double? get convertedAmount =>
    exchangeRate != null ? exchangeRate!.convert(amount) : null;
```

No conversion logic lives in the widget.

---

## 13. Tier 2 — History Chart Endpoint

For the 7-day rate history chart, call the time-series endpoint and map the results to `fl_chart` data.

### Fetching the data

```dart
// Already implemented in RemoteDataSourceImpl.fetchHistory()
final List<RatePoint> history = await repository.getHistory('USD', 'NGN', 7);
```

This gives you a list of 7 `RatePoint` objects, one per calendar day.

### Converting to `FlSpot` data for fl_chart

`LineChart` from `fl_chart` takes a list of `FlSpot(x, y)`. Use the list index as `x` and the rate as `y`:

```dart
List<FlSpot> toChartSpots(List<RatePoint> points) {
  return List.generate(points.length, (i) {
    return FlSpot(i.toDouble(), points[i].rate);
  });
}
```

### X-axis date labels

Keep a reference to the `points` list and look up by index in `getTitlesWidget`:

```dart
getTitlesWidget: (value, meta) {
  final index = value.toInt();
  if (index < 0 || index >= points.length) return const SizedBox.shrink();
  final date = points[index].date;
  return Text(
    '${date.month}/${date.day}',
    style: const TextStyle(fontSize: 10),
  );
},
```

### Managing history state in BLoC

The history fetch must be managed in BLoC — not directly in a widget. Add a separate event and extend your state to carry history data:

```dart
class FetchHistory extends CurrencyEvent {}

// In CurrencyState, add:
final List<RatePoint> rateHistory;
final RateStatus historyStatus;
```

Handle it in a separate `on<FetchHistory>` handler, keeping history loading and live-rate loading independent of each other.

---

## Quick Reference Cheat Sheet

| What you need | Endpoint | Response shape |
|---|---|---|
| All available currencies | `GET /currencies` | `List<Currency>` (201 items) |
| Live rate for one pair | `GET /rate/{base}/{quote}` | Single `ExchangeRate` object |
| Live rates for multiple targets | `GET /rates?base=X&quotes=A,B,C` | `List<ExchangeRate>` |
| 7-day history for a pair | `GET /rates?base=X&quotes=Y&from=...&to=...` | `List<RatePoint>` |

---

*Have a question about something not covered here? Reach your mentor before you get blocked — not after you have spent two hours guessing.*
