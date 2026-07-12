import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/error_retry.dart';
import '../../calculos/domain/calculo_service.dart';
import '../../calculos/domain/estado_nota.dart';
import '../../dashboard/presentation/widgets/promedio_donut.dart';
import '../application/asignatura_providers.dart';
import '../application/asignaturas_controller.dart';
import '../domain/asignatura.dart';
import '../domain/evaluacion.dart';
import 'widgets/evolucion_bar_chart.dart';
import 'widgets/nota_input_dialog.dart';

/// Pantalla detalle de una asignatura — Diseño Premium Dark.
class AsignaturaDetalleScreen extends ConsumerStatefulWidget {
  const AsignaturaDetalleScreen({super.key, required this.asignaturaId});

  final String asignaturaId;

  @override
  ConsumerState<AsignaturaDetalleScreen> createState() =>
      _AsignaturaDetalleScreenState();
}

class _AsignaturaDetalleScreenState
    extends ConsumerState<AsignaturaDetalleScreen> {
  double _notaDeseada = 5.5;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(asignaturaProvider(widget.asignaturaId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => ErrorRetry(
          error: e,
          onRetry: () =>
              ref.invalidate(asignaturaProvider(widget.asignaturaId)),
        ),
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Asignatura no encontrada'));
          }
          return _Body(
            asignatura: a,
            notaDeseada: _notaDeseada,
            onNotaDeseadaChanged: (v) => setState(() => _notaDeseada = v),
            onEditarNota: (e) => _editarNota(a, e),
            onEditarExamen: () => _editarExamen(a),
            onEditar: () =>
                context.push(AppRoutes.asignaturaEditar(widget.asignaturaId)),
          );
        },
      ),
    );
  }

  Future<void> _editarNota(Asignatura a, Evaluacion e) async {
    final res = await showNotaDialog(
      context,
      titulo: e.nombre,
      notaActual: e.nota,
    );
    if (res == null) return;
    await _guardarNota(
      () => ref
          .read(asignaturasControllerProvider.notifier)
          .setNotaEvaluacion(a, e.id, res.nota),
    );
  }

  Future<void> _editarExamen(Asignatura a) async {
    final res = await showNotaDialog(
      context,
      titulo: 'Nota del Examen',
      notaActual: a.notaExamen,
    );
    if (res == null) return;
    await _guardarNota(
      () => ref
          .read(asignaturasControllerProvider.notifier)
          .setNotaExamen(a, res.nota),
    );
  }

  /// Guarda una nota avisando al usuario si la API falla (antes fallaba
  /// en silencio y parecía que la nota había quedado registrada).
  Future<void> _guardarNota(Future<void> Function() accion) async {
    try {
      await accion();
      if (mounted) mostrarExito(context, 'Nota guardada');
    } catch (e) {
      if (mounted) mostrarError(context, mensajeDeError(e));
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.asignatura,
    required this.notaDeseada,
    required this.onNotaDeseadaChanged,
    required this.onEditarNota,
    required this.onEditarExamen,
    required this.onEditar,
  });

  final Asignatura asignatura;
  final double notaDeseada;
  final ValueChanged<double> onNotaDeseadaChanged;
  final void Function(Evaluacion) onEditarNota;
  final VoidCallback onEditarExamen;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final r = CalculoService.calcularAsignatura(asignatura);
    final topPad = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      slivers: [
        // Header con gradiente y donut
        SliverToBoxAdapter(
          child: _DetalleHeader(
            asignatura: asignatura,
            resultado: r,
            topPad: topPad,
            onEditar: onEditar,
          ),
        ),

        // Contenido
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.xl,
            AppDimensions.screenPadding,
            100,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _DesgloseCard(
                asignatura: asignatura,
                resultado: r,
                onEditarNota: onEditarNota,
                onEditarExamen: onEditarExamen,
              ),
              const SizedBox(height: AppDimensions.xl),
              _CalculadoraCard(
                asignatura: asignatura,
                resultado: r,
                notaDeseada: notaDeseada,
                onNotaDeseadaChanged: onNotaDeseadaChanged,
              ),
              const SizedBox(height: AppDimensions.xl),
              _EvolucionCard(evaluaciones: asignatura.evaluaciones),
            ]),
          ),
        ),
      ],
    );
  }
}

// --- Header del detalle ---
class _DetalleHeader extends StatelessWidget {
  const _DetalleHeader({
    required this.asignatura,
    required this.resultado,
    required this.topPad,
    required this.onEditar,
  });

