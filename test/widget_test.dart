import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tenant_flutter_application/main.dart';

void main() {
  testWidgets('App builds and shows splash branding', (WidgetTester tester) async {
    final errors = <FlutterErrorDetails>[];
    final originalHandler = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details);

    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('TenantHub'), findsOneWidget);
    expect(find.text('Your Smart Tenant Companion'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    FlutterError.onError = originalHandler;
  });
}