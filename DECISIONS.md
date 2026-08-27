# 🏛️ FoodExpress — Architecture Decision Log

This document records the architectural and technical decisions made during the development of FoodExpress.

---

## Day 1 Decisions

### Decision 1: Use Feature-First Project Organization
* **Context:** Choosing between layer-first (`/screens`, `/controllers`, `/models`) and feature-first (`/features/auth`, `/features/restaurants`, etc.).
* **Decision:** Adopt a feature-first folder structure supported by a shared `core/` folder.
* **Reason:** Keeping data, application logic, and presentation code grouped by feature makes the codebase easier to navigate, maintain, and scale without creating massive unorganized directories as features expand.

---

### Decision 2: Centralized Material 3 Theme & Design Tokens
* **Context:** Managing colors, typography, margins, and component styling across multiple screens.
* **Decision:** Define design tokens (`AppColors`, `AppTypography`, `AppDimensions`) centrally in `core/constants/` and compose them into `AppTheme.lightTheme`.
* **Reason:** Prevents magic numbers and hardcoded colors across widgets. Changing brand colors or typography later requires editing a single theme file rather than dozens of screen files.

---

### Decision 3: Adopt Material 3 as the Theme Standard
* **Context:** Choosing between Material 2, Material 3, or completely raw custom drawing.
* **Decision:** Enable `useMaterial3: true` with a tailored `ColorScheme`.
* **Reason:** Material 3 provides modern elevation tokens, rounded shapes, refined touch ripple feedback, and accessibility standards out-of-the-box while remaining fully customizable for our custom food-app brand.

---

### Decision 4: Declarative Routing with `go_router`
* **Context:** Choosing navigation between Flutter's imperative `Navigator 1.0` (`Navigator.push`) and declarative `go_router`.
* **Decision:** Integrate `go_router` wrapped in a Riverpod `Provider`.
* **Reason:** `go_router` supports clean path-based routing (`/home`, `/restaurants/:id`), deep linking, and reactive authentication redirects. Introducing it on Day 1 avoids having to rewrite navigation calls later.

---

### Decision 5: Dedicated Reusable Core UI Components
* **Context:** Deciding whether to write raw Flutter widgets on each screen or create encapsulated core widgets.
* **Decision:** Create reusable components for common elements (`AppButton`, `AppTextField`, `AppCard`, `LoadingIndicator`, `EmptyState`, `ErrorState`).
* **Reason:** Enforces visual consistency (radii, padding, loading behavior) across all future screens and keeps screen files declarative and focused on business layout.

---

### Decision 6: Defer Firebase Integration to Later Days
* **Context:** Considering whether to set up Firebase packages, configurations, and mock repositories on Day 1.
* **Decision:** Defer Firebase packages (Auth, Firestore, Storage, FCM) until their dedicated feature days (starting Day 2).
* **Reason:** Prevents dead placeholder code, unused heavy build dependencies, and premature abstractions. Each development day maintains a single, clear objective.

---

### Decision 7: Isolated Development Mock Data
* **Context:** Needing mock data to visually demonstrate the design system on Day 1 before real backends exist.
* **Decision:** Place all visual demonstration data inside `core/mock/mock_data.dart`, clearly labeled as temporary.
* **Reason:** Prevents mixing fake data into future production repositories and makes cleanup effortless.

---

## Day 2 Decisions

### Decision 8: Decouple Domain User (`UserModel`) from Firebase `User`
* **Context:** Choosing whether to use Firebase's `User` directly throughout the app UI or map it to a custom `UserModel`.
* **Decision:** Create an independent `UserModel` and `UserRole` enum.
* **Reason:** Decouples our app domain and UI from third-party vendor SDKs, allows attaching custom role metadata (Customer vs Admin) and future profile attributes, and makes unit and widget testing straightforward without requiring Firebase native binaries.

---

### Decision 9: Repository Pattern for Authentication (`AuthRepository`)
* **Context:** Deciding how the UI and Riverpod controllers interact with Firebase Auth.
* **Decision:** Define an abstract `AuthRepository` contract implemented by `FirebaseAuthRepository`.
* **Reason:** Adheres to Clean Architecture principles. Keeps all Firebase SDK calls isolated in the data layer and enables mock implementations (`FakeAuthRepository`) for fast, isolated automated tests.

---

### Decision 10: Manage Auth UI State with `StateNotifier<AsyncValue<void>>`
* **Context:** Tracking asynchronous login, registration, and reset operations with loading indicators and error banners.
* **Decision:** Use Riverpod `StateNotifierProvider` with `AsyncValue<void>` to represent operation state (idle, loading, error, success).
* **Reason:** Provides a single, predictable state machine for forms, prevents double-submits, and exposes formatted `AuthException` error messages directly to the UI.

