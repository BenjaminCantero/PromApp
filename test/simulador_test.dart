import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';
import 'package:promapp/core/router/app_router.dart';

import 'helpers/auth_test_helper.dart';

void main() {
  setUp(() => appRouter.go(AppRoutes.dashboard));

  Future<void> abrirSimulador(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(overrides: loggedInOverrides, child: const PromApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();
    expect(find.text('Parámetros de Evaluación'), findsOneWidget);
  }

  testWidgets('El simulador calcula la nota mínima de examen en vivo',
      (tester) async {
    await abrirSimulador(tester);

    // Presentación 5.0, examen 40% → objetivo 4.0.
    // (4.0 - 5.0*0.6) / 0.4 = 2.5
    await tester.enterText(find.byType(TextField).at(0), '5.0');
    await tester.enterText(find.byType(TextField).at(1), '40');
    await tester.pumpAndSettle();

    // Las tarjetas de resultado están más abajo (ListView lazy) → scroll.
    await tester.scrollUntilVisible(
      find.text('Necesitas rendir'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Necesitas rendir'), findsOneWidget);
    expect(find.text('2.5'), findsWidgets);
  });

  testWidgets('Detecta eximición cuando la presentación la supera',
      (tester) async {
    await abrirSimulador(tester);

    await tester.enterText(find.byType(TextField).at(0), '6.0'); // presentación
    await tester.enterText(find.byType(TextField).at(1), '40'); // % examen
    await tester.enterText(find.byType(TextField).at(2), '5.5'); // eximir
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('¡Estás eximido!'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('¡Estás eximido!'), findsOneWidget);
  });
}
