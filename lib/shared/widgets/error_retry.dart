import 'package:flutter/material.dart';

import '../../core/network/error_messages.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

/// Estado de error reutilizable con botón "Reintentar".
///
/// Muestra un mensaje amable (sin volcar el stack trace) y deja al usuario
/// reintentar la carga — útil cuando la API está caída o la sesión expiró.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry, this.error});

  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.badgeRedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.reprobado,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'No pudimos cargar los datos',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              mensajeDeError(error),
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
