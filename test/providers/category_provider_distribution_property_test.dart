import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_roulette/models/meal_category.dart';
import 'package:food_roulette/providers/category_provider.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Custom generators for uniform distribution property test.
extension DistributionGenerators on Any {
  /// Generates a unique valid shop name (1-50 alphanumeric characters).
  Generator<String> get shopName =>
      nonEmptyLetterOrDigits.map((s) => s.length > 50 ? s.substring(0, 50) : s);

  /// Generates a list of 2-5 unique shop names for testing distribution.
  Generator<List<String>> get uniqueShopNames =>
      listWithLengthInRange(2, 5, shopName).map((names) {
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
    'Feature: food-roulette-app, Property 9: Uniform random distribution',
    () {
      /// **Validates: Requirements 4.5**
      ///
      /// For any category with N shops (N ≥ 2), over a large number of
      /// pickRandom calls, each shop shall be selected approximately 1/N
      /// of the time within statistical tolerance.
      Glados2(
        any.choose(MealCategory.values),
        any.uniqueShopNames,
        ExploreConfig(numRuns: 5),
      ).test(
        'pickRandom distributes selections approximately uniformly across all shops',
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
          final n = shops.length;
          expect(
            n,
            greaterThanOrEqualTo(2),
            reason: 'Category must have at least 2 shops for pickRandom',
          );

          // Call pickRandom many times and count selections
          const totalPicks = 1000;
          final counts = <String, int>{};
          for (final shop in shops) {
            counts[shop.name] = 0;
          }

          for (var i = 0; i < totalPicks; i++) {
            final result = provider.pickRandom(category);
            expect(result, isNotNull);
            counts[result!.name] = (counts[result.name] ?? 0) + 1;
          }

          // Verify uniform distribution with generous tolerance
          // Expected count per shop: totalPicks / n
          // Accept if each count is within [expected * 0.4, expected * 1.6]
          final expectedCount = totalPicks / n;
          final lowerBound = expectedCount * 0.4;
          final upperBound = expectedCount * 1.6;

          for (final shop in shops) {
            final count = counts[shop.name]!;
            expect(
              count,
              greaterThanOrEqualTo(lowerBound.floor()),
              reason:
                  'Shop "${shop.name}" was selected $count times, expected at least ${lowerBound.floor()} '
                  '(expected ~${expectedCount.round()} out of $totalPicks picks for $n shops)',
            );
            expect(
              count,
              lessThanOrEqualTo(upperBound.ceil()),
              reason:
                  'Shop "${shop.name}" was selected $count times, expected at most ${upperBound.ceil()} '
                  '(expected ~${expectedCount.round()} out of $totalPicks picks for $n shops)',
            );
          }
        },
      );
    },
  );
}
