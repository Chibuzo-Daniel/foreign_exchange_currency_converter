# Getting Started

This document walks you through everything between "I've just been given this repo link" and "I'm writing my first widget."

---

## 1. Fork the Repository

Click **Fork** in the top right of this repository on GitHub. This creates your own copy under your account — you'll do all your work there, not on the original.

## 2. Clone Your Fork

```bash
git clone git@github.com:YOUR-USERNAME/flutter-fx-converter.git
cd flutter-fx-converter
```

If you haven't set up SSH authentication with GitHub yet, use the HTTPS URL instead, or revisit your Week 3 Git setup notes.

## 3. Initialise Your Flutter Project

This repository currently contains only the brief and its documentation — no Flutter project exists yet. You'll create it yourself, inside this same repo, so your forked repository becomes your actual submission.

From the root of the cloned repo:

```bash
flutter create .
```

This generates the standard Flutter project structure (`lib/`, `pubspec.yaml`, `android/`, `ios/`, etc.) in the current directory without overwriting the documentation files already here.

Confirm everything is wired up correctly:

```bash
flutter doctor
flutter run
```

You should see the default Flutter counter app running. Once that's confirmed working, you're ready to start building against the brief.

## 4. Add Your Dependencies

See [`04-recommended-packages.md`](04-recommended-packages.md) for the required packages. Add them to your `pubspec.yaml` and run:

```bash
flutter pub get
```

## 5. Commit Your Setup

Before writing any feature code, make your first commit so your project history starts clean:

```bash
git add .
git commit -m "chore: initialise flutter project and add dependencies"
git push origin main
```

From here, follow the same Git habits from Week 3: branch per feature, atomic commits, clear messages. Your commit history is part of what gets reviewed.

## 6. Start Building

Head to [`01-overview.md`](01-overview.md) to review the core features, then to [`02-tier-1-base.md`](02-tier-1-base.md) for the full technical requirements and recommended folder structure.

When you reach the API integration part of your build, open [`07-frankfurter-api-guide.md`](07-frankfurter-api-guide.md) — it covers every Frankfurter endpoint, the exact JSON shapes you will parse, all model classes, and a complete step-by-step worked example.

Use [`../CHECKLIST.md`](../CHECKLIST.md) to track your progress as you go.
