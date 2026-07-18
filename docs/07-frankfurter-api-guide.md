# Frankfurter API — Integration Guide

> **Who this is for:** This document is a practical reference for mentees integrating the Frankfurter exchange-rate API into their Flutter project. It picks up where [`02-tier-1-base.md`](02-tier-1-base.md) and [`03-tier-2-intermediate.md`](03-tier-2-intermediate.md) leave off — the tier documents tell you *what* to build; this document tells you what the API gives you and what your architecture is responsible for doing with it. The implementation is yours to write.

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
12. [End-to-End Data Flow](#12-end-to-end-data-flow)
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

This project targets **v2** of the Frankfurter API. Define the base URL once as a constant so it never appears as a magic string anywhere in your code:

```dart
// lib/core/constants/api_constants.dart

abstract final class ApiConstants {
  static const String baseUrl = 'https://api.frankfurter.dev/v2';
}
```

Every endpoint URL in this guide is built from this base.

---

## 3. Endpoints You Need

### 3.1 — List All Currencies (Tier 1)

Fetches every currency the API supports, with its ISO code and human-readable name.

```
GET /currencies
```

**Full URL:**
```
https://api.frankfurter.dev/v2/currencies
```

**When to call it:** Once on app start. Store the result so the user can pick from a dropdown throughout the session.

---

### 3.2 — Latest Rate for a Single Pair (Tier 1)

Fetches the current exchange rate between exactly two currencies.

```
GET /rate/{base}/{quote}
```

**Full URL example** (USD to EUR):
```
https://api.frankfurter.dev/v2/rate/USD/EUR
```

**When to call it:** Every time the user selects a new currency pair, swaps the pair, or manually refreshes.

---

### 3.3 — Latest Rates for Multiple Targets (Tier 1 and 2)

Fetches the latest rate from one base currency to several target currencies at once.

```
GET /rates?base={base}&quotes={quote1},{quote2},...
```

**Full URL example** (USD to EUR, GBP, JPY, and NGN):
```
https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR,GBP,JPY,NGN
```

**When to call it:** Used for the multi-currency comparison list in Tier 2.

---

### 3.4 — Time-Series / 7-Day History (Tier 2)

Fetches daily rates for a currency pair over a date range.

```
GET /rates?base={base}&quotes={quote}&from={YYYY-MM-DD}&to={YYYY-MM-DD}
```

**Full URL example** (7 days of USD to EUR):
```
https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR&from=2026-07-10&to=2026-07-17
```

**When to call it:** When the user views the history chart, and again whenever the currency pair changes.

---

## 4. Real JSON Responses

These are live, unmodified responses from the API. Study the shape of each one carefully — your `fromJson` factories must map exactly these fields.

### 4.1 — `/currencies` Response

Returns a JSON **array**. Each element represents one currency:

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

> The array contains 201 items. For your `Currency` model you only need `iso_code`, `name`, and optionally `symbol`.

---

### 4.2 — `/rate/{base}/{quote}` Response

Returns a **single JSON object**:

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

Returns a JSON **array** — one object per requested target currency:

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

Same array structure as above — one entry per **calendar day** in the requested range. Weekends repeat the last business-day rate (this is expected and accurate):

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

---

## 5. Model Classes

Never pass raw `Map<String, dynamic>` between layers. Define typed models and centralise all JSON parsing inside them via `fromJson` factory constructors.

The brief requires two models at minimum. A third is needed for Tier 2.

---

### 5.1 — `Currency`

**File:** `lib/models/currency.dart`

Your `Currency` class should have these fields:

| Field | Type | Source in JSON | Notes |
|---|---|---|---|
| `code` | `String` | `iso_code` | e.g. `"USD"` |
| `name` | `String` | `name` | e.g. `"United States Dollar"` |
| `symbol` | `String` | `symbol` | e.g. `"$"` — use empty string as fallback if null |

Your class must include:
- A `const` constructor
- A `Currency.fromJson(Map<String, dynamic> json)` factory that maps the fields above
- Optionally: a `flagEmoji` getter — the first two letters of most currency codes match an ISO country code, which can be mapped to a regional indicator emoji

---

### 5.2 — `ExchangeRate`

**File:** `lib/models/exchange_rate.dart`

| Field | Type | Source in JSON | Notes |
|---|---|---|---|
| `base` | `String` | `base` | e.g. `"USD"` |
| `quote` | `String` | `quote` | e.g. `"EUR"` |
| `rate` | `double` | `rate` | Cast via `(json['rate'] as num).toDouble()` |
| `lastUpdated` | `DateTime` | `date` | Parse via `DateTime.parse(...)` |

Your class must include:
- A `const` constructor
- A `ExchangeRate.fromJson(Map<String, dynamic> json)` factory
- A `convert(double amount)` method that returns the converted result — this is pure arithmetic, no API calls
- A `rateLabel` getter that produces a string like `"1 USD = 0.8724 EUR"` — used in the UI

---

### 5.3 — `RatePoint` (Tier 2)

**File:** `lib/models/rate_point.dart`

Holds one data point from the time-series response. Used to populate the history chart.

| Field | Type | Source in JSON |
|---|---|---|
| `date` | `DateTime` | `date` |
| `rate` | `double` | `rate` |

Your class must include a `RatePoint.fromJson(Map<String, dynamic> json)` factory.

---

## 6. Remote Data Source

The data source is the **only** place in your app that makes HTTP calls. No widget, BLoC, or repository should ever call `http.get(...)` directly.

### Define the abstract interface first

```dart
// lib/data/datasources/remote_data_source.dart

abstract interface class RemoteDataSource {
  Future<List<Currency>> fetchCurrencies();
  Future<ExchangeRate> fetchRate(String base, String quote);
  Future<List<ExchangeRate>> fetchRates(String base, List<String> quotes);
  Future<List<RatePoint>> fetchHistory(String base, String quote, int days);
}
```

### Implement the concrete class

Create `RemoteDataSourceImpl` that implements the interface above. Here is one method shown in full to illustrate the pattern — implement the remaining three yourself:

```dart
// One method shown as a reference — implement the others following the same pattern.

Future<ExchangeRate> fetchRate(String base, String quote) async {
  final uri = Uri.parse('${ApiConstants.baseUrl}/rate/$base/$quote');
  final response = await _client.get(uri);

  // You must validate the HTTP status code here.
  // If the status is not 2xx, parse the error body and throw an ApiException.
  _checkStatus(response);

  // Decode the JSON body and hand it to your model's fromJson factory.
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return ExchangeRate.fromJson(data);
}
```

**What you need to implement:**

| Method | Endpoint to call | Response shape | Returns |
|---|---|---|---|
| `fetchCurrencies()` | `GET /currencies` | JSON array | `List<Currency>` |
| `fetchRate(base, quote)` | `GET /rate/{base}/{quote}` | Single JSON object | `ExchangeRate` |
| `fetchRates(base, quotes)` | `GET /rates?base=...&quotes=...` | JSON array | `List<ExchangeRate>` |
| `fetchHistory(base, quote, days)` | `GET /rates?base=...&quotes=...&from=...&to=...` | JSON array | `List<RatePoint>` |

**For `fetchHistory`:** You need to compute `from` and `to` dates dynamically at call time. `to` is today; `from` is `days - 1` days before today. Format both as `YYYY-MM-DD` strings.

**Status checking:** Define a private `_checkStatus(http.Response response)` method. If the status code is not in the 2xx range, decode the response body (the API returns `{"message": "..."}`) and throw an `ApiException`. Define `ApiException` in the same file as a class that implements `Exception` and carries a `statusCode` and `message`.

> **Tip on testability:** Inject `http.Client` through the constructor rather than creating it inside the class. This lets you pass a mock client in tests without hitting the real network.

---

## 7. Repository Layer

The repository sits between the data source and the BLoC. It is where caching belongs (Tier 2), and where you can translate low-level exceptions into errors that make sense at the domain level.

### Define the abstract interface

```dart
// lib/data/repositories/currency_repository.dart

abstract interface class CurrencyRepository {
  Future<List<Currency>> getCurrencies();
  Future<ExchangeRate> getRate(String base, String quote);
  Future<List<ExchangeRate>> getRates(String base, List<String> quotes);
  Future<List<RatePoint>> getHistory(String base, String quote, int days);
}
```

The BLoC must depend on this interface, not on the concrete implementation. This is the repository pattern.

### Implement the concrete class

`CurrencyRepositoryImpl` takes a `RemoteDataSource` as a constructor argument and delegates each method call to it.

For Tier 1, each method is a simple delegation — call the matching data source method and return its result.

For Tier 2 caching, before delegating to the data source, check whether a valid cached result exists (younger than 1 hour). Return the cache if it is still fresh; call the data source and update the cache if it is stale or absent.

---

## 8. BLoC Wiring

The BLoC receives events from the UI, calls the repository, and emits states. It must never know about HTTP, JSON, or the data source.

### Events

Your `CurrencyBloc` must handle at minimum:

| Event | When it is dispatched |
|---|---|
| `LoadCurrencies` | On app start — fetches the full currency list |
| `SelectBaseCurrency(code)` | When the user picks a new base currency |
| `SelectTargetCurrency(code)` | When the user picks a new target currency |
| `SetAmount(amount)` | When the user types a new amount |
| `SwapCurrencies` | When the user taps the swap button |
| `FetchRates` | Internally, after any selection that changes the currency pair |

### State

Your `CurrencyState` must expose:

| Field | Type | Purpose |
|---|---|---|
| `currencies` | `List<Currency>` | Populated on load; backs the dropdowns |
| `baseCurrencyCode` | `String` | Currently selected base |
| `targetCurrencyCode` | `String` | Currently selected target |
| `amount` | `double` | The value the user has entered |
| `exchangeRate` | `ExchangeRate?` | Null until the first fetch completes |
| `status` | `RateStatus` enum | `initial`, `loading`, `loaded`, or `error` |
| `errorMessage` | `String?` | Human-readable error for display |

Add two **derived getters** to `CurrencyState` — do not compute these in the widget:
- `convertedAmount` — `null` if no rate has been fetched, otherwise `amount * rate`
- `rateLabel` — delegates to `ExchangeRate.rateLabel`, or `null` if no rate

### What each event handler must do

**`LoadCurrencies`**
1. Emit a loading state
2. Call `repository.getCurrencies()`
3. On success: emit loaded state with the currency list, then immediately dispatch `FetchRates` for the default pair
4. On failure: emit an error state with a human-readable message

**`FetchRates`**
1. Emit a loading state
2. Call `repository.getRate(baseCurrencyCode, targetCurrencyCode)`
3. On success: emit loaded state with the new `ExchangeRate`
4. On failure: emit an error state — preserve the last known rate if one exists, so the UI does not go blank

**`SelectBaseCurrency` / `SelectTargetCurrency`**
1. Update the relevant code in state
2. Dispatch `FetchRates` — the rate must refresh automatically on every pair change

**`SetAmount`**
1. Update `amount` in state only
2. No network call — `convertedAmount` is a derived getter, so the UI updates automatically

**`SwapCurrencies`**
1. Swap `baseCurrencyCode` and `targetCurrencyCode` in state
2. Clear `exchangeRate` to avoid displaying a stale result during the refresh
3. Dispatch `FetchRates`

---

## 9. Error Handling

### What can go wrong

| Scenario | Exception type | How to detect |
|---|---|---|
| No internet connection | `SocketException` (`dart:io`) | `on SocketException` catch clause |
| Unknown currency code | `ApiException` (HTTP 404) | `e.statusCode == 404` |
| Malformed query | `ApiException` (HTTP 400) | `e.statusCode == 400` |
| Server error | `ApiException` (HTTP 5xx) | `e.statusCode >= 500` |
| Request timeout | `TimeoutException` | Apply `.timeout(duration)` to the HTTP future |

### The non-negotiable rule

Every failure path in every BLoC event handler must emit a state with `status: RateStatus.error` and a human-readable `errorMessage`. A raw exception message, a stack trace, or a blank screen reaching the user is always a bug — and is graded accordingly.

Catch exceptions in this order: specific types first (`SocketException`, `ApiException`), then a final generic `catch` as a safety net.

---

## 10. Loading States in the UI

Your UI must visibly respond to all four values of `RateStatus`. Use a `BlocBuilder` and switch on `state.status`:

| Status | What the user sees |
|---|---|
| `initial` | A prompt to select currencies and get started |
| `loading` | A `CircularProgressIndicator` — never a frozen UI |
| `error` | The `errorMessage` string + a **Retry** button that re-dispatches `FetchRates` |
| `loaded` | The conversion result and rate label |

The Retry button is required. Do not make a user restart the app to recover from a temporary network failure.

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

## 12. End-to-End Data Flow

This traces the full journey of a user action through every layer of the architecture — from tap to rendered result. No layer is skipped; no layer does more than its job.

---

**App launch**

`main.dart` constructs the dependency chain and provides it to the widget tree:

```
http.Client  →  RemoteDataSourceImpl  →  CurrencyRepositoryImpl  →  CurrencyBloc
```

The BLoC is created and `LoadCurrencies` is dispatched immediately.

---

**Step 1 — Currencies load**

`LoadCurrencies` arrives at the BLoC.
The BLoC emits a loading state, then asks the repository for the currency list.
The repository delegates to the data source.
The data source calls `GET /currencies` and receives a 201-item JSON array.
Each array element is parsed into a `Currency` object via `Currency.fromJson(...)`.
The list travels back up: data source → repository → BLoC.
The BLoC emits a loaded state carrying the list.
The UI renders the currency dropdowns.
The BLoC then immediately dispatches `FetchRates` for the default pair.

---

**Step 2 — User selects a new target currency**

The dropdown widget dispatches `SelectTargetCurrency('NGN')`.
The BLoC updates `targetCurrencyCode` in state, then dispatches `FetchRates`.

---

**Step 3 — Rate is fetched**

`FetchRates` arrives at the BLoC.
The BLoC emits a loading state, then calls `repository.getRate('USD', 'NGN')`.
The data source calls `GET /rate/USD/NGN`.
The API responds:
```json
{ "date": "2026-07-17", "base": "USD", "quote": "NGN", "rate": 1388.28 }
```
The response is parsed into an `ExchangeRate` object.
The BLoC emits a loaded state carrying the new `ExchangeRate`.

---

**Step 4 — User enters an amount**

The amount input dispatches `SetAmount(50.0)`.
The BLoC updates `amount` in state. **No network call is made.**
The `convertedAmount` getter on `CurrencyState` computes `50.0 × 1388.28 = 69,414.00` on demand.
The `ConversionResult` widget rebuilds and displays `69,414.00 NGN`.

---

**Step 5 — A network error occurs**

Suppose the device loses connectivity when `FetchRates` is in flight.
The data source receives a `SocketException`.
The exception travels up to the BLoC's catch block.
The BLoC emits an error state: `status: RateStatus.error`, `errorMessage: 'No internet connection.'`
The UI renders the error message and a Retry button.
The user taps Retry → `FetchRates` is dispatched again → the flow restarts from Step 3.

---

## 13. Tier 2 — History Chart Endpoint

### Fetching the data

Call `repository.getHistory(base, quote, 7)` — your data source implementation computes the `from` and `to` dates and builds the URL automatically. It returns `List<RatePoint>`.

This fetch must be triggered by the BLoC — not directly from a widget. If you add a separate history BLoC or extend `CurrencyBloc`, the loading and error state for historical data must be tracked **independently** of the live rate state. A failed history fetch must not clear the live conversion result.

### Mapping to chart data

`fl_chart`'s `LineChart` expects a list of `FlSpot(x, y)`. Use the list **index** (0–6) as `x` and the rate as `y`. Think about where this mapping belongs — it should not be inside a widget's `build` method.

### X-axis labels

You need to display dates on the X axis. Your mapping function has access to both the index (`x`) and the original `RatePoint` list. Use the index to look up the corresponding `RatePoint.date` in `getTitlesWidget`.

### Weekend behaviour

Weekend entries in the response repeat the last Friday rate. This is accurate data — plot all entries as-is. The flat segment on weekends is expected.

---

## Quick Reference

| What you need | Endpoint | Response shape |
|---|---|---|
| All available currencies | `GET /currencies` | JSON array → `List<Currency>` |
| Live rate for one pair | `GET /rate/{base}/{quote}` | Single object → `ExchangeRate` |
| Live rates for multiple targets | `GET /rates?base=X&quotes=A,B,C` | JSON array → `List<ExchangeRate>` |
| 7-day history for a pair | `GET /rates?base=X&quotes=Y&from=...&to=...` | JSON array → `List<RatePoint>` |

---

*Have a question about something not covered here? Come to your mentor before you are blocked — not after you have spent two hours guessing.*
