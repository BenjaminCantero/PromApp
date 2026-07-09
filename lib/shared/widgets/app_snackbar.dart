import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Feedback breve al usuario (éxito / error) con el estilo de PromApp.
void mostrarError(BuildContext context, String mensaje) =>
    _mostrar(context, mensaje, AppColors.reprobado, Icons.error_outline_rounded);

void mostrarExito(BuildContext context, String mensaje) => _mostrar(
      context,
      mensaje,
      AppColors.aprobado,
      Icons.check_circle_outline_rounded,
    );

void _mostrar(
  BuildContext context,
  String mensaje,
  Color color,
  IconData icono,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icono, color: AppColors.textOnDark, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        margin: const EdgeInsets.all(AppDimensions.screenPadding),
      ),
    );
}
