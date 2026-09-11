# 🌸 EstheBook — Aesthetic Clinic Finder & Booking App

**EstheBook** is a modern, cross-platform application built with **Flutter**, designed to help users discover premium aesthetic clinics, explore non-surgical treatments, and seamlessly book appointments. This repository contains the frontend implementation (V1) featuring a fully responsive UI, local state management, and a mock booking flow — deployed as **Flutter Web on GitHub Pages**.

## 📱 App Overview

Finding the right aesthetic clinic for treatments like Botox, dermal fillers, laser therapy, and medical facials can be overwhelming. EstheBook centralizes the experience, offering transparent pricing, verified clinic profiles, and a frictionless booking system.

## ✨ Core Features (V1)

- **Smart Discovery** — browse clinics by location, specialty, and rating, with search, filter sheet, and sorting.
- **Clinic Profiles** — gallery-style hero, practitioner bios, amenities, and opening hours.
- **Treatment Menu** — downtime, benefits, duration, and transparent pricing for every treatment.
- **Seamless Booking** — treatment → time slot → confirm in 3 taps, with an animated stepper.
- **User Dashboard** — upcoming appointments, booking history, and cancellation flow.

## 🛠 Tech Stack

- **Framework:** Flutter (Dart) — Flutter Web build
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigation:** `go_router` with a shell route and deep links
- **UI/UX:** Custom design system (soft blush, sage, cream, gold; Playfair Display + Inter)
- **Architecture:** Feature-first structure under `lib/src/features/<feature>/presentation`
- **Mock Data:** Bundled JSON (`assets/data/*.json`) loaded via an in-memory repository — ready for Firebase/Supabase in V2

## 🚀 Run Locally

```bash
flutter pub get
flutter run -d chrome          # run in debug
# or build for release:
flutter build web --release
```

> Fonts note: this project expects `PlayfairDisplay` and `Inter` TTFs under `assets/fonts/`. Either drop the font files in, or remove the `fonts:` block from `pubspec.yaml` (the UI falls back to system serif/sans). Assets are optional-safe: the app builds even without the font files as long as the block is removed.

## 🌍 Deploy to GitHub Pages (automated)

A GitHub Actions workflow (`.github/workflows/deploy.yml`) builds the web app and publishes it to GitHub Pages on every push to `main`.

1. Push this repository to GitHub (branch: `main`).
2. In the repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. Every push to `main` runs: analyze → test → `flutter build web --release --base-href /<repo-name>/` → deploy.

The live site will be at `https://<username>.github.io/<repo-name>/`.

### Workflow details

- `--base-href /<repo-name>/` — required so assets resolve under the project subpath.
- `404.html` is copied from `index.html` so deep links like `/discover/clinic/c1` resolve on refresh.
- `.nojekyll` prevents GitHub Pages from ignoring files starting with `_` (e.g. `assets/`).
- Analyzer + widget tests run before every deploy.

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry
└── src/
    ├── core/
    │   ├── data/                      # Mock repository + Riverpod providers
    │   ├── domain/                    # Clinic, Treatment, Appointment models
    │   ├── presentation/              # Router, shared widgets
    │   ├── theme/                     # Design tokens & ThemeData
    │   └── utils/                     # Formatters
    └── features/
        ├── shell/                     # Adaptive nav shell (bar/rail)
        ├── onboarding/                # Welcome screen
        ├── discovery/                 # Search, filters, clinic cards
        ├── clinics/                   # Clinic profile
        ├── booking/                   # 3-step flow + success
        └── bookings_dashboard/        # Upcoming & history
```

## 🎨 Design System

- **Style:** Minimalist, luxurious, clean.
- **Palette:** Soft Blush `#F7E8EA`, Sage `#A8BCA1`, Cream `#FDFBF7`, Gold `#C9A96A`.
- **Typography:** Playfair Display for headings, Inter for body.
- **Elements:** generous whitespace, 12–16px radii, soft shadows, gradient image placeholders.

## 🔭 V2 Roadmap

- Real auth (Firebase/Supabase), persisted bookings, rescheduling, real payments intent, reviews.

---
