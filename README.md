# SwiftShop - E-Commerce Product Listing App

SwiftShop is a scalable, offline-first Flutter application built using **Clean Architecture**, **BLoC (Cubits)**, and **Hive**. It consumes the DummyJSON API, caches items locally for offline retrieval, supports paginated lists, and provides wishlist toggling, dark/light theme switching, and real-time product search.

---

## 🏛️ Architecture Explanation

The application is structured following **Clean Architecture** principles, maintaining a strict separation of concerns and decoupling business logic from dependencies.

### Project Structure
```
lib/
├── core/
│   ├── constants/       # App constants (base URLs, timeouts, persistence keys)
│   ├── error/           # Abstract failures and exceptions
│   ├── network/         # Network connectivity and API client setups
│   ├── theme/           # App colors, Material 3 themes, and ThemeCubit
│   ├── storage/         # Local DB (Hive) initialization manager
│   └── widgets/         # Shared reusable widgets (product cards, skeletons, banners, error handlers)
│
└── features/
    ├── auth/            # Auth state, AuthCubit, and login workflows
    ├── products/        # Product list, ProductListCubit, details, scroll listeners, and categories
    └── wishlist/        # Offline wishlist, WishlistCubit, and favorited items storage
```

### Layers within Features
1. **Domain Layer**:
   - Contains **Entities** (pure business models) and **Repositories** (abstract contracts).
   - This layer is completely independent of external packages, databases, and APIs.
2. **Data Layer**:
   - Implements repositories defined in the domain layer.
   - Orchestrates between **Remote Data Sources** (Dio HTTP client) and **Local Data Sources** (Hive caching/SharedPreferences storage).
   - Handles data serialization via **Models** (e.g. `ProductModel`).
3. **Presentation Layer**:
   - Contains state managers (**BLoC Cubits**) and views (**UI Screens & Custom Widgets**).
   - Rebuilds components reactively based on state changes.

---

## ⚡ State Management Approach

We use **BLoC** (`flutter_bloc`) for state management and dependency injection:
- **Dependency Injection**: Core modules and repositories (Dio, Connectivity, SharedPreferences, Hive boxes, and repositories) are declared using `MultiRepositoryProvider` inside `main.dart`, making them easily readable and mockable.
- **State Managers (Cubits)**:
  - `ProductListCubit` manages infinite scrolling states, pagination variables, categories, searches, loading flags, and error values.
  - `WishlistCubit` manages the collection of favorited products, updating the UI immediately.
  - `AuthCubit` coordinates the current dummy user session and authentication tokens.
  - `ThemeCubit` handles light/dark theme switching and persists preference settings locally.
- **Computed Getters**: Instead of using computed providers, filter logic (e.g., matching search terms and category choices) is cleanly defined as a getter on the state class (e.g., `state.filteredProducts`). Widgets listen to state updates and automatically receive optimized list changes.

---

## 💾 Offline Caching & Storage Approach

SwiftShop implements an **offline-first** architecture:
- **Products Caching**:
  - Every successful paginated remote HTTP fetch triggers a write to the `products_cache_box` Hive box.
  - If a network failure or connection timeout occurs, the repository automatically reads cached products from Hive.
  - Users can view and search previously loaded pages offline, alongside a friendly yellow warning banner.
- **Wishlist Storage**:
  - Favorited products are stored in a dedicated Hive box using the product's ID as the key.
  - Toggling items writes/deletes raw serialized JSON payloads. This guarantees that favorited items remain accessible and persistent offline.
- **Theme & Auth Session Storage**:
  - `SharedPreferences` caches the dummy JWT auth token and selected theme modes (Light/Dark).

---

## 📦 Key Packages Used

- **State Management**: `flutter_bloc` (v8.1+)
- **Local DB / Storage**: `hive` & `hive_flutter` (v2+)
- **Networking**: `dio` (v5+)
- **Connectivity Status**: `connectivity_plus` (v6+)
- **Skeleton Shimmers**: `shimmer` (v3+)
- **Fonts**: `google_fonts` (Outfit / Inter)

---

## 🚀 Steps to Run the Application

### 1. Prerequisites
- Install **Flutter SDK** (v3.10.0 or higher is recommended)
- Verify installation by running:
  ```bash
  flutter doctor
  ```

### 2. Clone and Setup Project
```bash
git clone <repository-url>
cd e_commerce_product
```

### 3. Get Dependencies
Run the following command to download all pub packages:
```bash
flutter pub get
```

### 4. Run Unit Tests
Run the unit test suite verifying repository caching and timeouts:
```bash
flutter test
```

### 5. Launch Application
Connect a mobile device or launch an emulator, then execute:
```bash
flutter run
```

### 6. Build Release APK
To compile a release APK for Android:
```bash
flutter build apk --release
```
The compiled APK will be outputted to:
`build/app/outputs/flutter-apk/app-release.apk`
