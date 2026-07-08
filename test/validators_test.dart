import 'package:flutter_test/flutter_test.dart';
import 'package:promapp/features/asignaturas/domain/evaluacion.dart';
import 'package:promapp/features/calculos/domain/validators.dart';

Evaluacion ev(double pct) =>
    Evaluacion(id: 'x', nombre: 'x', porcentaje: pct);

void main() {
  group('Validators.nota', () {
    test('1.0 y 7.0 son válidas', () {
      expect(Validators.nota(1.0).esValido, isTrue);
      expect(Validators.nota(7.0).esValido, isTrue);
    });
    test('fuera de rango es inválida', () {
      expect(Validators.nota(0.9).esValido, isFalse);
      expect(Validators.nota(7.1).esValido, isFalse);
      expect(Validators.nota(null).esValido, isFalse);
    });
  });

  group('Validators.porcentaje', () {
    test('0 y 100 válidos, fuera de rango inválido', () {
      expect(Validators.porcentaje(0).esValido, isTrue);
      expect(Validators.porcentaje(100).esValido, isTrue);
      expect(Validators.porcentaje(-1).esValido, isFalse);
      expect(Validators.porcentaje(101).esValido, isFalse);
    });
  });

  group('Validators.sumaPorcentajes', () {
    test('suma 100 exacto es válido', () {
      expect(
        Validators.sumaPorcentajes([ev(30), ev(30), ev(40)]).esValido,
        isTrue,
      );
    });
    test('tolerancia ±0.1', () {
      expect(Validators.sumaPorcentajes([ev(99.95)]).esValido, isTrue);
      expect(Validators.sumaPorcentajes([ev(99.5)]).esValido, isFalse);
    });
  });

  group('Validators.pesosExamen', () {
    test('60/40 válido', () {
      expect(Validators.pesosExamen(0.6, 0.4).esValido, isTrue);
    });
    test('no suman 100 → inválido', () {
      expect(Validators.pesosExamen(0.7, 0.4).esValido, isFalse);
    });
    test('peso examen 0 → inválido', () {
      expect(Validators.pesosExamen(1.0, 0.0).esValido, isFalse);
    });
  });
}
