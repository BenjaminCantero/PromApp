import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/features/asignaturas/application/asignatura_providers.dart';
import 'package:promapp/features/asignaturas/data/api_asignatura_repository.dart';
import 'package:promapp/features/asignaturas/data/asignatura_repository.dart';
import 'package:promapp/features/asignaturas/domain/asignatura.dart';
import 'package:promapp/features/asignaturas/presentation/asignatura_config_screen.dart';

/// Repositorio que simula una API caída al guardar.
class _RepoQueFalla implements AsignaturaRepository {
  @override
  Future<List<Asignatura>> getAsignaturas() async => [];

  @override
  Future<Asignatura?> getAsignatura(String id) async => null;

  @override
  Future<void> saveAsignatura(Asignatura a) async =>
      throw const ApiException('No se pudo conectar con el servidor.');

  @override
  Future<void> deleteAsignatura(String id) async {}
}

void main() {
  testWidgets('Si la API falla al guardar, avisa y NO cierra el formulario',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          asignaturaRepositoryProvider.overrideWith((ref) => _RepoQueFalla()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const AsignaturaConfigScreen(),
                    ),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Información General'), findsOneWidget);

    // Nombre del ramo (primer TextField del formulario).
    await tester.enterText(find.byType(TextField).at(0), 'Cálculo I');

    // Añadir una evaluación que sume 100%.
    await tester.tap(find.text('Añadir evaluación'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(3), 'Certamen 1');
    await tester.enterText(find.byType(TextField).at(4), '100');
    await tester.pumpAndSettle();

    // Intentar guardar → la API falla. (El botón se construye lazy, bajo el fold.)
    await tester.scrollUntilVisible(
      find.text('Crear asignatura'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Crear asignatura'));
    await tester.pump(); // dispara el guardado
    await tester.pump(const Duration(milliseconds: 400)); // anima el snackbar

    // Avisa del error...
    expect(find.text('No se pudo conectar con el servidor.'), findsOneWidget);
    // ...y el formulario sigue abierto, sin perder lo escrito.
    expect(find.text('Información General'), findsOneWidget);
    expect(find.text('Cálculo I'), findsOneWidget);
    expect(find.text('abrir'), findsNothing); // no volvió atrás
  });
}
