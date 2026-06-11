import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for random pick membership property test.
extension RandomPickGenerators on Any {
  /// Generates a unique valid shop name (1-50 alphanumeric characters).
  Generator<String> get shopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a list of 2-10 unique shop names for a category.
  Generator<List<String>> get uniqueShopNames =>
      listWithLengthInRange(2, 10, shopName).map((names) {
        // Ensure uniqueness by appending index if needed
        final seen = <String>{};
        final unique = <String>[];
        for (var i = 0; i < names.length; i++) {
          var name = names[i];
          final lower = name.toLowerCase();
          if (seen.contains(lower)) {
            name = '$name$i';
            if (name.length > 50) {
              name = name.substring(0, 50);
            }
          }
          seen.add(name.toLowerCase());
          unique.add(name);
        }
        return unique.length >= 2 ? unique : [...unique, 'ExtraShop'];
      });
}

void main() {
  group(
    'Feature: food-roulette-app, Property 8: Random pick is always a list member',
    () {
      /// **Validates: Requirements 4.1**
      ///
      /// For any category with two or more shops, calling pickRandom shall
      /// return a FoodShop that exists in that category's shop list.
      Glados2(
        any.choose(MealCategory.values),
        any.uniqueShopNames,
        ExploreConfig(numRuns: 100),
      ).test(
        'pickRandom returns a shop that exists in the category shop list',
        (MealCategory category, List<String> shopNames) async {
          // Set up mock SharedPreferences
          SharedPreferences.setMockInitialValues({});

          // Create StorageService and CategoryProvider
          final storageService = StorageService();
          final provider = CategoryProvider(storageService: storageService);
          await provider.loadData();

          // Add all shops to the category
          for (final name in shopNames) {
            await provider.addShop(category, name);
          }

          // Verify we have at least 2 shops
          final shops = provider.getShops(category);
          expect(
            shops.length,
            greaterThanOrEqualTo(2),
            reason: 'Category must have at least 2 shops for pickRandom',
          );

          // Call pickRandom multiple times and verify membership
          for (var i = 0; i < 10; i++) {
            final result = provider.pickRandom(category);

            // Result must not be null for a category with 2+ shops
            expect(
              result,
              isNotNull,
              reason:
                  'pickRandom must not return null when category has 2+ shops',
            );

            // Result must exist in the category's shop list
            final currentShops = provider.getShops(category);
            expect(
              currentShops.contains(result),
              isTrue,
              reason:
                  'pickRandom result "${result?.name}" must exist in the category shop list',
            );
          }
        },
      );
    },
  );
}
