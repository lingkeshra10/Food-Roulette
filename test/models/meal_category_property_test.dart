import 'package:glados/glados.dart';
import 'package:food_roulette/models/meal_category.dart';

void main() {
  group(
    'Feature: food-roulette-app, Property 1: Category colors are unique',
    () {
      /// **Validates: Requirements 1.2, 5.1**
      ///
      /// For any two distinct MealCategory values, their assigned colors
      /// must be different.
      Glados2(
        any.choose(MealCategory.values),
        any.choose(MealCategory.values),
        ExploreConfig(numRuns: 100),
      ).test(
        'any two distinct categories have different colors',
        (MealCategory category1, MealCategory category2) {
          if (category1 != category2) {
            expect(
              category1.color,
              isNot(equals(category2.color)),
              reason:
                  '${category1.displayName} and ${category2.displayName} must have different colors',
            );
          }
        },
      );

      // Exhaustive pairwise check for completeness
      test('all category pairs have unique colors (exhaustive)', () {
        const categories = MealCategory.values;
        for (var i = 0; i < categories.length; i++) {
          for (var j = i + 1; j < categories.length; j++) {
            expect(
              categories[i].color,
              isNot(equals(categories[j].color)),
              reason:
                  '${categories[i].displayName} and ${categories[j].displayName} must have different colors',
            );
          }
        }
      });
    },
  );
}
