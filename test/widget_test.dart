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

  testWidgets('La política de privacidad está disponible desde Ajustes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides, child: const PromApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Resumen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('perfil-avatar')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Privacidad'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Privacidad'));
    await tester.pumpAndSettle();

    expect(find.text('Privacidad simple y transparente'), findsOneWidget);
    expect(find.text('Sin publicidad ni seguimiento'), findsOneWidget);
  });
}
