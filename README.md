# TailorX – Premium Atelier OS

TailorX is a production-ready Flutter application tailored for boutique tailoring houses across Pakistan, India, and emerging markets.  
It marries couture-level aesthetics with pragmatic UX so even first-time smartphone users can manage orders, customers, and measurements with confidence.

---

##  Product Highlights
- **Immersive entry**: Aurora-style splash, cinematic onboarding carousel, and branded Auth shell for login/signup with Riverpod-powered controllers.
- **Enhanced Authentication**: Password visibility toggle with smooth animations on login and signup screens for better UX.
- **Intuitive home dashboard**: Gradient welcome hero, action grid for daily operations, responsive stats, and latest orders wrapped inside a custom glassmorphic UI.
- **Complete business stack**:
  - **Orders module** – list, filters, detail, add flow with measurement auto-linking, receipt generation, and sharing capabilities.
  - **Customers module** – searchable CRM, add/detail views, linked order + measurement history.
  - **Measurements module** – 30+ fields, gender-aware grouping, dedicated detail screen, add/edit flows with validation.
- **Floating Luxury Bottom Nav**: bespoke glass navigation shell with a raised action orb, adaptive labels, and icon-first interactions.
- **Professional UI Feedback**: Custom snackbar service with success (green), error (red), and info (dark) variants featuring icons, rounded corners, and smooth animations.
- **Design System**: bespoke `AppScaffold`, `AppButton`, `AppInputField`, `CustomCard`, `AuroraBackground`, `MeasurementGroupCard`, `CustomerCard`, etc.
- **State & Routing**: Riverpod for deterministic state + GoRouter for clean navigation across splash, auth, dashboard, orders, customers, measurements, and notifications.
- **Responsive by design**: `AppSizes`, `MediaQuery`, and adaptive grids ensure everything from 5" Android phones to large tablets and web canvases look polished.

---

## 🧱 Architecture Overview
```
lib/
├── core
│   ├── theme/          # AppColors, AppTextStyles, AppButtons, AppInputs, AppTheme
│   ├── routes/         # GoRouter config + route constants
│   ├── helpers/        # Validators, responsive utilities
│   └── constants/      # AppSizes spacing scale
├── shared
│   ├── widgets/        # AppScaffold, CustomCard, AuroraBackground, Measurement tiles, etc.
│   └── services/       # SecureStorageService, SnackbarService, ToastService
├── features
│   ├── splash/         # Animated orb intro
│   ├-─ onboarding/     # 3-screen onboarding flow
│   ├── auth/           # Login, signup, forgot password (Riverpod controllers)
│   ├── home/           # Dashboard UI + bottom nav
│   ├── orders/         # models, controllers, screens, widgets (list/add/detail)
│   ├── customers/      # CRM flows (list/add/detail cards)
│   ├── measurements/   # measurement forms, detail view, UI helpers
│   └── notifications/  # updates feed
```

All business logic lives inside feature-specific `controllers/` (StateNotifiers). UI widgets pull data via Riverpod selectors, preserving separation of concerns.

---

## 🧩 Key Modules at a Glance

### 1. Orders
- **OrdersListScreen**: search, quick filters (All / New / In Progress / Completed), card-based list using the `OrderCard` + `OrderStatusBadge`.
- **AddOrderScreen**: customer dropdowns from `customersProvider`, auto-attach measurement, delivery date picker, total/advance validation, toast feedback.
- **OrderDetailScreen**: rich summary with amount breakdown, status toggles (auto-updates Riverpod state), measurement deep-link, edit/delete actions.

### 2. Customers
- **CustomersListScreen**: debounced search, `CustomerCard` entries, add button launching `AddCustomerScreen`.
- **AddCustomerScreen**: minimal form with validation, persists via `customersProvider`.
- **CustomerDetailScreen**: full profile (phone/email/address), linked measurements and order history sections with CTA to measurement details.

### 3. Measurements
- **MeasurementsListScreen**: search, gender badges, edit/delete actions via dialog, `MeasurementTile` showing key metrics.
- **AddMeasurementScreen**: 30+ structured fields grouped by `MeasurementGroupCard`, gender selector, note support, buttons backed by Riverpod.
- **MeasurementDetailScreen**: read-only view of all metrics, grouped cards, edit/delete hooks.

### 4. Global Experiences
- **Splash & Onboarding**: branded experience with animated gradients and story-driven slides.
- **Auth Stack**: glassmorphism-driven login/sign-up with password visibility toggle, smooth icon animations, and 3-step password recovery bottom sheet.
- **Home Dashboard**: card-first UI with `CustomCard`, `MeasurementGroupCard`, `CustomBottomNavBar`, `OrderStatusBadge`, and `CustomFilterChip`.
- **User Feedback**: Professional snackbar notifications using `SnackbarService` with color-coded messages (success/error/info) and smooth animations.

---

## 🧬 Design System & Guidelines
- **Color palette**: `AppColors` (teal primary, aqua secondary, warm neutrals) to mirror luxury atelier brand language.
- **Typography**: `AppTextStyles` ensures consistent type ramp (headline/body/caption) – no direct `TextStyle` usage.
- **Spacing**: `AppSizes` (4/8/12/16/24/32/40) controls all margins/padding.
- **UI primitives**:
  - `AppScaffold` for consistent safe areas, toolbars, and global padding.
  - `CustomCard`, `MeasurementGroupCard`, `OrderCard`, `CustomerCard` for reusable layout patterns.
  - `AppButton` and `AppInputField` for buttons/forms to guarantee accessible sizing and theming.
- **Services**:
  - `SnackbarService`: Unified notification system with `showSuccess()`, `showError()`, and `showInfo()` methods for consistent user feedback.
  - `SecureStorageService`: Secure local storage for user profiles and sensitive data.
  - `ToastService`: Top banner notifications for important messages.
- **Interaction patterns**: Glassmorphism, subtle blurs, elevated surfaces, pronounced shadow tokens, and smooth animations to maintain a premium aesthetic.

---

## 🧪 Tooling & Commands
```bash
# Install dependencies
flutter pub get

# Run the app (device/emulator/web)
flutter run

# Quality checks
flutter analyze
flutter test
```

Requires **Flutter 3.19+** and **Dart 3+**. The project targets Android and Web by default; iOS/macOS/Linux can be added with minimal effort.

---

## 🎨 Recent Improvements
- **Custom Snackbar Service**: Replaced default ScaffoldMessenger with a professional snackbar system featuring:
  - Color-coded variants (green for success, red for errors, dark for info)
  - Icon indicators for each message type
  - Rounded corners, shadows, and smooth animations
  - Consistent styling across the entire app
- **Password Visibility Toggle**: Enhanced login and signup screens with:
  - Smooth animated icon transitions (fade + scale)
  - Visibility/visibility_off icons for better UX
  - State management for password field visibility

## 🤝 Contributing & Extensibility
- Follow the existing `feature / controller / screen / widget` pattern when adding new flows (inventory, invoicing, etc.).
- Extend Riverpod controllers for side effects (API integration, persistence) while keeping UI layers declarative.
- Leverage `AppSizes`/`AppTextStyles` for all new UI to maintain consistency.
- Use `SnackbarService` for all user feedback messages instead of direct ScaffoldMessenger calls.
- Follow the established password visibility pattern when adding new password fields.

TailorX is built as a foundation for high-touch tailoring businesses. Explore, extend, and craft your own premium workflows on top of this solid, opinionated codebase. Happy tailoring! ✂️
