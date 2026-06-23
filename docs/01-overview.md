# Project Overview

You've already built this once in JavaScript. You handled the API calls, the conversion logic, the UI updates. Now the question is: can you build the same thing in Flutter — with proper architecture, clean state management, and code that holds up to a review?

This is a real-world class of app. Currency converters are a category that exists in every app store, and they require you to think carefully about API integration, async state, caching, error handling, and UX responsiveness. All of that is in scope here.

---

## Quick Reference

| | |
|---|---|
| **Reference Challenge** | Foreign Exchange Currency Converter — Frontend Mentor |
| **Original Stack** | HTML, CSS, JavaScript |
| **Target Stack** | Flutter (Dart) — BLoC, Clean Architecture, HTTP/Dio, fl_chart |
| **Live API Required** | Yes — Frankfurter (no API key required) |
| **Platform Target** | Mobile (Android/iOS) — responsive layout is a bonus |
| **Submission** | GitHub repository with APK or demo recording |

---

## Core Features

These features must **all** be present to count as a complete submission, at either tier:

- [ ] Select a base (from) currency and a target (to) currency from a dropdown or searchable list
- [ ] Enter an amount and see the converted result update in real time
- [ ] Swap the base and target currencies with a single action
- [ ] Display the current exchange rate between the two selected currencies (e.g. `1 USD = 0.92 EUR`)
- [ ] Show the date/time of the last rate refresh
- [ ] Handle loading and error states gracefully — no blank screens or unhandled exceptions

These six features are the foundation. Everything in [Tier 1](02-tier-1-base.md) is about building them properly — with the right architecture, not just making them appear to work.

---

## Next Steps

- Haven't set up your project yet? Go to [`00-getting-started.md`](00-getting-started.md)
- Ready to see the full technical requirements? Go to [`02-tier-1-base.md`](02-tier-1-base.md)
