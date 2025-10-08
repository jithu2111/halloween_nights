// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:halloween_nights/main.dart';

void main() {
  testWidgets('Halloween app loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HalloweenNightsApp());

    // Verify that our Halloween app starts with the home screen.
    expect(find.text('HALLOWEEN NIGHTS'), findsOneWidget);
    expect(find.text('Enter if you dare...'), findsOneWidget);

    // Verify that the main game buttons are present
    expect(find.text('Ghost Hunt'), findsOneWidget);
    expect(find.text('Halloween Trivia'), findsOneWidget);
  });
}