  final Asignatura asignatura;
  final ResultadoAsignatura resultado;
  final double topPad;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final prom = resultado.promedioFinal ?? resultado.promedioPresentacion;
    final estado = prom == null
        ? null
        : EstadoNota.clasificar(CalculoService.promedioOficial(prom));

    final Color donutColor = switch (estado) {
      EstadoNota.aprobado => AppColors.aprobado,
      EstadoNota.examen => AppColors.examen,
      EstadoNota.reprobado => AppColors.reprobado,
      null => AppColors.primary,
    };

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        topPad + AppDimensions.sm,
        AppDimensions.screenPadding,
        AppDimensions.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones back + editar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textOnDark,
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.textOnDark.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(AppDimensions.sm),
                ),
              ),
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Editar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryLight,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Nombre
          Text(
            asignatura.nombre,
            style: AppTypography.h1.copyWith(color: AppColors.textOnDark),
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          if (asignatura.codigo != null || asignatura.semestre != null)
            Text(
              [
                asignatura.codigo,
                asignatura.semestre,
              ].where((s) => s != null && s.isNotEmpty).join(' · '),
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.textOnDark.withValues(alpha: 0.6),
              ),
            ),

          const SizedBox(height: AppDimensions.xl),

          // Donut + mini stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PromedioDonut(
                progreso: prom == null ? 0 : prom / AppConstants.notaMax,
                valorCentral: prom == null
                    ? '—'
                    : CalculoService.formatearPromedio(prom),
                etiqueta: prom == null
                    ? (resultado.promedioFinal != null
                          ? 'Final'
                          : 'Presentación')
                    : '${resultado.promedioFinal != null ? 'Final' : 'Presentación'} ${CalculoService.formatearPromedioOficial(prom)}',
                size: 130,
                color: donutColor,
                lightMode: true,
              ),
              const SizedBox(width: AppDimensions.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniStatHero(
                      label: 'Estado',
                      valor: estado?.label ?? 'Sin notas',
                      color: donutColor,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _MiniStatHero(
                      label: 'Evaluado',
                      valor: '${resultado.pesoEvaluado.toStringAsFixed(0)}%',
                    ),
                    const SizedBox(height: AppDimensions.md),
                    _MiniStatHero(
                      label: 'Pendiente',
                      valor: '${resultado.pesoPendiente.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatHero extends StatelessWidget {
  const _MiniStatHero({required this.label, required this.valor, this.color});
  final String label;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: AppTypography.h3.copyWith(
            color: color ?? AppColors.textOnDark,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// --- Card: Desglose de evaluaciones ---
class _DesgloseCard extends StatelessWidget {
  const _DesgloseCard({
    required this.asignatura,
    required this.resultado,
    required this.onEditarNota,
    required this.onEditarExamen,
  });

  final Asignatura asignatura;
  final ResultadoAsignatura resultado;
  final void Function(Evaluacion) onEditarNota;
  final VoidCallback onEditarExamen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.list_alt_rounded,
            texto: 'Desglose de Evaluaciones',
          ),
          const SizedBox(height: AppDimensions.md),
          // Encabezado de columnas
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Evaluación',
                    style: AppTypography.captionUppercase,
                  ),
                ),
                Expanded(
                  child: Text(
                    '%',
                    style: AppTypography.captionUppercase,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Nota',
                    style: AppTypography.captionUppercase,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: AppDimensions.md),
          for (final e in asignatura.evaluaciones)
            _FilaEvaluacion(evaluacion: e, onTap: () => onEditarNota(e)),
          if (asignatura.tieneExamen) ...[
            Divider(color: AppColors.border, height: AppDimensions.xl),
            _FilaExamen(
              nota: asignatura.notaExamen,
              peso: asignatura.pesoExamen,
              eximido: resultado.eximido,
              onTap: onEditarExamen,
            ),
          ],
          Divider(color: AppColors.border, height: AppDimensions.xl),
          Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Toca una fila para registrar su nota',
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaEvaluacion extends StatelessWidget {
  const _FilaEvaluacion({required this.evaluacion, required this.onTap});
  final Evaluacion evaluacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nota = evaluacion.nota;
    final color = nota == null
        ? AppColors.textMuted
        : (nota >= AppConstants.notaAprobacion
              ? AppColors.aprobado
              : AppColors.reprobado);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm + 2),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evaluacion.nombre, style: AppTypography.body),
                  if (evaluacion.tipo != null)
                    Text(
                      evaluacion.tipo!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${evaluacion.porcentaje.toStringAsFixed(0)}%',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 56,
              child: nota == null
                  ? Center(
                      child: Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      nota.toStringAsFixed(1),
                      style: AppTypography.bodyBold.copyWith(color: color),
                      textAlign: TextAlign.right,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaExamen extends StatelessWidget {
  const _FilaExamen({
    required this.nota,
    required this.peso,
    required this.eximido,
    required this.onTap,
  });
  final double? nota;
  final double peso;
  final bool eximido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: eximido ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm + 2),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.examen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm - 2,
                      ),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      size: 14,
                      color: AppColors.examen,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text('Examen Final', style: AppTypography.bodyBold),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${(peso * 100).toStringAsFixed(0)}%',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                eximido ? 'Eximido' : (nota?.toStringAsFixed(1) ?? '—'),
                style: AppTypography.bodyBold.copyWith(
                  color: eximido ? AppColors.aprobado : AppColors.examen,
                  fontSize: eximido ? 10 : 14,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Card: Calculadora ---
class _CalculadoraCard extends StatelessWidget {
  const _CalculadoraCard({
    required this.asignatura,
    required this.resultado,
    required this.notaDeseada,
    required this.onNotaDeseadaChanged,
  });

  final Asignatura asignatura;
  final ResultadoAsignatura resultado;
  final double notaDeseada;
  final ValueChanged<double> onNotaDeseadaChanged;

  @override
  Widget build(BuildContext context) {
    final necesaria = _notaNecesaria(notaDeseada);
    final minAprobar = _notaNecesaria(AppConstants.notaAprobacion);

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.calculate_rounded,
            texto: 'Calculadora de Eximición',
          ),
          const SizedBox(height: 4),
          Text(
            'Calcula la nota que necesitas en lo que falta.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.lg),

          // Nota deseada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nota deseada', style: AppTypography.body),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Text(
                  notaDeseada.toStringAsFixed(1),
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(
              sliderTheme: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 4,
              ),
            ),
            child: Slider(
              value: notaDeseada,
              min: AppConstants.notaAprobacion,
              max: AppConstants.notaMax,
              divisions: 30,
              label: notaDeseada.toStringAsFixed(1),
              onChanged: onNotaDeseadaChanged,
            ),
          ),
          Divider(color: AppColors.border, height: AppDimensions.xl),

          _ResultadoNota(
            label:
                'Nota necesaria (${resultado.pesoPendiente.toStringAsFixed(0)}% restante)',
            nota: necesaria,
          ),
          const SizedBox(height: AppDimensions.md),
          _ResultadoNota(label: 'Mínimo para aprobar (4.0)', nota: minAprobar),
        ],
      ),
    );
  }

  double? _notaNecesaria(double objetivo) {
    final tieneExamenPendiente =
        asignatura.tieneExamen &&
        !resultado.eximido &&
        resultado.pesoPendiente == 0 &&
        resultado.promedioPresentacion != null;

    if (tieneExamenPendiente) {
      return CalculoService.notaNecesariaExamen(
        objetivo: objetivo,
        presentacion: resultado.promedioPresentacion!,
        pesoPresentacion: asignatura.pesoPresentacion,
        pesoExamen: asignatura.pesoExamen,
      );
    }
    return CalculoService.notaNecesariaRestante(
      objetivo: objetivo,
      evaluaciones: asignatura.evaluaciones,
    );
  }
}

