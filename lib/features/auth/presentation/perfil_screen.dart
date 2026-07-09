import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../application/auth_controller.dart';
import '../domain/auth_user.dart';

/// Pantalla de Perfil: datos de la cuenta + cerrar sesión.
///
/// Al cerrar sesión, `AuthController` limpia el token y el `AuthGate`
/// (app.dart) vuelve automáticamente a la pantalla de acceso.
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
        title: Text('Perfil', style: AppTypography.h3),
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
                        icon: Icons.mail_outline,
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
                _BotonCerrarSesion(
                  onConfirmar: () => _cerrarSesion(context, ref),
                ),
              ],
            ),
    );
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
              style: AppTypography.bodyBold
                  .copyWith(color: AppColors.textSecondary),
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
      // El AuthGate detecta la sesión nula y muestra el login solo.
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

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
        Text(
          user.nombre,
          style: AppTypography.h2,
          textAlign: TextAlign.center,
        ),
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
