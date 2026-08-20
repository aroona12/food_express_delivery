# 🍔 FoodExpress — Food Delivery & Restaurant Management App

FoodExpress is a production-style Flutter food ordering and restaurant management mobile application built with Flutter, Riverpod, and Firebase.

---

## 📌 Project Status

- **Current Stage:** Day 1 Completed (Project Foundation & UI Design System)
- **Current Milestone:** Technical architecture, design tokens, centralized Material 3 theme, reusable core UI widgets, declarative routing foundation, and home preview screen.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK ^3.11.1) | Cross-platform mobile application |
| **State Management** | Riverpod (`flutter_riverpod: ^2.6.1`) | Reactive, testable state management |
| **Routing** | `go_router: ^14.8.1` | Declarative URL-based routing & deep linking |
| **Design / Typography** | `google_fonts: ^6.2.1` (Poppins) | Consistent, modern typographic scale |
| **UI Design System** | Material 3 (Custom Theme) | Centralized theme, custom colors & reusable widgets |

---

## 🗓️ 10-Day Development Roadmap

- [x] **Day 1: Project Foundation & UI Design System** — *Completed*
- [ ] **Day 2: Customer Authentication (Firebase Auth & Riverpod)** — *Planned*
- [ ] **Day 3: Restaurant Discovery & Firestore Catalog** — *Planned*
- [ ] **Day 4: Search, Filtering & Menu Details** — *Planned*
- [ ] **Day 5: Cart Management & State Persistence** — *Planned*
- [ ] **Day 6: Favorites & User Profile** — *Planned*
- [ ] **Day 7: Delivery Address, Location & Checkout Flow** — *Planned*
- [ ] **Day 8: Orders & Real-Time Order Tracking** — *Planned*
- [ ] **Day 9: Restaurant/Admin Dashboard & Menu Management** — *Planned*
- [ ] **Day 10: Role-Based Access, Push Notifications & Polish** — *Planned*

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/       # AppColors, AppTypography, AppDimensions
│   ├── mock/            # Isolated temporary mock data for UI previews
│   ├── routing/         # AppRouter and navigation configuration
│   ├── theme/           # Centralized Material 3 ThemeData
│   └── widgets/         # AppButton, AppTextField, AppCard, LoadingIndicator, EmptyState, ErrorState
├── features/
│   └── home/            # Home screen and presentation subwidgets
└── main.dart            # Application entry point with ProviderScope
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.x or higher)
* Chrome / Edge (Web) or Android / iOS device/emulator

### Running the App
```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analyzer
flutter analyze

# 3. Run automated tests
flutter test

# 4. Launch the application (e.g. on Chrome)
flutter run -d chrome
```