class _ResultadoNota extends StatelessWidget {
  const _ResultadoNota({required this.label, required this.nota});
  final String label;
  final double? nota;

  @override
  Widget build(BuildContext context) {
    final n = nota;
    final String texto;
    final Color color;
    if (n == null) {
      texto = 'Sin pendientes';
      color = AppColors.textMuted;
    } else if (n > AppConstants.notaMax) {
      texto = 'Imposible';
      color = AppColors.reprobado;
    } else if (n <= AppConstants.notaMin) {
      texto = '¡Asegurado!';
      color = AppColors.aprobado;
    } else {
      texto = n.toStringAsFixed(1);
      color = n >= AppConstants.notaAprobacion
          ? AppColors.examen
          : AppColors.aprobado;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(
            texto,
            style: AppTypography.h3.copyWith(color: color, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

// --- Card: Evolución ---
class _EvolucionCard extends StatelessWidget {
  const _EvolucionCard({required this.evaluaciones});
  final List<Evaluacion> evaluaciones;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.show_chart_rounded,
            texto: 'Evolución del Rendimiento',
          ),
          const SizedBox(height: AppDimensions.lg),
          EvolucionBarChart(evaluaciones: evaluaciones),
        ],
      ),
    );
  }
}

// --- Título de sección ---
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.texto});
  final IconData icon;
  final String texto;

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
        Text(texto, style: AppTypography.h3),
      ],
    );
  }
}