---

### Decision 11: Declarative Route Guarding with `GoRouter` & Riverpod
* **Context:** Protecting `/home` and redirecting unauthenticated users to `/login` reactively.
* **Decision:** Connect `authStateChanges` stream to `GoRouter`'s `refreshListenable` via `GoRouterRefreshStream` and implement central `redirect` logic.
* **Reason:** Eliminates manual navigation checks scattered throughout screens. When a user logs in or logs out, `GoRouter` automatically redirects them to the appropriate route without race conditions or redirect loops.

---

## Day 3 Decisions

### Decision 12: Direct UID Document Mapping in Firestore (`users/{firebaseAuthUid}`)
* **Context:** Choosing a document structuring strategy for customer profile storage in Cloud Firestore.
* **Decision:** Store each user document under the `users` root collection keyed directly by their Firebase Auth UID (`users/{uid}`).
* **Reason:** Eliminates query lookups for current user data, ensures direct 1-to-1 security rule mapping (`request.auth.uid == resource.id`), and delivers sub-millisecond document lookups.

---

### Decision 13: Dedicated `UserRepository` Abstraction & Decoupled Presentation
* **Context:** Determining how customer profile read/update operations flow through the app architecture.
* **Decision:** Create an abstract `UserRepository` contract implemented by `FirestoreUserRepository`, exposed via Riverpod's `userRepositoryProvider`.
* **Reason:** Keeps all Firestore APIs strictly isolated in the data layer. Presentation screens and widgets communicate exclusively through Riverpod providers and controllers (`userProfileProvider`, `userControllerProvider`), enabling 100% testable widget tests without native Firebase SDKs.

---

### Decision 14: Granular Profile Mutations with `UserController`
* **Context:** Managing edit profile form state, validation, and async feedback.
* **Decision:** Use a Riverpod `StateNotifier<AsyncValue<void>>` (`UserController`) for mutating profile fields (`name`, `phone`, `address`).
* **Reason:** Provides atomic loading indicators, catches mutation errors cleanly, and keeps the `EditProfileSheet` UI declarative and responsive.

---

## Day 4 Decisions

### Decision 15: Domain Models Decoupled from Storage (`RestaurantModel` & `FoodItemModel`)
* **Context:** Designing the entities for restaurant metadata and catalog food dishes.
* **Decision:** Create clean, framework-independent Dart models with comprehensive serialization (`fromMap`/`toMap`), `copyWith`, value equality, and price formatting utilities.
* **Reason:** Decouples UI widgets and business logic from data storage mechanisms. When Firestore or REST APIs are integrated in subsequent days, the domain and presentation layers remain unchanged.

---

### Decision 16: Repository Pattern and Mock Data Isolation (`RestaurantRepository`)
* **Context:** Providing restaurant discovery and menu browsing data before Firestore collections and backend administration are finalized.
* **Decision:** Define an abstract `RestaurantRepository` contract and implement `MockRestaurantRepository` backed by `RestaurantMockData`. Ensure UI components only access data via Riverpod providers referencing the interface.
* **Reason:** Strict separation of concerns. UI screens have 0% direct coupling to mock lists. Replacing `MockRestaurantRepository` with `FirestoreRestaurantRepository` in future iterations will require changing only the provider implementation.

---

### Decision 17: Family Providers for Restaurant-Specific State (`Provider.family`)
* **Context:** Managing restaurant details, menu categories, selected filters, and dishes parameterized by `restaurantId`.
* **Decision:** Use Riverpod `FutureProvider.family` (`restaurantByIdProvider`, `foodItemsProvider`, `filteredFoodItemsProvider`) and `StateProvider.family` (`selectedMenuCategoryProvider`).
* **Reason:** Riverpod auto-caches and manages independent state instances for each `restaurantId`. Multiple restaurant pages or cached tabs can maintain their own selected categories without global state collision.

---

### Decision 18: Client-Side Menu Filtering and Availability State Handling
* **Context:** Enabling instant category switching (Burgers, Pizza, Healthy, Sides, Drinks, Desserts) and conveying food item availability to customers.
* **Decision:** Combine `selectedMenuCategoryProvider(restaurantId)` with `filteredFoodItemsProvider(restaurantId)` and render distinct visual states (`Sold Out` banner, `Unavailable` chip, dimmed opacity, disabled tap) for out-of-stock items.
* **Reason:** Delivers sub-millisecond filtering performance and clear visual feedback without premature cart logic or unnecessary backend calls.

---

### Decision 19: Protected Dynamic Deep-Link Routing (`/restaurant/:restaurantId`)
* **Context:** Routing from home discovery cards to restaurant menu screens while preserving authentication guards.
* **Decision:** Register `/restaurant/:restaurantId` in `GoRouter` and extract `restaurantId` from `state.pathParameters['restaurantId']!`.
* **Reason:** Enables deep linking, browser back-button support on web, and seamless navigation while keeping unauthenticated users guarded behind the `/login` redirect.

