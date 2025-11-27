# TailorX – Premium Atelier OS

TailorX is a modern Flutter experience crafted for boutique ateliers across Pakistan, India, and beyond.  
The app follows a strict clean architecture, a bespoke design system, and provides a luxurious-yet-simple UX that uneducated users can still navigate with ease.

## ✨ Feature Highlights
- **Immersive intro** – Aurora splash, animated onboarding journey, and branded auth shell.
- **Authentication suite** – Login, signup, and a 3-step forgot-password sheet powered by Riverpod controllers.
- **Dashboard built for tailors** – Card-based overview, action hub, stats, and latest orders using premium Glassmorphism components.
- **Custom components** – `AppScaffold`, `AppButton`, `AppInputField`, `CustomCard`, `CustomCircularIndicator`, `AuroraBackground`, and the bespoke floating BottomNav inspired by the reference shot.
- **Riverpod + GoRouter** – Predictable state management and declarative routing throughout.
- **Responsive-ready** – Layouts rely on `MediaQuery`, `AppSizes`, and flexible widgets so Android phones, tablets, and Web screens all feel native.

## 🏗 Architecture Snapshot
```
lib/
  core/
    theme/        → AppColors, AppTextStyles, AppButtons, AppInputs, AppTheme
    routes/       → GoRouter setup + route constants
    helpers/      → Validators, responsive utilities
    constants/    → AppSizes spacing scale
  shared/
    widgets/      → AppScaffold, CustomCard, AuroraBackground, etc.
    services/     → SecureStorageService, ToastService
  features/
    splash/       → controller + screen
    onboarding/   → controller + screen
    auth/         → controllers, screens, forgot password sheet
    home/         → controller, premium home layout, custom bottom nav
    notifications/→ controller + list screen
```

## 🧩 Screens & Flows
- **Splash** – Animated orb, tagline, micro-stat chips.
- **Onboarding** – 3 slides with bold typography, illustrations, and progress CTA.
- **Auth** – Minimal login/signup forms, luxury spacing, glass bottom sheet for recovery.
- **Home** – Welcome gradient card, action grid, responsive stats row, latest orders, and the custom nav bar.
- **Notifications** – Card stack with subtle hover feel and timestamps.

## 🚀 Getting Started
```bash
flutter pub get
flutter run -d chrome   # or android emulator / device
```

### Helpful Scripts
```bash
flutter analyze   # static analysis
flutter test      # widget/unit tests
```

## 🧱 Design System Notes
- **Palette**: `AppColors.primary` (teal), `secondary`, `background`, `surface`, `dark`.
- **Typography**: `AppTextStyles` enforces all text usage (no raw `TextStyle`s).
- **Spacing**: `AppSizes` governs rhythm (8/12/16/24 px scale).
- **Components**: Always use TailorX widgets (`AppButton`, `AppInputField`, `CustomCard`, etc.) to ensure consistency.

## 📦 Requirements Recap
- Flutter 3.19+
- Dart 3+
- Target platforms: Android & Web (desktop layouts supported via responsive helpers).

Enjoy building atop TailorX’s premium foundation! Let us know if you need more flows (orders, customers, measurements) scaffolded in the same style.
