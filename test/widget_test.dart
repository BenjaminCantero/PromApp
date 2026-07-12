import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';

import 'helpers/auth_test_helper.dart';

void main() {
  mockOnboardingVisto();
  testWidgets('La app arranca en la Calculadora Libre', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides, child: const PromApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cálculo Libre'), findsOneWidget);
    expect(find.text('Calculadora'), findsOneWidget);

    await tester.tap(find.text('Resumen'));
    await tester.pumpAndSettle();
    expect(find.text('Mi Rendimiento'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('MODO OBJETIVO'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('MODO OBJETIVO'), findsOneWidget);
    expect(find.text('META 4.0'), findsOneWidget);
  });
}
