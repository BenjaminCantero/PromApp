import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/dashboard_data.dart';

/// Fila "Rendimiento por Asignatura" — barra animada con gradiente.
class RendimientoBar extends StatelessWidget {
  const RendimientoBar({super.key, required this.rendimiento});

  final RendimientoAsignatura rendimiento;

  @override
  Widget build(BuildContext context) {
    final prom = rendimiento.promedio;

    // Color y gradiente según nota
    final Color color;
    final List<Color> gradColors;
    if (prom == null) {
      color = AppColors.textMuted;
      gradColors = [AppColors.textMuted, AppColors.textMuted];
    } else if (prom >= 5.5) {
      color = AppColors.aprobado;
      gradColors = [AppColors.aprobado, AppColors.aprobadoLight];
    } else if (prom >= 4.0) {
      color = AppColors.primary;
      gradColors = [AppColors.primary, AppColors.primaryLight];
    } else {
      color = AppColors.reprobado;
      gradColors = [AppColors.reprobado, AppColors.reprobadoLight];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rendimiento.nombre,
                  style: AppTypography.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              // Badge de nota
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  prom == null ? '—' : prom.toStringAsFixed(1),
                  style: AppTypography.bodyBold.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm - 2),
          // Barra de progreso con gradiente
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: Stack(
              children: [
                // Track
                Container(
                  height: 6,
                  width: double.infinity,
                  color: AppColors.border,
                ),
                // Fill con gradiente
                FractionallySizedBox(
                  widthFactor: rendimiento.progreso.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
