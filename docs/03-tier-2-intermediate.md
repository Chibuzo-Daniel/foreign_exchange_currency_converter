# Tier 2 — Intermediate

## Goal

Extend the base converter with a rate history chart, multi-currency comparison, and a favourites system backed by local persistence. These are the exact features that separate a demo app from something a user might actually keep on their phone.

**All Tier 1 requirements still apply and are still graded.** See [`02-tier-1-base.md`](02-tier-1-base.md) — this document only covers what's *added* on top. Intermediate adds a further **50 points** on top of your Base score.

---

## Additional Feature 1 — Rate History Chart

- Display a line chart showing the exchange rate between the selected currency pair over the past 7 days
- Use the **fl_chart** package for the chart — no WebView-based chart solutions
- Chart must update when the currency pair changes
- Fetch historical rates from the API (ExchangeRate-API supports 7-day history on the free tier) or fall back to mocked data if the API doesn't support it — **clearly note which approach you used in your README**
- Show axis labels with dates and rate values

## Additional Feature 2 — Multi-Currency Comparison

- From the main converter screen, allow the user to see the base amount converted to multiple target currencies at once — at minimum **5 currencies** shown in a list
- List must update reactively when the base currency or amount changes
- Each row in the list shows: currency flag/code, currency name, converted amount

## Additional Feature 3 — Favourites

- User can mark a currency pair as a favourite (e.g. `USD → NGN`)
- Favourites are persisted locally using **shared_preferences** or **Hive** — they survive app restarts
- A favourites screen or section shows saved pairs; tapping one loads that pair into the converter
- User can remove a pair from favourites

---

## Additional Technical Requirements

### Caching

- Cache the last fetched rates locally so the app works offline or handles API failures gracefully
- Show a stale data warning if the cached rates are older than 1 hour

### Rate History BLoC (or extension of `CurrencyBloc`)

- If implementing the chart, history fetch state must be managed in BLoC — not directly in the widget
- Handle loading and error states for historical data **separately** from live rate state

---

## Intermediate Tier — Grading Rubric

| Criteria | Points | Notes |
|----------|--------|-------|
| Rate history chart (fl_chart) updates with currency pair | 15 | Axis labels required |
| Multi-currency comparison list (5+ currencies, reactive) | 10 | Updates on input change |
| Favourites: save, list, restore, remove — persisted locally | 12 | Survives app restart |
| Rate caching with stale data warning | 8 | 1-hour threshold |
| History/comparison BLoC state managed correctly | 5 | Not in widget `build` |
| **INTERMEDIATE BONUS TOTAL** | **+50** | **Added to Base score** |

---

## Next Steps

- Check required packages for this tier: [`04-recommended-packages.md`](04-recommended-packages.md)
- Ready to submit? Go to [`05-submission-and-grading.md`](05-submission-and-grading.md)