---

## Day 5 Decisions

### Decision 20: Local In-Memory Client-Side State for Cart Management
* **Context:** Choosing a persistence strategy for customer shopping cart state on Day 5.
* **Decision:** Manage cart state entirely in-memory using Riverpod's `StateNotifier<CartModel>`. Intentionally defer Cloud Firestore/database persistence until order placement and checkout flows are implemented in subsequent days.
* **Reason:** Keeps the cart fast, responsive, and decoupled from network latency while eliminating dead placeholder collections before order models and schemas are established.

---

### Decision 21: Centralized Cart Mutations & Immutability (`CartController`)
* **Context:** Determining how cart items, quantity modifications, additions, and removals should be executed.
* **Decision:** Centralize all cart mutation methods (`addToCart`, `increaseQuantity`, `decreaseQuantity`, `removeFromCart`, `clearCart`, `clearAndAddToCart`) within `CartController`. Ensure all operations return immutable updated copies of `CartModel`.
* **Reason:** Prevents mutating shared state across widgets, guarantees predictable state transitions, and enforces invariants (such as quantity always > 0 and removing items when decremented to 0).

---

### Decision 22: Single-Restaurant Cart Isolation with Explicit Conflict Resolution
* **Context:** Handling user selections when dishes from different restaurants are added to the cart.
* **Decision:** Enforce that the cart contains items from only ONE restaurant at a time. When an item from another restaurant is selected, return `AddToCartResult.restaurantMismatch` and display an explicit confirmation dialog (*"Your cart contains items from another restaurant. Clear cart and add this item?"*) before clearing and switching restaurants.
* **Reason:** Protects customers from unintended cart resets while respecting delivery logistics constraints where orders are fulfilled by a single merchant per delivery.

---

### Decision 23: Centralized Pricing Rules & Derived Riverpod Providers
* **Context:** Calculating line subtotals, centralized delivery fees, grand totals, and badge counts across various screens and app bars.
* **Decision:** Encapsulate pricing calculations directly within `CartModel` (`subtotal`, `deliveryFee`, `total`, `totalItemCount`) and expose them through granular derived Riverpod providers (`cartSubtotalProvider`, `cartDeliveryFeeProvider`, `cartTotalProvider`, `cartItemCountProvider`, `isCartEmptyProvider`).
* **Reason:** Eliminates duplicate calculation logic across UI widgets, prevents floating-point rounding discrepancies, and allows widgets to selectively rebuild only when their relevant piece of derived state updates.

---

## Day 6 Decisions

### Decision 24: Customer Favorites Architecture with Optimistic Local Caching
* **Context:** Managing restaurant favorites across restaurant cards, headers, and dedicated screens.
* **Decision:** Implement `FavoriteRepository` abstraction backed by `MockFavoriteRepository` and managed by `favoriteControllerProvider` (`StateNotifier<Set<String>>`).
* **Reason:** Provides instant optimistic UI updates on heart toggle interactions with 0 latency, while maintaining strict separation of data storage from UI components.

---

### Decision 25: Customer Order History & Tracking Models
* **Context:** Representing past food orders, line items, timestamps, status progressions, and delivery addresses.
* **Decision:** Create domain models `OrderModel`, `OrderItemModel`, and `OrderStatus` with `OrderRepository` abstraction and Riverpod family providers (`orderHistoryProvider`, `orderByIdProvider`).
* **Reason:** Establishes the domain foundation for multi-stage tracking (pending, confirmed, preparing, outForDelivery, delivered, cancelled) without premature Firestore schema coupling.

---

## Day 7 Decisions

### Decision 26: Decoupled Delivery Address Entity & Repository Pattern (`AddressModel` & `AddressRepository`)
* **Context:** Managing customer delivery addresses (Home, Work, Other) with default designation and validation.
* **Decision:** Create a clean, immutable `AddressModel` domain entity and abstract `AddressRepository` with `MockAddressRepository`. Expose operations via `AddressListNotifier` (`StateNotifier<AsyncValue<List<AddressModel>>>`).
* **Reason:** Decouples customer address state from storage providers, ensures effortless transition to Cloud Firestore in future days, and enables complete unit and widget test isolation.

---

### Decision 27: Reactive Address Resolution & Selection State (`selectedAddressProvider`)
* **Context:** Resolving which delivery address should apply to current checkout and home delivery bar when explicit selections are made vs default address.
* **Decision:** Expose `selectedAddressIdProvider` (`StateProvider<String?>`) and combine it with `addressListProvider` and `defaultAddressProvider` inside `selectedAddressProvider`.
* **Reason:** Provides a single, reactive source of truth for the active delivery address throughout the app. When a user selects an address during checkout or home screen, all dependent UI updates instantly.

