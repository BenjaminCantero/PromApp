import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/app.dart';

import 'helpers/auth_test_helper.dart';

void main() {
  testWidgets('La app arranca en el Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
        ProviderScope(overrides: loggedInOverrides, child: const PromApp()));
    await tester.pumpAndSettle();

    // El dashboard muestra su sección principal.
    expect(find.text('Mi Rendimiento'), findsOneWidget);
    // El bottom nav muestra la tab activa "Inicio".
    expect(find.text('Inicio'), findsOneWidget);
  });
}
