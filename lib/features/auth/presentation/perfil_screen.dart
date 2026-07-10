import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/backup_helper.dart';
import '../../../core/utils/backup_manager.dart';
import '../../../core/storage/local_db_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../asignaturas/application/asignatura_providers.dart';

/// Pantalla de Ajustes: administración de datos locales.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Ajustes', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          const SizedBox(height: AppDimensions.md),
          const _Encabezado(),
          const SizedBox(height: AppDimensions.xxl),

          // ── Sección Respaldo y Datos ──
          Text('MANTENIMIENTO DE DATOS', style: AppTypography.captionUppercase),
          const SizedBox(height: AppDimensions.md),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.xs,
            ),
            child: Column(
              children: [
                _BotonAccionData(
                  icon: Icons.download_rounded,
                  label: 'Exportar respaldo',
                  sublabel: 'Descarga tus ramos y notas en JSON',
                  onTap: () => _exportarRespaldo(context, ref),
                ),
                const _Sep(),
                _BotonAccionData(
                  icon: Icons.upload_rounded,
                  label: 'Importar respaldo',
                  sublabel: 'Carga tus datos desde un respaldo JSON',
                  onTap: () => _importarRespaldo(context, ref),
                ),
                const _Sep(),
                _BotonAccionData(
                  icon: Icons.delete_forever_rounded,
                  label: 'Borrar todos los datos',
                  sublabel: 'Elimina tus ramos del dispositivo',
                  color: AppColors.reprobado,
                  onTap: () => _confirmarBorradoCompleto(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  Future<void> _exportarRespaldo(BuildContext context, WidgetRef ref) async {
    try {
      final manager = BackupManager(ref.read(localDbProvider));
      await manager.exportarRespaldo();
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respaldo exportado correctamente (si estás en móvil/escritorio, se copió al portapapeles)'),
          backgroundColor: AppColors.aprobado,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar datos: $e'),
          backgroundColor: AppColors.reprobado,
        ),
      );
    }
  }

  Future<void> _importarRespaldo(BuildContext context, WidgetRef ref) async {
    try {
      final helper = BackupHelperImpl();
      final content = await helper.importar();
      if (content == null || content.isEmpty) return;

      if (!context.mounted) return;
      final manager = BackupManager(ref.read(localDbProvider));
      await manager.importarRespaldo(content);

      // Refrescar el estado de Riverpod para actualizar toda la UI
      ref.invalidate(asignaturasProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Respaldo importado y aplicado correctamente!'),
          backgroundColor: AppColors.aprobado,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fallo en la importación'),
          content: Text('El archivo no pudo ser importado:\n\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _confirmarBorradoCompleto(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar absolutamente todo?'),
        content: const Text(
          'Esta acción eliminará de forma permanente tus ramos y todas tus notas de este dispositivo.\n\nEsta operación no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: AppTypography.bodyBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar definitivamente',
              style: AppTypography.bodyBold.copyWith(color: AppColors.reprobado),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final manager = BackupManager(ref.read(localDbProvider));
      await manager.borrarTodo();
      ref.invalidate(asignaturasProvider);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Botón de Acción de Datos locales
// ─────────────────────────────────────────────────────────────

class _BotonAccionData extends StatelessWidget {
  const _BotonAccionData({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyBold.copyWith(color: color == AppColors.reprobado ? AppColors.reprobado : null)),
                  const SizedBox(height: 2),
                  Text(sublabel, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets auxiliares del perfil
// ─────────────────────────────────────────────────────────────

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppColors.primaryGlow,
          ),
          child: Center(
            child: Icon(Icons.settings_rounded, size: 40, color: AppColors.textOnDark),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        Text('Configuración', style: AppTypography.h2, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text('Administra tus datos locales', style: AppTypography.bodySecondary),
      ],
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1);
}
