import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/evaluacion.dart';

/// Gráfico de barras "Evolución del Rendimiento" — Diseño Dark Premium.
class EvolucionBarChart extends StatelessWidget {
  const EvolucionBarChart({super.key, required this.evaluaciones});

  final List<Evaluacion> evaluaciones;

  @override
  Widget build(BuildContext context) {
    final rendidas = evaluaciones.where((e) => e.rendida).toList();

    if (rendidas.isEmpty) {
      return SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin notas registradas aún',
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: AppConstants.notaMax,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.8,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: AppTypography.caption,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= rendidas.length) {
                    return const SizedBox.shrink();
                  }
                  final nombre = rendidas[i].nombre;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      nombre.length > 5
                          ? '${nombre.substring(0, 5)}…'
                          : nombre,
                      style: AppTypography.caption,
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: AppConstants.notaAprobacion,
                color: AppColors.reprobado.withValues(alpha: 0.5),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.reprobado,
                  ),
                  labelResolver: (_) => '4.0',
                ),
              ),
            ],
          ),
          barGroups: [
            for (var i = 0; i < rendidas.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: rendidas[i].nota!,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: rendidas[i].nota! >= AppConstants.notaAprobacion
                          ? [AppColors.aprobado, AppColors.aprobadoLight]
                          : [AppColors.reprobado, AppColors.reprobadoLight],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
