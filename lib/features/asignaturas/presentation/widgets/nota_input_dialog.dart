import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../calculos/domain/validators.dart';

/// Resultado del diálogo de nota.
class NotaDialogResult {
  const NotaDialogResult(this.nota);

  /// `null` = el usuario pidió borrar la nota.
  final double? nota;
}

/// Diálogo premium para ingresar / editar / borrar una nota (1.0–7.0).
Future<NotaDialogResult?> showNotaDialog(
  BuildContext context, {
  required String titulo,
  double? notaActual,
}) {
  final controller = TextEditingController(
    text: notaActual?.toString() ?? '',
  );
  String? errorText;

  return showDialog<NotaDialogResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(titulo, style: AppTypography.h3),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.h2.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '5.5',
                    errorText: errorText,
                    suffixText: '/ 7.0',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              if (notaActual != null)
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, const NotaDialogResult(null)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.reprobado,
                  ),
                  child: const Text('Borrar'),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final valor = double.tryParse(
                    controller.text.replaceAll(',', '.'),
                  );
                  final validacion = Validators.nota(valor);
                  if (!validacion.esValido) {
                    setState(() => errorText = validacion.error);
                    return;
                  }
                  Navigator.pop(context, NotaDialogResult(valor));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
