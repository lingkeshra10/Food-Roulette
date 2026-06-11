import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/category_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const FoodRouletteApp());
}

class FoodRouletteApp extends StatelessWidget {
  const FoodRouletteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = CategoryProvider(storageService: StorageService());
        provider.loadData();
        return provider;
      },
      child: MaterialApp(
        title: 'Food Roulette',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Colors.deepOrange;
    const fontFamily = 'Roboto';
    const borderRadius = BorderRadius.all(Radius.circular(12.0));

    return ThemeData(
      primarySwatch: Colors.deepOrange,
      primaryColor: primaryColor,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: const Color(0xFFFFF8E1),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepOrange,
        backgroundColor: const Color(0xFFFFF8E1),
      ).copyWith(
        secondary: Colors.orangeAccent,
      ),
    );
  }
}