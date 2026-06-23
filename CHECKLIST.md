# Project Checklist

Tick these off as you go. This mirrors the grading rubrics in [`docs/02-tier-1-base.md`](docs/02-tier-1-base.md) and [`docs/03-tier-2-intermediate.md`](docs/03-tier-2-intermediate.md) — use it as a running progress tracker, not just a pre-submission review.

---

## Setup

- [ ] Forked the brief repository
- [ ] Cloned my fork locally
- [ ] Confirmed project files do not contain hardcoded credentials
- [ ] Ran `flutter create .` to initialise the project inside this repo
- [ ] Added required dependencies to `pubspec.yaml` and ran `flutter pub get`
- [ ] Made my first commit

---

## Core Features (Required at Every Tier)

- [ ] Select a base currency and a target currency from a dropdown or searchable list
- [ ] Enter an amount and see the converted result update in real time
- [ ] Swap the base and target currencies with a single action
- [ ] Display the current exchange rate between the two selected currencies
- [ ] Show the date/time of the last rate refresh
- [ ] Handle loading and error states gracefully — no blank screens, no unhandled exceptions

---

## Tier 1 — Base Architecture

**State Management**
- [ ] `flutter_bloc` used for all conversion state
- [ ] `CurrencyBloc` handles: `LoadCurrencies`, `SelectBaseCurrency`, `SelectTargetCurrency`, `SetAmount`, `SwapCurrencies`, `FetchRates`
- [ ] `CurrencyState` exposes: base currency, target currency, amount, converted result, exchange rate, loading status, error message
- [ ] No `setState` used for any API or conversion logic

**API Integration**
- [ ] Live exchange rates fetched from a real API
- [ ] HTTP calls made via Dio or `http` — never directly from a widget
- [ ] All API calls go through a dedicated datasource class
- [ ] HTTP errors (network failure, 4xx, 5xx) are caught and surfaced to the UI

**Data & Models**
- [ ] `Currency` model defined (`code`, `name`, optional `flag`)
- [ ] `ExchangeRate` model defined (`base`, `rates`, `lastUpdated`)
- [ ] No raw `Map`s passed between layers — typed models used throughout

**Widget Structure**
- [ ] `CurrencyDropdown` widget built (searchable preferred)
- [ ] `AmountInput` widget built
- [ ] `ConversionResult` widget built
- [ ] `RateInfo` widget built
- [ ] No business logic or API calls inside any widget `build` method

**Folder Structure**
- [ ] `lib/models/`
- [ ] `lib/data/datasources/`
- [ ] `lib/data/repositories/`
- [ ] `lib/bloc/`
- [ ] `lib/widgets/`
- [ ] `lib/screens/`

**Code Quality**
- [ ] Repository pattern in place between datasource and BLoC (abstract + impl)
- [ ] Naming is clear and consistent
- [ ] No magic values — meaningful constants/names used
- [ ] Inline comments explain non-obvious logic

---

## Tier 2 — Intermediate (Optional, +50 points)

**Rate History Chart**
- [ ] Line chart built with `fl_chart` showing 7-day rate history for the selected pair
- [ ] Chart updates when the currency pair changes
- [ ] Axis labels show dates and rate values
- [ ] README documents whether real historical data or mocked data was used

**Multi-Currency Comparison**
- [ ] At least 5 target currencies shown converted from the base amount
- [ ] List updates reactively when base currency or amount changes
- [ ] Each row shows flag/code, currency name, and converted amount

**Favourites**
- [ ] User can mark a currency pair as a favourite
- [ ] Favourites persisted with `shared_preferences` or `Hive`
- [ ] Favourites survive an app restart
- [ ] Tapping a saved favourite loads that pair into the converter
- [ ] User can remove a favourite

**Caching**
- [ ] Last fetched rates cached locally
- [ ] App remains usable (with cached data) if the API call fails or there's no connection
- [ ] Stale data warning shown if cached rates are older than 1 hour

**Rate History BLoC**
- [ ] History/chart state managed in BLoC — not in the widget
- [ ] Loading and error states for historical data handled separately from live rate state

---

## Ground Rules — Final Check

- [ ] A live API is used — no hardcoded rates
- [ ] `flutter_bloc` is the only state management approach used (no GetX, Provider, Riverpod, or `setState`-based logic)
- [ ] No external UI kits used — all widgets built from scratch
- [ ] No WebView charts or image-based chart screenshots (Tier 2)
- [ ] I can explain my data flow end-to-end, from button press to screen update
- [ ] No API key committed anywhere in the repository history

---

## Submission

- [ ] GitHub repository link ready to share
- [ ] `README.md` updated with: tier attempted, API used, how to run the project, known limitations
- [ ] Demo recording made, or APK built and tested
- [ ] Confirmed the project runs from a clean clone (not just on my own machine)
