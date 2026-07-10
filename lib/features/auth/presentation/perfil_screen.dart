import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/backup_helper.dart';
import '../../../core/utils/backup_manager.dart';
import '../../../shared/widgets/app_card.dart';
import '../../asignaturas/application/asignatura_providers.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

/// Pantalla de Perfil: datos de la cuenta + cambio de contraseña + administración de datos locales + cerrar sesión.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Mi Perfil', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                const SizedBox(height: AppDimensions.md),
                _Encabezado(user: user),
                const SizedBox(height: AppDimensions.xxl),

                // ── Sección Cuenta ──
                Text('CUENTA', style: AppTypography.captionUppercase),
                const SizedBox(height: AppDimensions.md),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: AppDimensions.xs,
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Nombre',
                        valor: user.nombre,
                      ),
                      const _Sep(),
                      _InfoRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Correo',
                        valor: user.email,
                      ),
                      if (user.carrera != null && user.carrera!.isNotEmpty) ...[
                        const _Sep(),
                        _InfoRow(
                          icon: Icons.school_outlined,
                          label: 'Carrera',
                          valor: user.carrera!,
                        ),
                      ],
                      if (user.universidad != null &&
                          user.universidad!.isNotEmpty) ...[
                        const _Sep(),
                        _InfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'Universidad',
                          valor: user.universidad!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),

                // ── Sección Seguridad ──
                Text('SEGURIDAD', style: AppTypography.captionUppercase),
                const SizedBox(height: AppDimensions.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => _abrirCambioPassword(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.md + 2,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cambiar contraseña',
                                  style: AppTypography.bodyBold),
                              Text(
                                'Actualiza tu contraseña actual',
                                style: AppTypography.caption,
                              ),
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
                ),
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
                        sublabel: 'Elimina tu cuenta y ramos del dispositivo',
                        color: AppColors.reprobado,
                        onTap: () => _confirmarBorradoCompleto(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),

                // ── Cerrar sesión ──
                _BotonCerrarSesion(
                  onConfirmar: () => _cerrarSesion(context, ref),
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
    );
  }

  void _abrirCambioPassword(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CambiarPasswordSheet(ref: ref),
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
      ref.invalidate(authControllerProvider);
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
          'Esta acción eliminará de forma permanente tu usuario, ramos y todas tus notas de este dispositivo.\n\nEsta operación no se puede deshacer.',
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
      
      // Cerrar sesión y forzar recarga
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión', style: AppTypography.h3),
        content: Text(
          '¿Seguro que quieres salir de tu cuenta?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style:
                  AppTypography.bodyBold.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cerrar sesión',
              style: AppTypography.bodyBold.copyWith(color: AppColors.reprobado),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Sheet: Cambiar Contraseña
// ─────────────────────────────────────────────────────────────

class _CambiarPasswordSheet extends StatefulWidget {
  const _CambiarPasswordSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CambiarPasswordSheet> createState() => _CambiarPasswordSheetState();
}

class _CambiarPasswordSheetState extends State<_CambiarPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _verActual = false;
  bool _verNueva = false;
  bool _verConfirmar = false;
  bool _cargando = false;
  String? _error;
  bool _exito = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await widget.ref.read(authControllerProvider.notifier).cambiarPassword(
            passwordActual: _actualCtrl.text,
            passwordNueva: _nuevaCtrl.text,
          );
      if (!mounted) return;
      setState(() => _exito = true);
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.lg,
        AppDimensions.screenPadding,
        botPad + AppDimensions.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Text('Cambiar contraseña', style: AppTypography.h3),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
            if (_exito)
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.aprobado.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                      color: AppColors.aprobado.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.aprobado, size: 22),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        '¡Contraseña actualizada correctamente!',
                        style: AppTypography.bodyBold
                            .copyWith(color: AppColors.aprobado),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _CampoPassword(
                controller: _actualCtrl,
                label: 'Contraseña actual',
                visible: _verActual,
                onToggle: () => setState(() => _verActual = !_verActual),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Ingresa tu contraseña actual'
                    : null,
              ),
              const SizedBox(height: AppDimensions.md),
              _CampoPassword(
                controller: _nuevaCtrl,
                label: 'Nueva contraseña',
                visible: _verNueva,
                onToggle: () => setState(() => _verNueva = !_verNueva),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  if (v == _actualCtrl.text) {
                    return 'Debe ser distinta a la contraseña actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.md),
              _CampoPassword(
                controller: _confirmarCtrl,
                label: 'Confirmar nueva contraseña',
                visible: _verConfirmar,
                onToggle: () => setState(() => _verConfirmar = !_verConfirmar),
                validator: (v) => v != _nuevaCtrl.text
                    ? 'Las contraseñas no coinciden'
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.badgeRedBg,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.reprobado, size: 18),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.body
                              .copyWith(color: AppColors.reprobadoLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _cargando ? null : AppColors.primaryGradient,
                    color: _cargando ? AppColors.border : null,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    boxShadow: _cargando ? null : AppColors.primaryGlow,
                  ),
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(
                            'Actualizar contraseña',
                            style: AppTypography.button
                                .copyWith(color: AppColors.textOnPrimary),
                          ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
// Widget: Campo contraseña con toggle de visibilidad
// ─────────────────────────────────────────────────────────────

class _CampoPassword extends StatelessWidget {
  const _CampoPassword({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      style: AppTypography.body,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textMuted, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.reprobado),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.reprobado, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets auxiliares del perfil
// ─────────────────────────────────────────────────────────────

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.user});
  final AuthUser user;

  String get _iniciales {
    final partes =
        user.nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

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
            child: Text(
              _iniciales,
              style: AppTypography.h1.copyWith(color: AppColors.textOnDark),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        Text(user.nombre, style: AppTypography.h2, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(user.email, style: AppTypography.bodySecondary),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(valor, style: AppTypography.bodyBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1);
}

class _BotonCerrarSesion extends StatelessWidget {
  const _BotonCerrarSesion({required this.onConfirmar});
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onConfirmar,
        icon: const Icon(Icons.logout_rounded,
            size: 18, color: AppColors.reprobado),
        label: Text(
          'Cerrar sesión',
          style: AppTypography.button.copyWith(color: AppColors.reprobado),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.reprobado),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}
