import 'dart:convert';

import 'package:glados/glados.dart';
import 'package:food_roulette/models/food_shop.dart';
import 'package:food_roulette/models/meal_category.dart';

/// Custom generators for property-based testing of storage round-trip.
extension StorageGenerators on Any {
  /// Generates a valid shop name (1-50 alphanumeric characters).
  Generator<String> get shopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a [FoodShop] with a random name and a positive timestamp.
  Generator<FoodShop> get foodShop => combine2(
        shopName,
        intInRange(0, 2000000000),
        (String name, int millis) => FoodShop(
          name: name,
          createdAt: DateTime.fromMillisecondsSinceEpoch(millis),
        ),
      );

  /// Generates a list of 0-10 [FoodShop] items for a single category.
  Generator<List<FoodShop>> get foodShopList =>
      listWithLengthInRange(0, 10, foodShop);

  /// Generates a full category map with shop lists for all five categories.
  Generator<Map<MealCategory, List<FoodShop>>> get shopListsMap => combine5(
        foodShopList,
        foodShopList,
        foodShopList,
        foodShopList,
        foodShopList,
        (List<FoodShop> breakfast, List<FoodShop> lunch,
                List<FoodShop> teaTime, List<FoodShop> dinner,
                List<FoodShop> supper) =>
            {
          MealCategory.breakfast: breakfast,
          MealCategory.lunch: lunch,
          MealCategory.teaTime: teaTime,
          MealCategory.dinner: dinner,
          MealCategory.supper: supper,
        },
      );
}

void main() {
  group(
    'Feature: food-roulette-app, Property 6: Storage round-trip preserves data and order',
    () {
      /// **Validates: Requirements 3.2**
      ///
      /// For any valid collection of shop lists across all categories,
      /// serializing the data to JSON and then deserializing it shall produce
      /// an equivalent collection where each category contains the same shops
      /// in the same order.
      Glados(
        any.shopListsMap,
        ExploreConfig(numRuns: 100),
      ).test(
        'serializing to JSON and deserializing produces equivalent data in same order',
        (Map<MealCategory, List<FoodShop>> original) {
          // Serialize: replicate StorageService.saveShopLists logic
          final Map<String, dynamic> jsonMap = {};
          for (final category in MealCategory.values) {
            final shops = original[category] ?? [];
            jsonMap[category.name] =
                shops.map((shop) => shop.toJson()).toList();
          }
          final jsonString = jsonEncode(jsonMap);

          // Deserialize: replicate StorageService.loadShopLists logic
          final Map<String, dynamic> decoded =
              jsonDecode(jsonString) as Map<String, dynamic>;
          final Map<MealCategory, List<FoodShop>> restored = {};

          for (final category in MealCategory.values) {
            final List<dynamic>? shopListJson =
                decoded[category.name] as List<dynamic>?;
            if (shopListJson != null) {
              restored[category] = shopListJson
                  .map((item) =>
                      FoodShop.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else {
              restored[category] = [];
            }
          }

          // Verify: same categories, same shops, same order
          for (final category in MealCategory.values) {
            final originalShops = original[category] ?? [];
            final restoredShops = restored[category] ?? [];

            expect(
              restoredShops.length,
              equals(originalShops.length),
              reason:
                  'Category ${category.name} should have same number of shops after round-trip',
            );

            for (var i = 0; i < originalShops.length; i++) {
              expect(
                restoredShops[i].name,
                equals(originalShops[i].name),
                reason:
                    'Shop at index $i in ${category.name} should have same name after round-trip',
              );
              expect(
                restoredShops[i].createdAt.millisecondsSinceEpoch,
                equals(originalShops[i].createdAt.millisecondsSinceEpoch),
                reason:
                    'Shop at index $i in ${category.name} should have same createdAt after round-trip',
              );
            }
          }
        },
      );
    },
  );
}
