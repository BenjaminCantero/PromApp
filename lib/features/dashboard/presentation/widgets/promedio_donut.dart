import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Gráfico circular (donut) para el promedio.
///
/// - [progreso]: 0.0–1.0 → porción rellena del anillo.
/// - [valorCentral]: texto grande al centro (ej: "5.9").
/// - [etiqueta]: subtítulo (ej: "Rendimiento Alto").
/// - [lightMode]: si true, textos blancos (sobre fondo oscuro del hero).
class PromedioDonut extends StatelessWidget {
  const PromedioDonut({
    super.key,
    required this.progreso,
    required this.valorCentral,
    required this.etiqueta,
    this.size = 160,
    this.color = AppColors.primary,
    this.lightMode = false,
  });

  final double progreso;
  final String valorCentral;
  final String etiqueta;
  final double size;
  final Color color;
  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    final pct = (progreso.clamp(0, 1) * 100).toDouble();
    final textColor = lightMode ? AppColors.textOnDark : AppColors.textPrimary;
    final subtitleColor = lightMode
        ? AppColors.textOnDark.withValues(alpha: 0.6)
        : AppColors.textSecondary;
    final trackColor = lightMode
        ? AppColors.textOnDark.withValues(alpha: 0.15)
        : AppColors.border;

    // Gradiente como arco de colores en el pie chart
    final gradientColor = color;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow detrás del donut
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size / 2 - AppDimensions.chartStroke,
              sections: [
                PieChartSectionData(
                  value: pct,
                  color: gradientColor,
                  radius: AppDimensions.chartStroke,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 100 - pct,
                  color: trackColor,
                  radius: AppDimensions.chartStroke,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Padding(
            // Mantiene el texto dentro del anillo y evita desbordes con
            // valores largos (ej: "Eximido", "Imposible").
            padding: EdgeInsets.symmetric(horizontal: size * 0.14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    valorCentral,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.display.copyWith(color: textColor),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: subtitleColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
