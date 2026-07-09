import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';

import 'helpers/auth_test_helper.dart';

void main() {

  testWidgets('Abre Perfil desde el avatar y cierra sesión → vuelve al login',
      (tester) async {
    await tester.pumpWidget(
        ProviderScope(overrides: loggedInOverrides, child: const PromApp()));
    await tester.pumpAndSettle();

    // Tocar el avatar del hero abre la pantalla de Perfil.
    await tester.tap(find.byKey(const Key('perfil-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('test@promapp.cl'), findsWidgets);

    // Cerrar sesión → confirmar en el diálogo.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    // El AuthGate muestra la pantalla de acceso.
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
