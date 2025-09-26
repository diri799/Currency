// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⬇️ IMPORTANT: make this import match your pubspec `name:`
// If pubspec `name: currency_1`, keep currency_1.
// If it's `currensee`, use package:currensee/main.dart, etc.
import 'package:currency_1/main.dart';

void main() {
  testWidgets('App builds and shows a MaterialApp', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CurrenSeeApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
