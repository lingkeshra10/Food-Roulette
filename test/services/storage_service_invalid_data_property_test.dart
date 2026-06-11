import 'dart:convert';

import 'package:glados/glados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_roulette/services/storage_service.dart';

/// Generators for various categories of invalid storage data.
extension InvalidDataGenerators on Any {
  /// Random non-JSON strings (alphanumeric characters that won't parse as JSON).
  Generator<String> get nonJsonString =>
      letterOrDigits.map((s) => 'not_json_$s');

  /// Valid JSON arrays (wrong top-level type; expected a map).
  Generator<String> get jsonArrayString =>
      list(any.int).map(jsonEncode);

  /// Valid JSON map but with numeric values instead of lists.
  Generator<String> get jsonMapWithWrongValueTypes =>
      positiveIntOrZero.map((n) => jsonEncode({'breakfast': n, 'lunch': n}));

  /// Valid JSON map with lists containing shop objects missing 'createdAt'.
  Generator<String> get jsonMissingCreatedAt => letterOrDigits.map((name) =>
      jsonEncode({
        'breakfast': [
          {'name': name}
        ]
      }));

  /// Truncated/partial JSON strings.
  Generator<String> get truncatedJson =>
      letterOrDigits.map((name) => '{"breakfast": [{"name": "$name", "createdAt"');

  /// Valid JSON map with arrays containing non-map items (integers, strings).
  Generator<String> get jsonArraysWithNonMapItems =>
      positiveIntOrZero.map((n) => jsonEncode({
            'breakfast': [n, n + 1],
            'lunch': ['string_not_map']
          }));

  /// Combines all invalid data generators into one.
  Generator<String> get invalidStorageString => oneOf([
        nonJsonString,
        jsonArrayString,
        jsonMapWithWrongValueTypes,
        jsonMissingCreatedAt,
        truncatedJson,
        jsonArraysWithNonMapItems,
      ]);
}

void main() {
  group(
    'Feature: food-roulette-app, Property 7: Invalid storage data yields empty lists',
    () {
      /// **Validates: Requirements 3.3**
      ///
      /// For any malformed or unparseable string stored in SharedPreferences,
      /// loading shop lists shall return null (signaling the provider to start
      /// with empty lists) rather than throwing an exception.
      Glados(
        any.invalidStorageString,
        ExploreConfig(numRuns: 100),
      ).test(
        'any invalid storage string yields null without throwing',
        (String invalidData) async {
          // Arrange: inject invalid data into SharedPreferences mock
          SharedPreferences.setMockInitialValues(
              {'food_roulette_data': invalidData});

          // Act: attempt to load shop lists
          final storageService = StorageService();
          final result = await storageService.loadShopLists();

          // Assert: should return null (not throw)
          expect(
            result,
            isNull,
            reason:
                'loadShopLists should return null for invalid data: "$invalidData"',
          );
        },
      );

      Glados(
        any.nonJsonString,
        ExploreConfig(numRuns: 100),
      ).test(
        'random non-JSON strings yield null without throwing',
        (String randomString) async {
          // Arrange: inject a random non-JSON string
          SharedPreferences.setMockInitialValues(
              {'food_roulette_data': randomString});

          // Act
          final storageService = StorageService();
          final result = await storageService.loadShopLists();

          // Assert: should return null (not throw)
          expect(
            result,
            isNull,
            reason:
                'loadShopLists should return null for non-JSON string: "$randomString"',
          );
        },
      );

      Glados(
        any.jsonMissingCreatedAt,
        ExploreConfig(numRuns: 100),
      ).test(
        'valid JSON with missing required fields yields null without throwing',
        (String jsonWithMissingFields) async {
          // Arrange: valid JSON but shop objects miss 'createdAt' field
          SharedPreferences.setMockInitialValues(
              {'food_roulette_data': jsonWithMissingFields});

          // Act
          final storageService = StorageService();
          final result = await storageService.loadShopLists();

          // Assert: should return null (not throw)
          expect(
            result,
            isNull,
            reason:
                'loadShopLists should return null for JSON with missing fields: "$jsonWithMissingFields"',
          );
        },
      );
    },
  );
}
