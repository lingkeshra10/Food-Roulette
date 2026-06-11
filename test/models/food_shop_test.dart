import 'package:flutter_test/flutter_test.dart';
import 'package:food_roulette/models/food_shop.dart';

void main() {
  group('FoodShop', () {
    group('JSON serialization', () {
      test('round-trip: toJson then fromJson produces equivalent data', () {
        final createdAt = DateTime.utc(2024, 3, 15, 10, 30);
        final original = FoodShop(name: 'KFC', createdAt: createdAt);

        final json = original.toJson();
        final restored = FoodShop.fromJson(json);

        expect(restored.name, equals(original.name));
        expect(restored.createdAt, equals(original.createdAt));
      });

      test('boundary: 1-character name serializes correctly', () {
        final createdAt = DateTime.utc(2024, 1, 1);
        final shop = FoodShop(name: 'A', createdAt: createdAt);

        final json = shop.toJson();
        expect(json['name'], equals('A'));
        expect(json['createdAt'], equals(createdAt.toIso8601String()));

        final restored = FoodShop.fromJson(json);
        expect(restored.name, equals('A'));
        expect(restored.createdAt, equals(createdAt));
      });

      test('boundary: 50-character name serializes correctly', () {
        final longName = 'A' * 50;
        final createdAt = DateTime.utc(2024, 6, 20, 18, 0);
        final shop = FoodShop(name: longName, createdAt: createdAt);

        final json = shop.toJson();
        expect(json['name'], equals(longName));
        expect((json['name'] as String).length, equals(50));

        final restored = FoodShop.fromJson(json);
        expect(restored.name, equals(longName));
        expect(restored.name.length, equals(50));
        expect(restored.createdAt, equals(createdAt));
      });
    });

    group('case-insensitive equality', () {
      test('shops with same name in different cases are equal', () {
        final now = DateTime.utc(2024, 1, 1);
        final upper = FoodShop(name: 'KFC', createdAt: now);
        final lower = FoodShop(name: 'kfc', createdAt: now);

        expect(upper, equals(lower));
        expect(upper.hashCode, equals(lower.hashCode));
      });

      test('shops with different names are not equal', () {
        final now = DateTime.utc(2024, 1, 1);
        final kfc = FoodShop(name: 'KFC', createdAt: now);
        final mcd = FoodShop(name: 'MCD', createdAt: now);

        expect(kfc, isNot(equals(mcd)));
      });
    });
  });
}
