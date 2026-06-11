import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal_category.dart';
import '../providers/category_provider.dart';
import '../widgets/category_card.dart';
import 'shop_list_screen.dart';

/// The root screen displaying five category cards in a scrollable grid layout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('Food Roulette'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          const categories = MealCategory.values;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopListScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
