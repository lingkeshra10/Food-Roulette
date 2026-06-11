import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/food_shop.dart';
import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/models/result_types.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for shop removal property testing.
extension RemovePropertyGenerators on Any {
  /// Generates a unique shop name (1-50 alphanumeric characters).
  Generator<String> get shopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a list of 1-10 unique shop names.
  Generator<List<String>> get uniqueShopNames =>
      listWithLengthInRange(1, 10, shopName).map((names) {
        // Ensure uniqueness by appending index suffix
        final unique = <String>[];
        for (var i = 0; i < names.length; i++) {
          final candidate = '${names[i]}$i';
          unique.add(candidate.length > 50 ? candidate.substring(0, 50) : candidate);
        }
        return unique;
      });
}

void main() {
  group(
    'Feature: food-roulette-app, Property 4: Removing a shop shrinks the list',
    () {
      /// **Validates: Requirements 2.3**
      ///
      /// For any Category with at least one shop, removing a shop from the
      /// list shall result in the list length decreasing by exactly one and
      /// the removed shop no longer appearing in the list, while all other
      /// entries retain their relative order.
      Glados2(
        any.choose(MealCategory.values),
        any.uniqueShopNames,
        ExploreConfig(numRuns: 100),
      ).test(
        'removing a shop decreases list length by one, removes the shop, and preserves order of others',
        (MealCategory category, List<String> shopNames) async {
          // Arrange: set up storage and provider
          SharedPreferences.setMockInitialValues({});
          final storageService = StorageService();
          final provider = CategoryProvider(storageService: storageService);

          // Add all shops to the category
          for (final name in shopNames) {
            final result = await provider.addShop(category, name);
            expect(
              result,
              equals(AddShopResult.success),
              reason: 'Adding shop "$name" should succeed',
            );
          }

          // Get the list before removal
          final shopsBefore = provider.getShops(category);
          final lengthBefore = shopsBefore.length;
          expect(
            lengthBefore,
            equals(shopNames.length),
            reason: 'All shops should have been added',
          );

          // Pick a random shop to remove (use index based on list length)
          final removeIndex = lengthBefore ~/ 2; // deterministic middle pick
          final shopToRemove = shopsBefore[removeIndex];

          // Act: remove the shop
          final removeResult = await provider.removeShop(category, shopToRemove);
          expect(
            removeResult,
            equals(RemoveShopResult.success),
            reason: 'Removing the shop should succeed',
          );

          // Assert: list length decreased by exactly one
          final shopsAfter = provider.getShops(category);
          expect(
            shopsAfter.length,
            equals(lengthBefore - 1),
            reason: 'List length should decrease by exactly 1 after removal',
          );

          // Assert: removed shop no longer in list
          final removedStillPresent = shopsAfter.any(
            (shop) => shop.name.toLowerCase() == shopToRemove.name.toLowerCase(),
          );
          expect(
            removedStillPresent,
            isFalse,
            reason: 'Removed shop should no longer appear in the list',
          );

          // Assert: remaining shops retain their relative order
          final expectedRemaining = List<FoodShop>.from(shopsBefore)
            ..removeAt(removeIndex);
          expect(
            shopsAfter.length,
            equals(expectedRemaining.length),
            reason: 'Remaining list should match expected length',
          );
          for (var i = 0; i < expectedRemaining.length; i++) {
            expect(
              shopsAfter[i].name,
              equals(expectedRemaining[i].name),
              reason:
                  'Shop at index $i should be "${expectedRemaining[i].name}" but was "${shopsAfter[i].name}" — relative order must be preserved',
            );
          }
        },
      );
    },
  );
}
