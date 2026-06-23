# Submission & Evaluation

## What to Submit

- GitHub repository link — public, or shared with your mentor
- `README.md` — which tier you attempted, which API you used, how to run the project, any known limitations
- A demo recording (screen record) **or** an APK for Android testing
- If you used a free API key, either include it in your README's instructions or provide a `.env.example` and document how to plug in a real key

This repository already includes an `.env.example` template at its root — keep it, and make sure it accurately reflects what your project actually needs.

---

## How It Will Be Reviewed

| Dimension | What we're looking at |
|-----------|----------------------|
| **Does it work?** | Live conversion, swap, error states, edge cases (empty input, API down, invalid amounts) |
| **Is the code sound?** | GitHub code review — BLoC layering, datasource separation, model typing, naming |
| **Can you explain it?** | Verbal walkthrough — explain how a rate fetch flows from API call to screen update |

The verbal walkthrough is not a formality. Be ready to trace the full path: button press → event dispatched → BLoC receives it → repository called → datasource hits the API → response mapped to a typed model → new state emitted → widget rebuilds. If you can't explain that chain in your own project, that's a gap worth closing before submission.

---

## Grade Boundaries

| Grade | Score | What it means |
|-------|-------|----------------|
| **Distinction** | 85 – 100 | All features work, BLoC is clean, layers are correct, code is readable |
| **Merit** | 70 – 84 | Most features work, minor layering or BLoC gaps |
| **Pass** | 50 – 69 | Core features work but architecture is incomplete or inconsistent |
| **Needs Work** | < 50 | Major features missing, app crashes, or architecture is absent — revision required |

---

## Before You Submit

- [ ] Re-read [`06-ground-rules.md`](06-ground-rules.md) — a ground rule violation can cap your grade regardless of feature completeness
- [ ] Run through [`../CHECKLIST.md`](../CHECKLIST.md) in full
- [ ] Confirm your `.env` file is **not** committed (`git status` should never show it)
- [ ] Confirm the app runs from a clean clone — not just on your machine with leftover state
