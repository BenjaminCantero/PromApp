import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/features/asignaturas/domain/asignatura.dart';
import 'package:promapp/features/asignaturas/domain/evaluacion.dart';
import 'package:promapp/features/calculos/domain/calculo_service.dart';
import 'package:promapp/features/calculos/domain/estado_nota.dart';

/// Helper para crear evaluaciones rápido.
Evaluacion ev(String id, double pct, [double? nota]) =>
    Evaluacion(id: id, nombre: id, porcentaje: pct, nota: nota);

void main() {
  group('promedioSimple', () {
    test('promedia una lista de notas', () {
      expect(CalculoService.promedioSimple([5.0, 6.0, 7.0]), 6.0);
    });
    test('lista vacía → null', () {
      expect(CalculoService.promedioSimple([]), isNull);
    });
  });

  group('promedioPonderado', () {
    test('pondera sobre lo rendido (todas rendidas, suman 100)', () {
      final evals = [ev('a', 40, 6.0), ev('b', 60, 5.0)];
      // 6*40 + 5*60 = 240 + 300 = 540 / 100 = 5.4
      expect(CalculoService.promedioPonderado(evals), closeTo(5.4, 1e-9));
    });

    test('normaliza cuando faltan evaluaciones por rendir', () {
      final evals = [ev('a', 30, 6.0), ev('b', 70)]; // solo 'a' rendida
      // 6*30 / 30 = 6.0
      expect(CalculoService.promedioPonderado(evals), closeTo(6.0, 1e-9));
    });

    test('sin notas → null', () {
      expect(CalculoService.promedioPonderado([ev('a', 100)]), isNull);
    });
  });

  group('notaNecesariaRestante', () {
    test('calcula la nota promedio requerida en lo que falta', () {
      final evals = [ev('a', 50, 4.0), ev('b', 50)]; // falta 50%
      // contribución = 4*50/100 = 2.0 ; pendiente = 0.5
      // (5.0 - 2.0) / 0.5 = 6.0
      final r = CalculoService.notaNecesariaRestante(
        objetivo: 5.0,
        evaluaciones: evals,
      );
      expect(r, closeTo(6.0, 1e-9));
    });

    test('sin peso pendiente → null', () {
      final evals = [ev('a', 100, 5.0)];
      expect(
        CalculoService.notaNecesariaRestante(objetivo: 6.0, evaluaciones: evals),
        isNull,
      );
    });

    test('objetivo inalcanzable devuelve valor > 7 (UI decide "imposible")', () {
      final evals = [ev('a', 80, 3.0), ev('b', 20)];
      // contribución = 3*80/100 = 2.4 ; pendiente = 0.2
      // (4.0 - 2.4)/0.2 = 8.0  → > 7.0
      final r = CalculoService.notaNecesariaRestante(
        objetivo: 4.0,
        evaluaciones: evals,
      );
      expect(r, closeTo(8.0, 1e-9));
      expect(r! > 7.0, isTrue);
    });
  });

  group('notaNecesariaExamen', () {
    test('60/40 presentación 5.0 objetivo 4.0', () {
      // (4.0 - 5.0*0.6) / 0.4 = (4.0 - 3.0)/0.4 = 2.5
      final r = CalculoService.notaNecesariaExamen(
        objetivo: 4.0,
        presentacion: 5.0,
        pesoPresentacion: 0.6,
        pesoExamen: 0.4,
      );
      expect(r, closeTo(2.5, 1e-9));
    });
  });

  group('calcularAsignatura', () {
    test('ramo sin examen → final = presentación', () {
      final a = Asignatura(
        id: '1',
        nombre: 'Historia',
        evaluaciones: [ev('a', 50, 6.0), ev('b', 50, 4.0)],
      );
      final r = CalculoService.calcularAsignatura(a);
      expect(r.promedioFinal, closeTo(5.0, 1e-9));
      expect(r.estado, EstadoNota.aprobado);
      expect(r.pesoEvaluado, 100);
      expect(r.pesoPendiente, 0);
    });

    test('ramo con examen rendido → ponderación 60/40', () {
      final a = Asignatura(
        id: '2',
        nombre: 'Cálculo',
        evaluaciones: [ev('a', 100, 5.0)],
        tieneExamen: true,
        pesoPresentacion: 0.6,
        pesoExamen: 0.4,
        notaExamen: 6.0,
      );
      final r = CalculoService.calcularAsignatura(a);
      // 5.0*0.6 + 6.0*0.4 = 3.0 + 2.4 = 5.4
      expect(r.promedioFinal, closeTo(5.4, 1e-9));
      expect(r.estado, EstadoNota.aprobado);
    });

    test('ramo con examen pero eximido → final = presentación', () {
      final a = Asignatura(
        id: '3',
        nombre: 'Física',
        evaluaciones: [ev('a', 100, 6.0)],
        tieneExamen: true,
        notaEximir: 5.5,
      );
      final r = CalculoService.calcularAsignatura(a);
      expect(r.eximido, isTrue);
      expect(r.promedioFinal, closeTo(6.0, 1e-9));
    });

    test('ramo con examen sin rendir → final null', () {
      final a = Asignatura(
        id: '4',
        nombre: 'Química',
        evaluaciones: [ev('a', 100, 4.5)],
        tieneExamen: true,
        notaEximir: 5.5, // no alcanza a eximirse
      );
      final r = CalculoService.calcularAsignatura(a);
      expect(r.eximido, isFalse);
      expect(r.promedioFinal, isNull);
      expect(r.estado, isNull);
    });
  });

  group('EstadoNota.clasificar', () {
    test('4.0 → aprobado', () {
      expect(EstadoNota.clasificar(4.0), EstadoNota.aprobado);
    });
    test('3.7 → examen', () {
      expect(EstadoNota.clasificar(3.7), EstadoNota.examen);
    });
    test('3.4 → reprobado', () {
      expect(EstadoNota.clasificar(3.4), EstadoNota.reprobado);
    });
  });
}
