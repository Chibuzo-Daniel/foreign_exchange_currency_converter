# Recommended Packages

| Package | Purpose | Notes |
|---------|---------|-------|
| `flutter_bloc` | State management | Required |
| `equatable` | Value equality for BLoC | Required alongside `flutter_bloc` |
| `dio` | HTTP client | Preferred over the `http` package for interceptors |
| `fl_chart` | Rate history chart | Intermediate tier only |
| `shared_preferences` or `hive` | Favourites & cache persistence | Intermediate tier only |
| `intl` | Number & date formatting | Recommended for both tiers |

---

Add the ones you need to your `pubspec.yaml` under `dependencies:`, then run:

```bash
flutter pub get
```

See [`00-getting-started.md`](00-getting-started.md) if you haven't initialised your Flutter project yet.

## Next Steps

- Building Tier 1 only? Head to [`02-tier-1-base.md`](02-tier-1-base.md) for the architecture you'll need these packages for
- Building Tier 2? See [`03-tier-2-intermediate.md`](03-tier-2-intermediate.md) for where `fl_chart` and persistence packages come in
