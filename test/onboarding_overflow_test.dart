import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_flutter_application/screens/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding last page has no overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 660);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.drag(
        find.byType(PageView),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });
}