# Food Roulette

A Flutter mobile application that helps users decide where to eat by randomly selecting from their personalized list of food shops. Users organize food shops into meal categories and spin a roulette when they cannot decide.

## Features

- **Category Display** — Five predefined meal categories (Breakfast, Lunch, Tea Time, Dinner, Supper) displayed as color-coded cards with representative icons
- **Food Shop Management** — Add, view, and remove food shops under each category with input validation (1–50 characters, no duplicates)
- **Data Persistence** — Shop lists are saved locally via SharedPreferences and restored on app launch
- **Roulette Random Picker** — Animated spinner that randomly selects a food shop with uniform distribution (requires at least 2 shops)
- **Visual Design** — Warm color palette, rounded card-based layouts, consistent typography, and food-related icons

## Prerequisites

| Software | Minimum Version |
|----------|----------------|
| Flutter SDK | >=2.16.1 <3.0.0 |
| Dart SDK | >=2.16.1 (bundled with Flutter) |
| Android Studio | 4.0+ (for Android builds) |
| Xcode | 13.0+ (for iOS builds, macOS only) |

## Setup and Run

1. Ensure the Flutter SDK is installed and available on your PATH:

   ```bash
   flutter --version
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Code Structure

```
lib/
├── main.dart                       # App entry point and theme configuration
├── models/
│   ├── models.dart                 # Barrel file for model exports
│   ├── meal_category.dart          # MealCategory enum with display properties
│   ├── food_shop.dart              # FoodShop data class with JSON serialization
│   └── result_types.dart           # AddShopResult and RemoveShopResult enums
├── providers/
│   └── category_provider.dart      # State management for categories and shops
├── services/
│   └── storage_service.dart        # SharedPreferences persistence layer
├── screens/
│   ├── home_screen.dart            # Root screen with category grid
│   ├── shop_list_screen.dart       # Shop list view with add/remove/spin actions
│   └── roulette_screen.dart        # Animated roulette spinner screen
└── widgets/
    ├── category_card.dart          # Tappable card for a meal category
    ├── shop_list_item.dart         # Dismissible list tile for a food shop
    ├── add_shop_dialog.dart        # Dialog with validated text input for adding shops
    └── spinner_widget.dart         # Animated wheel visualization
```

## Public Classes

### Models

| Class | Description |
|-------|-------------|
| `MealCategory` | Enum representing the five predefined meal categories with display name, color, and icon properties. |
| `FoodShop` | Immutable data class representing a food shop entry with name and creation timestamp. |
| `AddShopResult` | Enum representing the outcome of adding a shop (success, emptyName, duplicateName, storageFailed). |
| `RemoveShopResult` | Enum representing the outcome of removing a shop (success, storageFailed). |

### Providers

| Class | Description |
|-------|-------------|
| `CategoryProvider` | ChangeNotifier that manages all category/shop state, handles validation, coordinates persistence, and provides random selection. |

### Services

| Class | Description |
|-------|-------------|
| `StorageService` | Handles reading and writing shop lists to SharedPreferences as JSON. |

### Screens

| Class | Description |
|-------|-------------|
| `HomeScreen` | Root screen displaying five category cards in a scrollable grid layout. |
| `ShopListScreen` | Displays the food shops for a selected category with add/remove capabilities and a spin button. |
| `RouletteScreen` | Animated spinner screen that randomly selects a food shop from the category's list. |

### Widgets

| Class | Description |
|-------|-------------|
| `CategoryCard` | A tappable card widget displaying a meal category with its unique color, icon, and name label. |
| `ShopListItem` | A dismissible list tile displaying a food shop name with delete action. |
| `AddShopDialog` | A dialog for adding a new food shop with inline validation for empty names, length limits, and duplicates. |
| `SpinnerWidget` | An animated wheel visualization that rotates during the roulette spin and displays shop name segments. |

## Public Methods

### CategoryProvider

| Method | Parameters | Return Type |
|--------|-----------|-------------|
| `CategoryProvider()` | `{required StorageService storageService}` | `CategoryProvider` |
| `loadData()` | none | `Future<void>` |
| `getShops()` | `MealCategory category` | `List<FoodShop>` |
| `addShop()` | `MealCategory category, String name` | `Future<AddShopResult>` |
| `removeShop()` | `MealCategory category, FoodShop shop` | `Future<RemoveShopResult>` |
| `pickRandom()` | `MealCategory category` | `FoodShop?` |

### StorageService

| Method | Parameters | Return Type |
|--------|-----------|-------------|
| `saveShopLists()` | `Map<MealCategory, List<FoodShop>> data` | `Future<bool>` |
| `loadShopLists()` | none | `Future<Map<MealCategory, List<FoodShop>>?>` |

### FoodShop

| Method | Parameters | Return Type |
|--------|-----------|-------------|
| `FoodShop()` | `{required String name, required DateTime createdAt}` | `FoodShop` |
| `toJson()` | none | `Map<String, dynamic>` |
| `FoodShop.fromJson()` | `Map<String, dynamic> json` | `FoodShop` |

### MealCategory (Extension Properties)

| Property | Type | Description |
|----------|------|-------------|
| `displayName` | `String` | Human-readable name for the category |
| `color` | `Color` | Unique background color for the category card |
| `icon` | `IconData` | Representative icon for the meal type |

### AddShopDialog

| Method | Parameters | Return Type |
|--------|-----------|-------------|
| `AddShopDialog()` | `{required MealCategory category}` | `AddShopDialog` |

### SpinnerWidget

| Method | Parameters | Return Type |
|--------|-----------|-------------|
| `SpinnerWidget()` | `{required Animation<double> animation, required List<FoodShop> shops, FoodShop? selectedShop}` | `SpinnerWidget` |

## Dependencies

- `flutter` — UI framework
- `provider` ^6.0.0 — State management
- `shared_preferences` ^2.0.0 — Local key-value storage
- `cupertino_icons` ^1.0.2 — iOS-style icons

## Dev Dependencies

- `flutter_test` — Widget and unit testing
- `integration_test` — Integration testing
- `glados` ^1.1.1 — Property-based testing
- `flutter_lints` ^1.0.0 — Lint rules
