import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry.dart';

import '../../calculos/domain/calculo_service.dart';
import '../application/dashboard_provider.dart';
import '../domain/dashboard_data.dart';
import 'widgets/promedio_donut.dart';
import 'widgets/proxima_evaluacion_tile.dart';
import 'widgets/rendimiento_bar.dart';

/// Pantalla Inicio (Dashboard) — Diseño Premium Dark.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => ErrorRetry(
          error: e,
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar con hero gradient
        _HeroSliverAppBar(data: data),

        // Contenido principal
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.xl,
            AppDimensions.screenPadding,
            100, // espacio para bottom nav flotante
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _AccionesRow(),
              const SizedBox(height: AppDimensions.xxl),
              _ObjetivosCard(objetivos: data.objetivos),
              const SizedBox(height: AppDimensions.xxl),
              _ProximasEvaluacionesCard(items: data.proximasEvaluaciones),
              const SizedBox(height: AppDimensions.xxl),
              _RendimientoCard(rendimientos: data.rendimientos),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ObjetivosCard extends StatelessWidget {
  const _ObjetivosCard({required this.objetivos});

  final List<ObjetivoAsignatura> objetivos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('MODO OBJETIVO', style: AppTypography.captionUppercase),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                'META 4.0',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(_mensajeGeneral, style: AppTypography.bodySecondary),
        const SizedBox(height: AppDimensions.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: objetivos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Center(
                    child: Text(
                      'Agrega un ramo para comenzar tu objetivo.',
                      style: AppTypography.bodySecondary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < objetivos.length; i++) ...[
                      _ObjetivoTile(objetivo: objetivos[i]),
                      if (i < objetivos.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  String get _mensajeGeneral {
    if (objetivos.isEmpty) {
      return 'Te mostraremos qué notas necesitas para aprobar.';
    }
    final enRiesgo = objetivos.where((o) => o.imposible).length;
    final encaminados = objetivos
        .where((o) => o.asegurado || (o.completado && o.aprobado))
        .length;
    if (enRiesgo > 0) {
      return 'Atención: $enRiesgo ${enRiesgo == 1 ? 'ramo necesita' : 'ramos necesitan'} un plan de recuperación.';
    }
    if (encaminados == objetivos.length) {
      return 'Vas muy bien: todas tus metas están encaminadas.';
    }
    return 'Estas son las notas promedio que necesitas en lo pendiente.';
  }
}

class _ObjetivoTile extends StatelessWidget {
  const _ObjetivoTile({required this.objetivo});

  final ObjetivoAsignatura objetivo;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return InkWell(
      onTap: () =>
          context.push(AppRoutes.asignaturaDetalle(objetivo.asignatura.id)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(_icono, color: color, size: 21),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objetivo.asignatura.nombre,
                    style: AppTypography.bodyBold,
                  ),
                  const SizedBox(height: 3),
                  Text(_detalle, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_valor, style: AppTypography.h3.copyWith(color: color)),
                Text(
                  _estado,
                  style: AppTypography.caption.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _color {
    if (objetivo.completado) {
      return objetivo.aprobado ? AppColors.aprobado : AppColors.reprobado;
    }
    if (objetivo.imposible) return AppColors.reprobado;
    final necesaria = objetivo.notaNecesaria;
    if (necesaria == null || necesaria <= 4.0) return AppColors.aprobado;
    if (necesaria <= 5.5) return AppColors.examen;
    return AppColors.reprobado;
  }

  IconData get _icono {
    if (objetivo.completado) {
      return objetivo.aprobado
          ? Icons.check_circle_rounded
          : Icons.cancel_rounded;
    }
    if (objetivo.imposible) return Icons.warning_rounded;
    return Icons.flag_rounded;
  }

  String get _valor {
    if (objetivo.completado) {
      return objetivo.promedioActual == null
          ? '—'
          : CalculoService.formatearPromedioOficial(objetivo.promedioActual!);
    }
    if (objetivo.imposible) return '> 7.0';
    if (objetivo.asegurado) return '✓';
    return objetivo.notaNecesaria == null
        ? '—'
        : CalculoService.formatearPromedioOficial(objetivo.notaNecesaria!);
  }

  String get _estado {
    if (objetivo.completado) {
      return objetivo.aprobado ? 'Aprobado' : 'Reprobado';
    }
    if (objetivo.imposible) return 'En riesgo';
    if (objetivo.asegurado) return 'Encaminado';
    return 'Necesitas';
  }

  String get _detalle {
    if (objetivo.completado) return 'Todas las evaluaciones están registradas';
    final pendiente = objetivo.pesoPendiente.clamp(0, 100).toStringAsFixed(0);
    if (objetivo.imposible) {
      return 'La meta requiere revisar tus próximos escenarios';
    }
    if (objetivo.asegurado) {
      return 'La aprobación está asegurada con el $pendiente% restante';
    }
    return 'Promedio requerido en el $pendiente% restante';
  }
}

// --- Hero SliverAppBar con gradiente y donut centrado ---
class _HeroSliverAppBar extends StatelessWidget {
  const _HeroSliverAppBar({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final prom = data.promedioGeneral;
    final topPad = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            // Círculo decorativo de fondo
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                topPad + AppDimensions.lg,
                AppDimensions.screenPadding,
                AppDimensions.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido 👋',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mi Rendimiento',
                            style: AppTypography.h2.copyWith(
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                      // Avatar → abre Perfil (ahora Ajustes)
                      GestureDetector(
                        key: const Key('perfil-avatar'),
                        onTap: () => context.push(AppRoutes.perfil),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.primaryGlow,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.settings_rounded,
                              color: AppColors.textOnDark,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xxl),

                  // Donut centrado + stats
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Donut grande
                      PromedioDonut(
                        progreso: data.progresoGeneral,
                        valorCentral: prom == null
                            ? '—'
                            : CalculoService.formatearPromedio(prom),
                        etiqueta: data.rendimientoLabel,
                        size: 148,
                        lightMode: true,
                      ),
                      const SizedBox(width: AppDimensions.xxl),

                      // Stats a la derecha
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroStat(
                              label: 'Ramos activos',
                              valor: '${data.rendimientos.length}',
                              icon: Icons.menu_book_rounded,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _HeroStat(
                              label: 'Aprobados',
                              valor:
                                  '${data.rendimientos.where((r) => r.aprobado).length}',
                              icon: Icons.check_circle_rounded,
                              color: AppColors.aprobado,
                            ),
                            const SizedBox(height: AppDimensions.md),
                            _HeroStat(
                              label: 'En riesgo',
                              valor:
                                  '${data.rendimientos.where((r) => r.enRiesgo).length}',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.reprobado,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.valor,
    required this.icon,
    this.color,
  });

  final String label;
  final String valor;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryLight;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, size: 14, color: c),
        ),
        const SizedBox(width: AppDimensions.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: AppTypography.h3.copyWith(
                color: AppColors.textOnDark,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Row: acciones rápidas ---
class _AccionesRow extends StatelessWidget {
  const _AccionesRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACCIONES RÁPIDAS', style: AppTypography.captionUppercase),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: _AccionCard(
                icon: Icons.edit_note_rounded,
                titulo: 'Nueva Nota',
                subtitulo: 'Registrar evaluación',
                gradient: AppColors.primaryGradient,
                glowColor: AppColors.primary,
                onTap: () => context.go(AppRoutes.asignaturas),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: _AccionCard(
                icon: Icons.library_add_rounded,
                titulo: 'Nuevo Ramo',
                subtitulo: 'Agregar asignatura',
                onTap: () => context.push(AppRoutes.asignaturaNueva),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccionCard extends StatelessWidget {
  const _AccionCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.gradient,
    this.glowColor,
  });

  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final hasPrimary = gradient != null;
    final fgColor = hasPrimary ? AppColors.textOnDark : AppColors.textPrimary;

    return AppCard(
      onTap: onTap,
      gradient: gradient,
      color: hasPrimary ? null : AppColors.surfaceAlt,
      border: !hasPrimary,
      glowColor: glowColor,
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm + 2),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(titulo, style: AppTypography.h3.copyWith(color: fgColor)),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            style: AppTypography.caption.copyWith(
              color: hasPrimary
                  ? fgColor.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Card: Próximas evaluaciones ---
class _ProximasEvaluacionesCard extends StatelessWidget {
  const _ProximasEvaluacionesCard({required this.items});
  final List items;

  static const _colores = [
    (AppColors.accentRed, AppColors.badgeRedBg),
    (AppColors.accentBlue, AppColors.badgeBlueBg),
    (AppColors.accentPurple, AppColors.badgePurpleBg),
    (AppColors.accentTeal, AppColors.badgeBlueBg),
    (AppColors.accentAmber, AppColors.badgePurpleBg),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Próximas Evaluaciones',
          icon: Icons.calendar_month_rounded,
        ),
        const SizedBox(height: AppDimensions.md),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.sm,
          ),
          child: Column(
            children: [
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.aprobado,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        'Sin evaluaciones próximas',
                        style: AppTypography.bodySecondary,
                      ),
                    ],
                  ),
                )
              else
                for (var i = 0; i < items.length; i++) ...[
                  ProximaEvaluacionTile(
                    item: items[i],
                    color: _colores[i % _colores.length].$1,
                    badgeBg: _colores[i % _colores.length].$2,
                  ),
                  if (i < items.length - 1)
                    Divider(color: AppColors.border, height: 1),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

// --- Card: Rendimiento por asignatura ---
class _RendimientoCard extends StatelessWidget {
  const _RendimientoCard({required this.rendimientos});
  final List rendimientos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Rendimiento por Ramo',
          icon: Icons.bar_chart_rounded,
        ),
        const SizedBox(height: AppDimensions.md),
        AppCard(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              for (final r in rendimientos) RendimientoBar(rendimiento: r),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Header de sección reutilizable ---
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.titulo, required this.icon});
  final String titulo;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.xs + 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm - 2),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.sm),
        Text(titulo, style: AppTypography.h3),
      ],
    );
  }
}
