# Implementation Plan: Food Roulette App

## Overview

This plan implements a Flutter/Dart mobile application with Provider state management, SharedPreferences persistence, and an animated roulette spinner. The implementation follows a bottom-up approach: data models → storage service → provider → UI screens/widgets → animations → tests → documentation. Each step builds incrementally so there is no orphaned code.

## Tasks

- [x] 1. Set up project structure and dependencies
  - [x] 1.1 Initialize Flutter project and configure dependencies
    - Create the Flutter project structure with standard directories (`lib/models/`, `lib/providers/`, `lib/screens/`, `lib/widgets/`, `lib/services/`)
    - Update `pubspec.yaml` with dependencies: `provider`, `shared_preferences`
    - Add dev dependencies: `flutter_test`, `glados`, `integration_test`
    - Configure the analysis options for linting
    - _Requirements: 1.1, 5.1, 5.2_

- [x] 2. Implement data models
  - [x] 2.1 Create MealCategory enum and FoodShop model
    - Create `lib/models/meal_category.dart` with the `MealCategory` enum containing five values (breakfast, lunch, teaTime, dinner, supper), each with `displayName`, `color`, and `icon` properties
    - Create `lib/models/food_shop.dart` with the `FoodShop` class including `name`, `createdAt`, JSON serialization (`toJson`, `fromJson`), and case-insensitive equality
    - Create `lib/models/result_types.dart` with `AddShopResult` and `RemoveShopResult` enums
    - Export all models from `lib/models/models.dart` barrel file
    - _Requirements: 1.2, 2.1, 2.5, 5.1, 5.4_

  - [x] 2.2 Write property test for category color uniqueness
    - **Property 1: Category colors are unique**
    - **Validates: Requirements 1.2, 5.1**

  - [x] 2.3 Write unit tests for FoodShop model
    - Test JSON serialization/deserialization
    - Test case-insensitive equality
    - Test boundary name lengths (1 char, 50 chars)
    - _Requirements: 2.1, 2.5_

- [x] 3. Implement storage service
  - [x] 3.1 Create StorageService class
    - Create `lib/services/storage_service.dart` with `StorageService` class
    - Implement `saveShopLists(Map<MealCategory, List<FoodShop>>)` that serializes data to JSON and writes to SharedPreferences under key `food_roulette_data`
    - Implement `loadShopLists()` that reads from SharedPreferences, parses JSON, and returns the map or null on failure
    - Handle corrupted/unparseable JSON gracefully by returning null
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 3.2 Write property test for storage round-trip
    - **Property 6: Storage round-trip preserves data and order**
    - **Validates: Requirements 3.2**

  - [x] 3.3 Write property test for invalid storage data
    - **Property 7: Invalid storage data yields empty lists**
    - **Validates: Requirements 3.3**

  - [x] 3.4 Write unit tests for StorageService
    - Test saving and loading empty lists
    - Test loading from empty SharedPreferences key returns null
    - Test loading corrupted JSON returns null
    - _Requirements: 3.2, 3.3_

- [x] 4. Checkpoint - Ensure data layer tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement CategoryProvider
  - [x] 5.1 Create CategoryProvider with ChangeNotifier
    - Create `lib/providers/category_provider.dart` with `CategoryProvider` extending `ChangeNotifier`
    - Implement `loadData()` to initialize from StorageService on app start
    - Implement `getShops(MealCategory)` returning the list for a category
    - Implement `addShop(MealCategory, String)` with validation (empty/whitespace check, length 1-50, case-insensitive duplicate check), persistence, and notification
    - Implement `removeShop(MealCategory, FoodShop)` with persistence and notification
    - Implement `pickRandom(MealCategory)` using Dart's `Random` for uniform distribution, returning null if fewer than 2 shops
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.4, 4.1, 4.4, 4.5_

  - [x] 5.2 Write property test for adding valid shops
    - **Property 2: Adding a valid shop grows the list**
    - **Validates: Requirements 2.1**

  - [x] 5.3 Write property test for whitespace rejection
    - **Property 3: Whitespace-only names are rejected**
    - **Validates: Requirements 2.2**

  - [x] 5.4 Write property test for shop removal
    - **Property 4: Removing a shop shrinks the list**
    - **Validates: Requirements 2.3**

  - [x] 5.5 Write property test for case-insensitive duplicates
    - **Property 5: Case-insensitive duplicate rejection**
    - **Validates: Requirements 2.5**

  - [x] 5.6 Write property test for random pick membership
    - **Property 8: Random pick is always a list member**
    - **Validates: Requirements 4.1**

  - [x] 5.7 Write property test for uniform distribution
    - **Property 9: Uniform random distribution**
    - **Validates: Requirements 4.5**

  - [x] 5.8 Write unit tests for CategoryProvider
    - Test addShop with exactly 51 characters fails
    - Test removeShop on the only shop results in empty list
    - Test addShop returns storageFailed on save error
    - Test loadData initializes with empty lists when storage returns null
    - _Requirements: 2.1, 2.2, 2.3, 3.3, 3.4_

