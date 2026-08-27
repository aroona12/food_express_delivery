# 🍔 FoodExpress — Food Delivery & Restaurant Management App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Riverpod](https://img.shields.io/badge/Riverpod-00599C?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev/)
[![Tests](https://img.shields.io/badge/Tests-215%20Passed-success?style=for-the-badge)](https://github.com/)
[![Analyzer](https://img.shields.io/badge/flutter%20analyze-0%20Issues-brightgreen?style=for-the-badge)](https://github.com/)

**FoodExpress** is a production-grade, full-featured food ordering and restaurant management mobile application built with **Flutter**, **Riverpod**, and **Firebase**. It demonstrates enterprise-level mobile architecture, feature-first Clean Architecture, reactive state management, Cloud Firestore persistence, real-time order tracking via document streams, and comprehensive test-driven development with 100% test pass rate.

---

## 📸 Overview & Key Highlights

* **Architecture**: Feature-First Clean Architecture with strictly decoupled domain entities, repository interfaces, and presentation layers.
* **State Management**: Reactive, testable state management using Riverpod (`StateNotifier`, `StreamProvider`, `FutureProvider`, family providers, and provider overrides for zero-dependency widget tests).
* **Cloud Database**: Cloud Firestore integration for user profiles (`users/{userId}`) and customer orders (`orders/{orderId}`).
* **Real-Time Tracking**: Live order status tracking powered by Firestore document snapshot streams (`.snapshots()`) with **zero polling timers**.
* **Declarative Routing**: Dynamic routing via GoRouter with real-time authentication guard redirects and deep-linking support.
* **UI & Design System**: Material 3 theming with custom brand color palettes, Google Fonts (Poppins), custom reusable components, and smooth micro-animations.
* **Test Coverage**: **215 automated unit, widget, and navigation tests** passing across all feature modules with **0 analyzer issues**.

---

## 🚀 Implemented Features (Days 1–8)

### 1. 🔐 Customer Authentication & Route Guards
* **Firebase Authentication**: Email and password registration, login, logout, and password recovery.
* **Session Persistence**: Automatic session restoration via `authStateChanges` stream.
* **Declarative Auth Guards**: GoRouter redirects unauthenticated users away from protected routes (`/profile`, `/cart`, `/checkout`, `/orders`, `/favorites`) directly to `/login`.
* **Form Validation**: Real-time email formatting, password strength checks, and descriptive error banners.

### 2. 👤 Customer Profile & Cloud Firestore
* **Profile Synchronization**: Automatic document creation and retrieval in Cloud Firestore (`users/{userId}`).
* **Edit Profile**: Modal bottom sheet for updating full name, phone number, and delivery address.
* **Fallback Safety**: Graceful fallback to Firebase Auth metadata during network latency or offline startup.

### 3. 🍽️ Restaurant Discovery & Menu Browsing
* **Explore Restaurants**: Rich restaurant cards displaying ratings, review counts, cuisines, delivery estimates, fees, and open/closed badges.
* **Category Filtering**: Horizontal category filter pills (Burgers, Pizza, Asian, Desserts, Beverages, Healthy).
* **Live Search**: Instant keyword search filtering restaurants by name, cuisine, and menu offerings.
* **Restaurant Details & Menu**: Hero banner images, categorized menu sections, dish descriptions, pricing, and availability tags.

### 4. 🛒 Cart Management & Quantity Controls
* **In-Memory Cart**: Fast shopping cart with single-restaurant enforcement (prompts user before switching restaurants).
* **Quantity Controls**: Add dishes, increment/decrement quantities, or remove items directly with real-time subtotal computation.
* **Reactive Badges**: Live cart badge on the home navigation bar showing active item count.

### 5. ❤️ Customer Favorites
* **Optimistic Bookmarking**: Instant UI toggle for saving and removing favorite restaurants.
* **Dedicated Favorites Screen**: Accessible from the customer profile with empty state illustrations and quick restaurant access.

### 6. 📍 Delivery Address Management
* **Address Book**: Full CRUD operations for customer delivery addresses (Home, Work, Other) with default address toggling.
* **Interactive Selection**: Dedicated selection mode allowing customers to pick or switch delivery addresses seamlessly during checkout.

### 7. 💳 Customer Checkout Flow
* **Comprehensive Review Screen**: Displays selected delivery address, fulfilling restaurant, itemized dish list, optional delivery notes, and bill summary (subtotal, delivery fee, grand total).
* **Payment Preview**: Pre-configured for Cash on Delivery (payment gateway integration planned for upcoming milestones).
* **Atomic Order Placement**: Persists order payload to Cloud Firestore and clears the shopping cart **only after** write confirmation succeeds. If network fails, cart dishes are preserved.

### 8. 📦 Persistent Orders & Real-Time Order Tracking
* **Cloud Firestore Orders**: Placed orders are stored under `orders/{orderId}` with server timestamps (`FieldValue.serverTimestamp()`) and user-scoped data.
* **Order Confirmation Screen (`/order-success/:orderId`)**: Displays confirmation celebration, generated Order ID badge (`#ORD-xxxxx`), restaurant details, total amount, and quick navigation CTAs.
* **Live Order Tracking Screen (`/orders/:orderId`)**: Subscribes directly to Firestore document snapshots via `watchOrderByIdProvider` to stream status updates in real-time without manual page refreshing.
* **Multi-Stage Visual Timeline**: Animated 5-step status progression (`pending` → `confirmed` → `preparing` → `outForDelivery` → `delivered`) with glowing active indicators, completed checkmarks, and dedicated cancellation cards.
* **Order History (`/orders`)**: Chronological past orders list displaying fulfilling restaurant, total amount, formatted date, and one-tap access to live tracking.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK ^3.11.1) | Cross-platform mobile client application |
| **Authentication** | Firebase Auth (`firebase_auth: ^6.5.7`) | Secure user registration, authentication, and session handling |
| **Cloud Database** | Cloud Firestore (`cloud_firestore: ^6.8.0`) | User profiles, persistent orders, and real-time snapshot listeners |
| **Firebase Core** | `firebase_core: ^4.13.0` | Firebase project runtime initialization |
| **State Management** | Riverpod (`flutter_riverpod: ^2.6.1`) | Reactive state management, dependency injection, and family providers |
| **Routing** | GoRouter (`go_router: ^14.8.1`) | Declarative navigation, route guards, and path parameter extraction |
| **Typography** | Google Fonts (`google_fonts: ^6.2.1`) | Poppins typographic scale |
| **Design System** | Material 3 (Custom AppTheme) | Consistent color tokens, typography, button styles, and cards |
| **Linting** | `flutter_lints: ^6.0.0` | Static analysis and best practice enforcement |
| **Testing** | `flutter_test` (Flutter SDK) | Unit, widget, provider, and navigation integration testing |

> [!NOTE]
> All networking and database operations utilize official, type-safe FlutterFire client SDKs. The third-party `http` package is **not used** in this project.

---

## 🏛️ Architecture & Project Structure

The project follows a **Feature-First Clean Architecture** pattern. Each domain feature encapsulates its own data sources, domain models, presentation screens/widgets, and Riverpod providers.

```
lib/
├── core/
│   ├── constants/            # AppColors, AppTypography, AppDimensions
│   ├── mock/                 # Isolated mock data for offline previews & tests
│   ├── routing/              # AppRouter with reactive authentication guards
│   ├── theme/                # Centralized Material 3 ThemeData
│   └── widgets/              # Reusable UI components (AppButton, AppTextField, AppCard, etc.)
├── features/
│   ├── address/              # Delivery address management (CRUD & selection)
│   │   ├── data/             # AddressRepository & MockAddressRepository
│   │   ├── models/           # AddressModel domain entity
│   │   ├── presentation/     # AddressListScreen, AddEditAddressScreen & widgets
│   │   └── providers/        # AddressListNotifier & selectedAddressProvider
│   ├── auth/                 # Customer Authentication
│   │   ├── data/             # AuthRepository & FirebaseAuthRepository
│   │   ├── models/           # UserModel & UserRole domain entities
│   │   ├── presentation/     # LoginScreen, RegisterScreen, ForgotPasswordScreen
│   │   └── providers/        # AuthController & currentUserProvider
│   ├── cart/                 # Shopping Cart & Quantity Controls
│   │   ├── models/           # CartModel & CartItemModel domain entities
│   │   ├── presentation/     # CartScreen & widgets
│   │   └── providers/        # CartController & cartProvider
│   ├── checkout/             # Customer Checkout & Confirmation
│   │   ├── models/           # CheckoutModel domain entity
│   │   ├── presentation/     # CheckoutScreen, OrderSuccessScreen & widgets
│   │   └── providers/        # CheckoutController & checkoutProvider
│   ├── favorites/            # Customer Restaurant Favorites
│   │   ├── data/             # FavoriteRepository & MockFavoriteRepository
│   │   ├── models/           # FavoriteModel domain entity
│   │   ├── presentation/     # FavoritesScreen & widgets
│   │   └── providers/        # FavoriteController & favoriteRestaurantsProvider
│   ├── home/                 # Discovery & Navigation
│   │   └── presentation/     # HomeScreen, HomeAppBar, HomeSearchBar, CategoryList
│   ├── order/                # Order Placement & Real-Time Tracking
│   │   ├── data/             # OrderRepository, FirestoreOrderRepository, MockOrderRepository
│   │   ├── models/           # OrderModel, OrderItemModel, OrderStatus enum
│   │   ├── presentation/     # OrderTrackingScreen, OrderHistoryScreen, OrderTrackingTimeline
│   │   └── providers/        # watchOrderByIdProvider, orderHistoryStreamProvider
│   ├── profile/              # Customer Profile Management
│   │   ├── data/             # UserRepository & FirestoreUserRepository
│   │   ├── presentation/     # ProfileScreen & EditProfileSheet
│   │   └── providers/        # UserController & userProfileProvider
│   └── restaurant/           # Restaurant Discovery & Menu Browsing
│       ├── data/             # RestaurantRepository & MockRestaurantRepository
│       ├── models/           # RestaurantModel & FoodItemModel
│       ├── presentation/     # RestaurantDetailsScreen, FoodItemCard, Header
│       └── providers/        # restaurantByIdProvider, foodItemsByRestaurantProvider
├── firebase_options.dart     # FlutterFire generated platform configurations
└── main.dart                 # Application entry point with Firebase & ProviderScope
```

---

## 🔒 Security & Firestore Rules

Database security is enforced at the Cloud Firestore rules level with zero-trust, user-scoped access control:

* **Customer Profiles (`users/{userId}`)**: Authenticated customers can only read and write their own profile document (`request.auth.uid == userId`).
* **Customer Orders (`orders/{orderId}`)**:
  * `create`: Allowed only when the authenticated user's UID matches the order's `userId` field (`request.resource.data.userId == request.auth.uid`).
  * `read, update`: Allowed only for the customer who created the order (`resource.data.userId == request.auth.uid`).
  * `delete`: Blocked by default (`false`) to ensure audit trail integrity.
* **Credentials Safety**: Sensitive client configuration files (`google-services.json`, `GoogleService-Info.plist`), keystores (`*.jks`, `*.keystore`), signing properties (`key.properties`), and environment secrets (`.env*`) are strictly excluded via `.gitignore`.

---

## 🧪 Testing & Quality Assurance

The codebase includes an extensive automated test suite covering domain serialization, repository operations, Riverpod state notifiers, widget rendering, and end-to-end navigation flows:

```
test/
├── features/
│   ├── address/              # Address repository, model, and screen widget tests
│   ├── auth/                 # Authentication controller, models, and screen tests
│   ├── cart/                 # Cart controller, model, and navigation tests
│   ├── checkout/             # Checkout controller, review screen, and order success tests
│   ├── favorites/            # Favorite repository, model, and screen tests
│   ├── home/                 # Home screen and discovery widget tests
│   ├── order/                # Order repository, stream providers, tracking timeline, and screen tests
│   ├── profile/              # Profile controller, repository, and screen tests
│   └── restaurant/           # Restaurant repository, menu providers, and card tests
├── helpers/                  # Test fakes (FakeAuthRepository, FakeUserRepository)
└── widget_test.dart          # Root application smoke tests
```

### Running Tests & Analyzer
```bash
# Run static analyzer (0 issues)
flutter analyze

# Run all 215 automated tests (100% passing)
flutter test
```

---

## ⚡ Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.1` or higher)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / Xcode / VS Code
* Chrome / Edge (for Web) or an Android/iOS emulator/device

### Installation & Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/foodexpress.git
   cd foodexpress
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (Optional for Local Development):**
   * If connecting to your own Firebase project, install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
   * Download and place `google-services.json` inside `android/app/` for Android execution.
   * Deploy Firestore security rules:
     ```bash
     firebase deploy --only firestore:rules
     ```

4. **Run Automated Tests:**
   ```bash
   flutter test
   ```

5. **Launch the Application:**
   ```bash
   # Run on Chrome (Web)
   flutter run -d chrome

   # Run on connected Android / iOS device
   flutter run
   ```

---

## 🗺️ 10-Day Development Roadmap

- [x] **Day 1: Foundation & UI Design System** — Centralized theme, color tokens, typography, reusable components.
- [x] **Day 2: Customer Authentication** — Firebase Auth, login/register forms, password reset, session persistence.
- [x] **Day 3: Customer Profile & Cloud Firestore** — Firestore user document syncing, profile edit sheet.
- [x] **Day 4: Restaurant Discovery & Menu Browsing** — Restaurant catalog, category filtering, search, dish detail.
- [x] **Day 5: Cart Management & Quantity Controls** — In-memory cart, quantity controls, single-restaurant validation.
- [x] **Day 6: Favorites & Order History** — Optimistic favorite bookmarks, chronological order history with item breakdown.
- [x] **Day 7: Delivery Address & Checkout Flow** — Delivery address CRUD, selection mode, full checkout review screen.
- [x] **Day 8: Order Placement & Real-Time Order Tracking** — Cloud Firestore order creation, post-success cart clearing, live status tracking via Firestore streams, 5-stage visual progress timeline.
- [ ] **Day 9: Restaurant/Admin Dashboard & Menu Management** — *(Planned)* Restaurant owner portal, order status updates, menu item CRUD.
- [ ] **Day 10: Role-Based Routing, Push Notifications & Production Polish** — *(Planned)* Role-based access control (Customer/Admin/Rider), FCM push notifications, app polishing.

---

## 💼 Portfolio Project Status

This repository is maintained as a clean, production-ready portfolio project demonstrating modern Flutter engineering standards, reactive data flow, test isolation, and real-time cloud database integration.

Developed with ❤️ using Flutter & Firebase.
