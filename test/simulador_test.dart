import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';

import 'helpers/auth_test_helper.dart';

void main() {
  mockOnboardingVisto();
  /// Abre la tab "Calcular" y deja visibles los campos de entrada.
  ///
  /// En la pantalla, las tarjetas de resultado van ARRIBA y los campos de
  /// "Parámetros de Evaluación" más abajo (SliverList lazy) → hay que bajar.
  Future<void> abrirSimulador(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides, child: const PromApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    await tester.dragFrom(const Offset(400, 150), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Parámetros de Evaluación'), findsOneWidget);
  }

  Future<void> subirHasta(WidgetTester tester, Finder objetivo) async {
    await tester.dragFrom(const Offset(400, 150), const Offset(0, 400));
    await tester.pumpAndSettle();
  }

  testWidgets('El simulador calcula la nota mínima de examen en vivo',
      (tester) async {
    await abrirSimulador(tester);

    // Presentación 5.0, examen 40% → objetivo 4.0.
    // (4.0 - 5.0*0.6) / 0.4 = 2.5
    await tester.enterText(find.byType(TextField).at(0), '5.0');
    await tester.enterText(find.byType(TextField).at(1), '40');
    await tester.pumpAndSettle();

    await subirHasta(tester, find.text('Necesitas rendir'));
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

    await subirHasta(tester, find.text('¡Estás eximido!'));
    expect(find.text('¡Estás eximido!'), findsOneWidget);
  });
}
