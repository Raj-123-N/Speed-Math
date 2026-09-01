import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speed_math/app/app.dart';
import 'package:provider/provider.dart';
import 'package:speed_math/app/theme/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const SpeedMathApp(),
      ),
    );

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
