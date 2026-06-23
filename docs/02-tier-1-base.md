# Tier 1 — Base

## Goal

A fully functional currency converter that fetches live exchange rates, converts correctly, handles state with BLoC, and is built with a clear separation of concerns. No UI kits, no `setState` for business logic.

This tier is required for every mentee. See [`01-overview.md`](01-overview.md) for the 6 core features that must work correctly — everything below is about *how* you build them.

---

## Technical Requirements

### State Management

- Use **BLoC** (`flutter_bloc`) for all conversion state
- `CurrencyBloc` must handle these events at minimum:
  - `LoadCurrencies`
  - `SelectBaseCurrency`
  - `SelectTargetCurrency`
  - `SetAmount`
  - `SwapCurrencies`
  - `FetchRates`
- `CurrencyState` must expose: base currency, target currency, amount, converted result, exchange rate, loading status, error message
- **No `setState`** for any logic that involves the API or conversion result

### API Integration

- Fetch live exchange rates from the Frankfurter API (https://frankfurter.dev)
- Use **Dio** or the **http** package for HTTP calls — no direct API calls from widgets
- All API calls must go through a data source class (`RemoteDataSource` or equivalent)
- Handle HTTP errors (network failure, 4xx, 5xx) and surface them cleanly to the UI

### Data & Models

- Define a `Currency` model: `code` (String), `name` (String), `flag` (optional String/emoji)
- Define an `ExchangeRate` model: `base`, `rates` (`Map<String, double>`), `lastUpdated` (DateTime)
- No raw `Map`s passed between layers — use typed models throughout

### Widget Structure

- `CurrencyDropdown` — reusable widget for selecting a currency (searchable preferred)
- `AmountInput` — handles amount text input with formatting
- `ConversionResult` — displays converted amount and rate
- `RateInfo` — shows last updated timestamp and rate label
- No business logic or API calls inside widget `build` methods

### Folder Structure

| Folder | What goes here |
|--------|----------------|
| `lib/models/` | `Currency`, `ExchangeRate` model classes |
| `lib/data/datasources/` | `RemoteDataSource` — raw API calls |
| `lib/data/repositories/` | `CurrencyRepository` (abstract + impl) |
| `lib/bloc/` | `CurrencyBloc`, `CurrencyEvent`, `CurrencyState` |
| `lib/widgets/` | Reusable UI components |
| `lib/screens/` | Full screen pages |

---

## Base Tier — Grading Rubric

| Criteria | Points | Notes |
|----------|--------|-------|
| All 6 core features work correctly | 25 | ~4 pts per feature |
| BLoC used correctly — correct events, states, and wiring | 20 | No `setState` for logic |
| API integration via datasource class (not from widget or BLoC directly) | 15 | Layered properly |
| Repository pattern correctly introduced between datasource and BLoC | 10 | Abstract class + impl |
| Typed models used throughout — no raw Maps between layers | 10 | `Currency` & `ExchangeRate` |
| Loading and error states handled in UI | 10 | No unhandled exceptions |
| Folder structure reflects architecture and is consistent | 5 | See layout above |
| Code is readable — naming, no magic values, inline comments | 5 | Peer-readable standard |
| **TOTAL** | **100** | **Pass mark: 70** |

---

## Next Steps

- Attempting the Intermediate tier too? Go to [`03-tier-2-intermediate.md`](03-tier-2-intermediate.md)
- Building with Tier 1 only? Go to [`05-submission-and-grading.md`](05-submission-and-grading.md) once you're done
- Check required packages: [`04-recommended-packages.md`](04-recommended-packages.md)
