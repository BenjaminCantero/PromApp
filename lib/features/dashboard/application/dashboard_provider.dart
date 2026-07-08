import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../asignaturas/application/asignatura_providers.dart';
import '../../asignaturas/domain/asignatura.dart';
import '../../calculos/domain/calculo_service.dart';
import '../domain/dashboard_data.dart';

/// Construye los datos del dashboard a partir de las asignaturas.
///
/// Deriva del [asignaturasProvider], así que se recalcula solo cuando cambian
/// los datos. Toda la lógica de agregación vive aquí (la UI queda tonta).
final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final asyncAsignaturas = ref.watch(asignaturasProvider);
  return asyncAsignaturas.whenData(_buildDashboard);
});

DashboardData _buildDashboard(List<Asignatura> asignaturas) {
  // Promedio de cada ramo (final si existe, si no la presentación).
  final promedios = <double>[];
  final rendimientos = <RendimientoAsignatura>[];

  for (final a in asignaturas) {
    final r = CalculoService.calcularAsignatura(a);
    final prom = r.promedioFinal ?? r.promedioPresentacion;
    if (prom != null) promedios.add(prom);
    rendimientos.add(RendimientoAsignatura(nombre: a.nombre, promedio: prom));
  }

  final promedioGeneral = CalculoService.promedioSimple(promedios);

  // Próximas evaluaciones: sin nota, con fecha futura, ordenadas por fecha.
  final proximas = <ProximaEvaluacion>[];
  for (final a in asignaturas) {
    for (final e in a.evaluaciones) {
      if (!e.rendida && e.fecha != null) {
        proximas.add(ProximaEvaluacion(asignatura: a, evaluacion: e));
      }
    }
  }
  proximas.sort((x, y) => x.fecha.compareTo(y.fecha));

  return DashboardData(
    promedioGeneral: promedioGeneral,
    proximasEvaluaciones: proximas.take(4).toList(),
    rendimientos: rendimientos,
  );
}
