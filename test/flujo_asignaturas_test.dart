import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';

import 'helpers/auth_test_helper.dart';

void main() {
  mockOnboardingVisto();

  testWidgets('Navega a la lista y abre el detalle de una asignatura',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: testOverrides, child: const PromApp()));
    await tester.pumpAndSettle();

    // Ir a la tab "Ramos" (label del bottom nav).
    await tester.tap(find.text('Ramos'));
    await tester.pumpAndSettle();

    // La lista carga los ramos del mock.
    expect(find.text('Programación Avanzada'), findsOneWidget);

    // Abrir el detalle del primer ramo.
    await tester.tap(find.text('Programación Avanzada'));
    await tester.pumpAndSettle();

    // Sección propia del detalle (scroll para forzar su construcción lazy).
    await tester.scrollUntilVisible(
      find.text('Calculadora de Eximición'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Calculadora de Eximición'), findsOneWidget);
  });

  testWidgets('Abre el formulario de Nueva Asignatura', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: testOverrides, child: const PromApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ramos'));
    await tester.pumpAndSettle();

    // Botón "Nuevo" del encabezado de la lista.
    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();

    // Scrollear para que el texto sea visible (ya que las tarjetas son más grandes)
    await tester.dragFrom(const Offset(400, 300), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Información General'), findsOneWidget);
    expect(find.text('Nombre del ramo *'), findsOneWidget);
  });
}
