import 'package:flutter/material.dart';

/// Represents the five predefined meal categories in the app.
enum MealCategory {
  breakfast,
  lunch,
  teaTime,
  dinner,
  supper,
}

/// Extension providing display properties for each [MealCategory].
extension MealCategoryExtension on MealCategory {
  /// Human-readable name for the category.
  String get displayName {
    switch (this) {
      case MealCategory.breakfast:
        return 'Breakfast';
      case MealCategory.lunch:
        return 'Lunch';
      case MealCategory.teaTime:
        return 'Tea Time';
      case MealCategory.dinner:
        return 'Dinner';
      case MealCategory.supper:
        return 'Supper';
    }
  }

  /// Unique background color for the category card.
  Color get color {
    switch (this) {
      case MealCategory.breakfast:
        return const Color(0xFFFF8A65);
      case MealCategory.lunch:
        return const Color(0xFFFFD54F);
      case MealCategory.teaTime:
        return const Color(0xFF81C784);
      case MealCategory.dinner:
        return const Color(0xFF64B5F6);
      case MealCategory.supper:
        return const Color(0xFFCE93D8);
    }
  }

  /// Representative icon for the meal type.
  IconData get icon {
    switch (this) {
      case MealCategory.breakfast:
        return Icons.free_breakfast;
      case MealCategory.lunch:
        return Icons.lunch_dining;
      case MealCategory.teaTime:
        return Icons.local_cafe;
      case MealCategory.dinner:
        return Icons.dinner_dining;
      case MealCategory.supper:
        return Icons.nightlight_round;
    }
  }
}