---

### Decision 28: Aggregated Checkout Domain State (`CheckoutModel`)
* **Context:** Assembling shopping cart items, restaurant metadata, selected delivery address, payment method, and optional delivery notes into a unified checkout state machine.
* **Decision:** Create `CheckoutModel` assembled reactively by `checkoutProvider` reading from `cartProvider`, `selectedAddressProvider`, `restaurantByIdProvider`, `checkoutPaymentMethodProvider`, and `checkoutOrderNotesProvider`.
* **Reason:** Keeps `CartModel` focused strictly on dishes and pricing while `CheckoutModel` aggregates all fulfillment prerequisites and enforces checkout validation (`isValid`).

---

### Decision 29: Order Placement Flow & Cart Clearing Lifecycle
* **Context:** Submitting an order from `CheckoutScreen`, providing feedback, clearing the cart, and guiding navigation.
* **Decision:** Implement `CheckoutController.placeOrder()` which validates prerequisites, generates order IDs, clears the shopping cart via `CartController.clearCart()`, and presents an order confirmation dialog with CTAs for Order History (`/orders`) and Home (`/home`).
* **Reason:** Guarantees atomicity and predictable state transition, preventing duplicate submissions while providing delightful user feedback.

---

## Day 8 Decisions

### Decision 30: Cloud Firestore Customer Order Storage (`orders/{orderId}`)
* **Context:** Persisting placed customer orders in Cloud Firestore with support for querying by user, single-order lookups, and real-time live updates.
* **Decision:** Store orders at root collection `orders/{orderId}` with fields for `id`, `userId`, `restaurantId`, `restaurantName`, `items`, `subtotal`, `deliveryFee`, `total`, `status`, `deliveryAddress`, `orderNotes`, `paymentMethod`, and `FieldValue.serverTimestamp()` for `createdAt`.
* **Reason:** Root collection with `userId` indexed attribute allows efficient user-specific queries (`where('userId', isEqualTo: uid)`), straightforward real-time document listeners, and granular Firestore security rules.

---

### Decision 31: Abstract Repository Architecture & Test Isolation (`FirestoreOrderRepository` & `MockOrderRepository`)
* **Context:** Integrating live Cloud Firestore data operations while keeping all UI widgets, providers, and test suites 100% decoupled from native Firebase binaries.
* **Decision:** Define abstract `OrderRepository` contract (`createOrder`, `getOrderById`, `watchOrderById`, `getOrders`, `watchOrders`), implement `FirestoreOrderRepository` for production, and provide an in-memory reactive `MockOrderRepository` with broadcast `StreamController`s for automated testing.
* **Reason:** Strict separation of data layer from presentation layer. Enables sub-second unit and widget testing with 0% native Firebase dependencies while ensuring production code uses production Firestore APIs.

---

### Decision 32: Real-Time Snapshots for Live Order Tracking with Zero Polling
* **Context:** Tracking order progression through multi-stage lifecycle (`pending` → `confirmed` → `preparing` → `outForDelivery` → `delivered` or `cancelled`) on `OrderTrackingScreen`.
* **Decision:** Bind `OrderTrackingScreen` to `watchOrderByIdProvider(orderId)` (`StreamProvider.family`) listening directly to Firestore `.snapshots()` streams.
* **Reason:** Delivers instantaneous, reactive UI updates whenever the restaurant or driver updates order status without battery-draining polling timers or redundant network roundtrips.

---

### Decision 33: Atomic Order Creation and Post-Success Cart Clearing Lifecycle
* **Context:** Managing shopping cart state and error feedback during network failures or Firestore write interruptions during checkout.
* **Decision:** Convert cart items to order payload, execute `orderRepository.createOrder(order)` first, and call `cartController.clearCart()` **only after** Firestore write confirmation succeeds. If creation fails, keep customer cart intact, surface descriptive error feedback, and allow immediate retry.
* **Reason:** Prevents destructive data loss if a network failure occurs during payment or order creation, ensuring the customer never loses their selected cart dishes.

---

### Decision 34: User-Scoped Firestore Security Rules (`firestore.rules`)
* **Context:** Securing customer order documents against unauthorized cross-user reads, malicious tampering, or unauthorized creation.
* **Decision:** Define granular security rules ensuring customer can only create orders where `request.resource.data.userId == request.auth.uid`, and can only read, update, or listen to orders where `resource.data.userId == request.auth.uid`. Preserve existing Day 3 `users/{userId}` rules.
* **Reason:** Guarantees strong zero-trust access control at the database layer; a customer cannot view or modify another customer's order even by guessing document IDs.


