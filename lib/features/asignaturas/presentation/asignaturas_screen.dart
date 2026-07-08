import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../calculos/domain/calculo_service.dart';
import '../../calculos/domain/estado_nota.dart';
import '../application/asignatura_providers.dart';
import '../domain/asignatura.dart';

/// Tab 2: lista de asignaturas del estudiante — diseño premium dark.
class AsignaturasScreen extends ConsumerWidget {
  const AsignaturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(asignaturasProvider);
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (asignaturas) {
          return CustomScrollView(
            slivers: [
              // AppBar personalizado
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    topPad + AppDimensions.lg,
                    AppDimensions.screenPadding,
                    AppDimensions.xl,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MIS RAMOS',
                            style: AppTypography.captionUppercase,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Asignaturas',
                            style: AppTypography.h1,
                          ),
                        ],
                      ),
                      // Botón nuevo
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.asignaturaNueva),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                            vertical: AppDimensions.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                            boxShadow: AppColors.primaryGlow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                color: AppColors.textOnDark,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Nuevo',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.textOnDark,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (asignaturas.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                    onTap: () => context.push(AppRoutes.asignaturaNueva),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding,
                    0,
                    AppDimensions.screenPadding,
                    100,
                  ),
                  sliver: SliverList.separated(
                    itemCount: asignaturas.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.md),
                    itemBuilder: (_, i) =>
                        _AsignaturaCard(asignatura: asignaturas[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Sin asignaturas aún',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Agrega tus ramos para comenzar\na registrar tus notas.',
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xl,
                  vertical: AppDimensions.md,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Text(
                  'Agregar ramo',
                  style: AppTypography.button.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsignaturaCard extends StatelessWidget {
  const _AsignaturaCard({required this.asignatura});
  final Asignatura asignatura;

  @override
  Widget build(BuildContext context) {
    final r = CalculoService.calcularAsignatura(asignatura);
    final prom = r.promedioFinal ?? r.promedioPresentacion;
    final color = _colorEstado(prom);
    final estado = prom == null ? null : EstadoNota.clasificar(prom);

    // Porcentaje evaluado para la mini barra
    final evaluado = r.pesoEvaluado / 100;

    return AppCard(
      onTap: () => context.push(AppRoutes.asignaturaDetalle(asignatura.id)),
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Row(
        children: [
          // Badge de nota circular
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                prom == null ? '—' : prom.toStringAsFixed(1),
                style: AppTypography.bodyBold.copyWith(
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asignatura.nombre,
                  style: AppTypography.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  [asignatura.codigo, asignatura.semestre]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(' · '),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppDimensions.sm),
                // Mini barra de progreso
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusPill),
                        child: Stack(
                          children: [
                            Container(height: 4, color: AppColors.border),
                            FractionallySizedBox(
                              widthFactor: evaluado.clamp(0.0, 1.0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusPill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      '${r.pesoEvaluado.toStringAsFixed(0)}%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          // Estado + flecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (estado != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    estado.label,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: AppDimensions.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorEstado(double? prom) {
    if (prom == null) return AppColors.textMuted;
    return switch (EstadoNota.clasificar(prom)) {
      EstadoNota.aprobado => AppColors.aprobado,
      EstadoNota.examen => AppColors.examen,
      EstadoNota.reprobado => AppColors.reprobado,
    };
  }
}
