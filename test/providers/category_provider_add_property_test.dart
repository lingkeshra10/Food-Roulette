import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/models/result_types.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for property-based testing of adding valid shops.
extension AddShopGenerators on Any {
  /// Generates a valid shop name: 1-50 non-whitespace-only characters.
  /// We generate alphanumeric strings and ensure they are trimmed and
  /// between 1 and 50 characters.
  Generator<String> get validShopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a random [MealCategory] value.
  Generator<MealCategory> get mealCategory => choose(MealCategory.values);
}

void main() {
  group(
    'Feature: food-roulette-app, Property 2: Adding a valid shop grows the list',
    () {
      /// **Validates: Requirements 2.1**
      ///
      /// For any Category and any valid shop name (1-50 non-whitespace-only
      /// characters, not already present in the category), adding the shop to
      /// the category's list shall result in the list length increasing by
      /// exactly one and the new entry appearing at the end of the list.
      Glados2(
        any.mealCategory,
        any.validShopName,
        ExploreConfig(numRuns: 100),
      ).test(
        'adding a valid shop increases list length by 1 and appends it at end',
        (MealCategory category, String shopName) async {
          // Set up SharedPreferences mock with empty state
          SharedPreferences.setMockInitialValues({});

          final storageService = StorageService();
          final provider = CategoryProvider(storageService: storageService);
          await provider.loadData();

          // Get the initial list length
          final initialShops = provider.getShops(category);
          final initialLength = initialShops.length;

          // Ensure name is valid (trimmed, 1-50 chars, not whitespace-only)
          final trimmedName = shopName.trim();
          // Guard: skip if the generated name is somehow invalid after trimming
          if (trimmedName.isEmpty || trimmedName.length > 50) return;

          // Add the shop
          final result = await provider.addShop(category, shopName);

          // Verify the result is success (name is unique since list starts empty)
          expect(
            result,
            equals(AddShopResult.success),
            reason: 'Adding a valid, non-duplicate shop name should succeed',
          );

          // Verify list length increased by exactly 1
          final updatedShops = provider.getShops(category);
          expect(
            updatedShops.length,
            equals(initialLength + 1),
            reason:
                'List length should increase by exactly 1 after adding a valid shop',
          );

          // Verify the new entry appears at the end of the list
          expect(
            updatedShops.last.name,
            equals(trimmedName),
            reason:
                'The newly added shop should appear at the end of the list with trimmed name',
          );
        },
      );
    },
  );
}
