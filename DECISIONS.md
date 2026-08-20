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