- [x] 6. Checkpoint - Ensure provider tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Implement UI screens and widgets
  - [x] 7.1 Create CategoryCard widget
    - Create `lib/widgets/category_card.dart` with a tappable card widget
    - Display category name label, food-related icon, and unique background color
    - Use rounded corners and card-based layout per visual design requirements
    - _Requirements: 1.2, 5.1, 5.3, 5.4_

  - [x] 7.2 Create HomeScreen
    - Create `lib/screens/home_screen.dart` with a Scaffold containing app bar titled "Food Roulette"
    - Display five CategoryCard widgets in a scrollable grid layout
    - On card tap, navigate to ShopListScreen passing the selected category
    - Wire up with Provider using `Consumer<CategoryProvider>`
    - _Requirements: 1.1, 1.3, 5.2, 5.3_

  - [x] 7.3 Create ShopListItem widget
    - Create `lib/widgets/shop_list_item.dart` with a dismissible list tile
    - Display shop name with delete action (swipe to dismiss or delete icon)
    - Use rounded corners and consistent styling
    - _Requirements: 2.3, 2.4, 5.3_

  - [x] 7.4 Create AddShopDialog widget
    - Create `lib/widgets/add_shop_dialog.dart` with a StatefulWidget dialog
    - Include a TextField with TextEditingController for shop name input
    - Implement inline validation: empty/whitespace, length > 50, case-insensitive duplicate
    - On valid submit, call `CategoryProvider.addShop()` and close dialog
    - _Requirements: 2.1, 2.2, 2.5_

  - [x] 7.5 Create ShopListScreen
    - Create `lib/screens/shop_list_screen.dart` accepting a MealCategory parameter
    - Display the category's shops in insertion order using ShopListItem widgets
    - Include a FAB or button to open AddShopDialog
    - Include a "Spin" button that navigates to RouletteScreen (disabled if fewer than 2 shops with informational message)
    - Handle remove actions via ShopListItem callbacks
    - Show SnackBar messages for storage failures
    - _Requirements: 2.1, 2.3, 2.4, 3.4, 4.4_

  - [x] 7.6 Create SpinnerWidget and RouletteScreen
    - Create `lib/widgets/spinner_widget.dart` with animated wheel visualization using the provided Animation<double>
    - Create `lib/screens/roulette_screen.dart` as a StatefulWidget with SingleTickerProviderStateMixin
    - Implement AnimationController with duration between 2-5 seconds
    - Implement `_startSpin()` to trigger animation and call `pickRandom` on completion
    - Display selected shop name prominently after animation completes
    - Include a "Spin Again" button visible after result display
    - Disable spin button during animation
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6_

  - [x] 7.7 Wire up app entry point with Provider
    - Create/update `lib/main.dart` with `ChangeNotifierProvider` wrapping the MaterialApp
    - Initialize `CategoryProvider` with `StorageService` and call `loadData()` on startup
    - Apply consistent theme: single font family, warm color palette, rounded corners
    - Set HomeScreen as the initial route
    - _Requirements: 1.1, 3.2, 5.1, 5.2, 5.3_

- [x] 8. Checkpoint - Ensure app builds and runs
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Write widget tests
  - [x] 9.1 Write widget tests for HomeScreen and CategoryCard
    - Test HomeScreen renders exactly 5 category cards
    - Test tapping a category card navigates to ShopListScreen
    - Test each card displays correct label and icon
    - _Requirements: 1.1, 1.2, 1.3, 5.4_

  - [x] 9.2 Write widget tests for ShopListScreen and AddShopDialog
    - Test ShopListScreen displays shops in insertion order
    - Test AddShopDialog shows validation errors for empty input
    - Test AddShopDialog shows duplicate error for existing names
    - Test minimum-shops message shown when category has fewer than 2 shops
    - _Requirements: 2.1, 2.2, 2.4, 2.5, 4.4_

  - [x] 9.3 Write widget tests for RouletteScreen
    - Test RouletteScreen shows result after animation completes
    - Test spin-again button is available after result display
    - Test spin button is disabled during animation
    - _Requirements: 4.2, 4.3, 4.6_

- [x] 10. Write integration tests
  - [x] 10.1 Write integration test for full add/persist/reload flow
    - Launch app → tap category → add shop → verify persistence → simulate relaunch → verify loaded
    - _Requirements: 2.1, 3.1, 3.2_

  - [x] 10.2 Write integration test for roulette flow
    - Add multiple shops → spin roulette → verify result is from the list
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 11. Create README documentation
  - [x] 11.1 Write comprehensive README.md
    - Create `README.md` at the project root
    - Include project overview section describing the app's purpose and features (Req 1-5)
    - Include code structure section with directory tree showing at least one level of subdirectories
    - Document all public classes (screens, providers, models, services) with one-sentence descriptions
    - Document all public methods with name, parameters with types, and return type
    - Include setup and run instructions: required Flutter SDK version, `flutter pub get`, `flutter run`
    - Include prerequisites section listing Flutter SDK, Dart SDK, Android Studio/Xcode minimum versions
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

- [x] 12. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document using the `glados` package
- Unit tests validate specific examples and edge cases
- Widget tests validate UI rendering and interaction
- The app uses Provider for state management — all screens access state via `context.read`/`context.watch`
- SharedPreferences stores a single JSON string keyed by `food_roulette_data`

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "3.1"] },
    { "id": 3, "tasks": ["3.2", "3.3", "3.4"] },
    { "id": 4, "tasks": ["5.1"] },
    { "id": 5, "tasks": ["5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8"] },
    { "id": 6, "tasks": ["7.1", "7.3", "7.4"] },
    { "id": 7, "tasks": ["7.2", "7.5", "7.6"] },
    { "id": 8, "tasks": ["7.7"] },
    { "id": 9, "tasks": ["9.1", "9.2", "9.3", "10.1", "10.2"] },
    { "id": 10, "tasks": ["11.1"] }
  ]
}
```
