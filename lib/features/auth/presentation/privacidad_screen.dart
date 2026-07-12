import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';

/// Política de privacidad visible dentro de la aplicación.
class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Privacidad', style: AppTypography.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          AppDimensions.md,
          AppDimensions.screenPadding,
          AppDimensions.xxl,
        ),
        children: [
          const _Intro(),
          const SizedBox(height: AppDimensions.lg),
          const _Seccion(
            icon: Icons.phone_android_rounded,
            titulo: 'Tus datos permanecen contigo',
            texto:
                'Los ramos, evaluaciones, notas y configuraciones se guardan localmente en tu dispositivo. PromApp no crea cuentas ni envía esta información a servidores propios. El sistema operativo puede incluir datos locales en sus respaldos según tu configuración.',
          ),
          const SizedBox(height: AppDimensions.md),
          const _Seccion(
            icon: Icons.visibility_off_outlined,
            titulo: 'Sin publicidad ni seguimiento',
            texto:
                'PromApp no integra anuncios, analítica, perfiles publicitarios ni tecnologías de seguimiento. Tampoco vende ni comparte tus datos académicos.',
          ),
          const SizedBox(height: AppDimensions.md),
          const _Seccion(
            icon: Icons.import_export_rounded,
            titulo: 'Respaldo bajo tu control',
            texto:
                'La exportación e importación solo ocurre cuando tú la solicitas. El archivo de respaldo queda bajo tu responsabilidad y contiene los datos necesarios para restaurar tus ramos.',
          ),
          const SizedBox(height: AppDimensions.md),
          const _Seccion(
            icon: Icons.delete_outline_rounded,
            titulo: 'Eliminación de datos',
            texto:
                'Puedes borrar permanentemente todos los datos desde Ajustes. Desinstalar la aplicación también elimina la información local, salvo respaldos que hayas guardado fuera de ella.',
          ),
          const SizedBox(height: AppDimensions.md),
          const _Seccion(
            icon: Icons.support_agent_rounded,
            titulo: 'Contacto',
            texto:
                'Para consultas de privacidad utiliza el correo de soporte publicado en la ficha oficial de PromApp en la tienda donde la descargaste.',
          ),
          const SizedBox(height: AppDimensions.lg),
          Center(
            child: Text(
              'Última actualización: 11 de julio de 2026',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.primaryGradient,
      border: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.textOnDark,
            size: 30,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Privacidad simple y transparente',
            style: AppTypography.h2.copyWith(color: AppColors.textOnDark),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'PromApp fue diseñada para funcionar de manera local, sin pedir datos personales innecesarios.',
            style: AppTypography.body.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.icon,
    required this.titulo,
    required this.texto,
  });

  final IconData icon;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTypography.bodyBold),
                const SizedBox(height: 5),
                Text(texto, style: AppTypography.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
