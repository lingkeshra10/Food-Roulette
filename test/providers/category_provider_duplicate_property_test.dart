import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/models/result_types.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for property-based testing of case-insensitive duplicates.
extension DuplicateGenerators on Any {
  /// Generates a valid shop name: 1-50 non-whitespace-only characters.
  Generator<String> get validShopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a random [MealCategory] value.
  Generator<MealCategory> get mealCategory => choose(MealCategory.values);
}

/// Produces a case-variant of the given name by toggling the case of each
/// alphabetical character.
String _toggleCase(String name) {
  return String.fromCharCodes(name.codeUnits.map((unit) {
    // Uppercase A-Z → lowercase
    if (unit >= 65 && unit <= 90) return unit + 32;
    // Lowercase a-z → uppercase
    if (unit >= 97 && unit <= 122) return unit - 32;
    return unit;
  }));
}

void main() {
  group(
    'Feature: food-roulette-app, Property 5: Case-insensitive duplicate rejection',
    () {
      /// **Validates: Requirements 2.5**
      ///
      /// For any existing shop name in a category, attempting to add a name
      /// that differs only in letter casing shall be rejected, and the
      /// category's shop list shall remain unchanged.
      Glados2(
        any.mealCategory,
        any.validShopName,
        ExploreConfig(numRuns: 100),
      ).test(
        'adding a case-variant of an existing shop name is rejected and list is unchanged',
        (MealCategory category, String shopName) async {
          // Set up SharedPreferences mock with empty state
          SharedPreferences.setMockInitialValues({});

          final storageService = StorageService();
          final provider = CategoryProvider(storageService: storageService);
          await provider.loadData();

          final trimmedName = shopName.trim();
          // Guard: skip if the generated name is somehow invalid after trimming
          if (trimmedName.isEmpty || trimmedName.length > 50) return;

          // First, add the original name (should succeed on empty list)
          final addResult = await provider.addShop(category, shopName);
          expect(
            addResult,
            equals(AddShopResult.success),
            reason: 'Initial add of a valid, unique shop name should succeed',
          );

          // Record list state after the first add
          final shopsAfterAdd = provider.getShops(category);
          final lengthAfterAdd = shopsAfterAdd.length;

          // Generate a case-variant of the same name
          final caseVariant = _toggleCase(trimmedName);

          // Attempt to add the case-variant
          final duplicateResult = await provider.addShop(category, caseVariant);

          // Verify: result should be duplicateName
          expect(
            duplicateResult,
            equals(AddShopResult.duplicateName),
            reason:
                'Adding "$caseVariant" (case-variant of "$trimmedName") should be rejected as a duplicate',
          );

          // Verify: list should remain unchanged
          final shopsAfterDuplicate = provider.getShops(category);
          expect(
            shopsAfterDuplicate.length,
            equals(lengthAfterAdd),
            reason:
                'Shop list length should remain unchanged after rejecting a case-insensitive duplicate',
          );

          // Verify: the original shop name is still the only entry
          expect(
            shopsAfterDuplicate.first.name,
            equals(trimmedName),
            reason:
                'The original shop entry should remain unchanged after duplicate rejection',
          );
        },
      );
    },
  );
}
