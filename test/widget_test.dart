import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:metamoot_app/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds a MaterialApp (adjust if your root widget differs).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
