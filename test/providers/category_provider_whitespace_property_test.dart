import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/models/result_types.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for whitespace-only strings.
extension WhitespaceGenerators on Any {
  /// Generates a whitespace-only string of varying length (0-20 characters)
  /// composed of spaces, tabs, and newlines.
  Generator<String> get whitespaceOnly {
    const whitespaceChars = [' ', '\t', '\n', '\r', '\f', '\v'];
    return listWithLengthInRange(0, 20, choose(whitespaceChars))
        .map((chars) => chars.join());
  }
}

void main() {
  group(
    'Feature: food-roulette-app, Property 3: Whitespace-only names are rejected',
    () {
      /// **Validates: Requirements 2.2**
      ///
      /// For any string composed entirely of whitespace characters (including
      /// the empty string), attempting to add it as a shop name shall be
      /// rejected, and the category's shop list shall remain unchanged.
      Glados2(
        any.choose(MealCategory.values),
        any.whitespaceOnly,
        ExploreConfig(numRuns: 100),
      ).test(
        'whitespace-only names are rejected and shop list remains unchanged',
        (MealCategory category, String whitespaceString) async {
          SharedPreferences.setMockInitialValues({});

          final storageService = StorageService();
          final provider = CategoryProvider(storageService: storageService);
          await provider.loadData();

          // Capture the shop list before the attempt
          final shopsBefore = provider.getShops(category);
          final lengthBefore = shopsBefore.length;

          // Attempt to add the whitespace-only string
          final result = await provider.addShop(category, whitespaceString);

          // Verify rejection
          expect(
            result,
            equals(AddShopResult.emptyName),
            reason:
                'Whitespace-only string "${whitespaceString.replaceAll('\n', '\\n').replaceAll('\t', '\\t').replaceAll('\r', '\\r')}" (length ${whitespaceString.length}) should be rejected with emptyName',
          );

          // Verify list remains unchanged
          final shopsAfter = provider.getShops(category);
          expect(
            shopsAfter.length,
            equals(lengthBefore),
            reason:
                'Shop list length should remain unchanged after rejecting whitespace-only input',
          );
        },
      );
    },
  );
}
