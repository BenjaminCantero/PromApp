import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promapp/core/storage/local_db_interface.dart';
import 'package:promapp/core/storage/local_db_non_web.dart';
import 'package:promapp/core/storage/local_db_provider.dart';
import 'package:promapp/core/storage/token_storage.dart';
import 'package:promapp/core/utils/backup_manager.dart';
import 'package:promapp/features/asignaturas/data/local_asignatura_repository.dart';
import 'package:promapp/features/asignaturas/domain/asignatura.dart';
import 'package:promapp/features/asignaturas/domain/evaluacion.dart';


class MockTokenStorage extends TokenStorage {
  String? _token;
  @override
  Future<void> save(String token) async => _token = token;
  @override
  Future<String?> read() async => _token;
  @override
  Future<void> clear() async => _token = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDb db;
  late LocalAsignaturaRepository repo;
  late ProviderContainer container;

  setUp(() async {
    // Inicializar SharedPreferences de test
    SharedPreferences.setMockInitialValues({});
    db = LocalDbImpl();
    await db.init();
    
    repo = LocalAsignaturaRepository(db);
    
    // Configurar el contenedor de Riverpod para test
    container = ProviderContainer(
      overrides: [
        localDbProvider.overrideWithValue(db),
        tokenStorageProvider.overrideWithValue(MockTokenStorage()),
      ],
    );
    
  });


  tearDown(() {
    container.dispose();
  });

  group('Pruebas de Base de Datos Local y CRUD de Asignaturas', () {
    test('Crear y Leer asignatura con evaluaciones', () async {
      final asignatura = Asignatura(
        id: 'test-ramo-1',
        nombre: 'Cálculo I',
        codigo: 'MAT101',
        semestre: '2026-1',
        tieneExamen: true,
        evaluaciones: [
          const Evaluacion(
            id: 'ev-1',
            nombre: 'Solemne 1',
            porcentaje: 30,
            nota: 5.5,
          ),
          const Evaluacion(
            id: 'ev-2',
            nombre: 'Solemne 2',
            porcentaje: 70,
          ),
        ],
      );

      // Guardar
      await repo.saveAsignatura(asignatura);

      // Leer
      final recuperada = await repo.getAsignatura('test-ramo-1');
      expect(recuperada, isNotNull);
      expect(recuperada!.nombre, 'Cálculo I');
      expect(recuperada.codigo, 'MAT101');
      expect(recuperada.tieneExamen, true);
      expect(recuperada.evaluaciones.length, 2);
      expect(recuperada.evaluaciones[0].nombre, 'Solemne 1');
      expect(recuperada.evaluaciones[0].nota, 5.5);
      expect(recuperada.evaluaciones[1].nota, isNull);
    });

    test('Actualizar asignatura', () async {
      final asignatura = Asignatura(
        id: 'test-ramo-1',
        nombre: 'Cálculo I',
        evaluaciones: [],
      );
      await repo.saveAsignatura(asignatura);

      // Modificar
      final modificada = asignatura.copyWith(
        nombre: 'Cálculo Avanzado',
        codigo: 'MAT201',
      );
      await repo.saveAsignatura(modificada);

      final recuperada = await repo.getAsignatura('test-ramo-1');
      expect(recuperada, isNotNull);
      expect(recuperada!.nombre, 'Cálculo Avanzado');
      expect(recuperada.codigo, 'MAT201');
    });

    test('Eliminar asignatura', () async {
      final asignatura = Asignatura(
        id: 'test-ramo-delete',
        nombre: 'Química',
        evaluaciones: [],
      );
      await repo.saveAsignatura(asignatura);

      // Verificar que existe
      var recuperada = await repo.getAsignatura('test-ramo-delete');
      expect(recuperada, isNotNull);

      // Eliminar
      await repo.deleteAsignatura('test-ramo-delete');

      // Verificar eliminación
      recuperada = await repo.getAsignatura('test-ramo-delete');
      expect(recuperada, isNull);
    });
  });



  group('Pruebas de Respaldo (Importación/Exportación)', () {
    test('Validación estricta de JSON corrupto e importación exitosa', () async {
      final manager = BackupManager(db);

      // JSON inválido por no tener asignaturas como lista
      const jsonInvalido = '{"version": 1, "usuarios": [], "asignaturas": "no-es-una-lista"}';
      expect(
        () => manager.importarRespaldo(jsonInvalido),
        throwsA(isA<FormatException>()),
      );

      // JSON válido
      final jsonValido = jsonEncode({
        'version': 1,
        'usuarios': [
          {
            'id': 'user-1',
            'nombre': 'Test User',
            'email': 'test@email.com',
          }
        ],
        'asignaturas': [
          {
            'id': 'ramo-1',
            'nombre': 'Física I',
            'evaluaciones': [
              {
                'id': 'ev-1',
                'nombre': 'Control 1',
                'porcentaje': 100,
              }
            ]
          }
        ]
      });

      // Importar respaldo válido
      await manager.importarRespaldo(jsonValido);

      // Verificar que los datos se escribieron en la base de datos local
      final asignatura = await repo.getAsignatura('ramo-1');
      expect(asignatura, isNotNull);
      expect(asignatura!.nombre, 'Física I');
      expect(asignatura.evaluaciones.length, 1);
      expect(asignatura.evaluaciones[0].nombre, 'Control 1');
    });
  });
}

