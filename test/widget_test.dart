import 'package:flutter_test/flutter_test.dart';

import 'package:food_roulette/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodRouletteApp());

    expect(find.text('Food Roulette'), findsOneWidget);
  });
}
