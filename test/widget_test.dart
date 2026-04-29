// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dermatologist_assist/screens/splash_screen.dart';
import 'package:dermatologist_assist/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dermatologist_assist/main.dart';

void main() {
  testWidgets('App starts and shows SplashScreen', (WidgetTester tester) async {
    final themeService = ThemeService();
    await tester.pumpWidget(MelanomaApp(themeService: themeService, initialTheme: ThemeMode.light));

    expect(find.byType(SplashScreen), findsOneWidget);


    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
