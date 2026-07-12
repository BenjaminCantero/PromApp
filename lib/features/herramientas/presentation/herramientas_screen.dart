import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../calculos/domain/calculo_service.dart';
import '../../dashboard/presentation/widgets/promedio_donut.dart';

/// Simulador de examen, accesible desde el apartado Calculadora.
class HerramientasScreen extends StatefulWidget {
  const HerramientasScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<HerramientasScreen> createState() => _HerramientasScreenState();
}

class _HerramientasScreenState extends State<HerramientasScreen> {
  final _presentacionCtrl = TextEditingController();
  final _pctExamenCtrl = TextEditingController();
  final _eximirCtrl = TextEditingController();
  final _aprobacionCtrl = TextEditingController(
    text: AppConstants.notaAprobacion.toStringAsFixed(1),
  );

  @override
  void dispose() {
    _presentacionCtrl.dispose();
    _pctExamenCtrl.dispose();
    _eximirCtrl.dispose();
    _aprobacionCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.'));

  void _rebuild(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final presentacion = _parse(_presentacionCtrl);
    final pctExamen = _parse(_pctExamenCtrl);
    final eximir = _parse(_eximirCtrl);
    final aprobacion = _parse(_aprobacionCtrl) ?? AppConstants.notaAprobacion;

    final sim = _simular(
      presentacion: presentacion,
      pctExamen: pctExamen,
      objetivo: aprobacion,
      eximir: eximir,
    );

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                topPad + AppDimensions.lg,
                AppDimensions.screenPadding,
                AppDimensions.xxl,
              ),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textOnDark,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.textOnDark.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CALCULADORA',
                          style: AppTypography.captionUppercase,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Simulador de examen',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Calcula qué necesitas y si puedes eximirte.',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textOnDark.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                // Card de resultado principal
                _ResultadoPrincipal(sim: sim),
                const SizedBox(height: AppDimensions.xl),

                // Stats secundarios
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        titulo: 'Nota en examen',
                        valor: sim.textoNotaExamen,
                        color: sim.colorNotaExamen,
                        icon: Icons.flag_rounded,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _StatCard(
                        titulo: 'Dist. eximición',
                        valor: sim.textoDistanciaEximicion,
                        color: sim.colorEximicion,
                        icon: Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),

                // Parámetros
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.xs + 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm - 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text(
                            'Parámetros de Evaluación',
                            style: AppTypography.h3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _InputNota(
                        label: 'Promedio de presentación',
                        controller: _presentacionCtrl,
                        hint: 'Ej: 5.2',
                        suffix: '/ 7.0',
                        onChanged: _rebuild,
                        icon: Icons.school_rounded,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _InputNota(
                        label: 'Ponderación del examen',
                        controller: _pctExamenCtrl,
                        hint: 'Ej: 40',
                        suffix: '%',
                        onChanged: _rebuild,
                        icon: Icons.percent_rounded,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _InputNota(
                        label: 'Nota de eximición (opcional)',
                        controller: _eximirCtrl,
                        hint: 'Ej: 5.5',
                        suffix: '/ 7.0',
                        onChanged: _rebuild,
                        icon: Icons.star_rounded,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _InputNota(
                        label: 'Nota mínima de aprobación',
                        controller: _aprobacionCtrl,
                        hint: 'Ej: 4.0',
                        suffix: '/ 7.0',
                        onChanged: _rebuild,
                        icon: Icons.check_circle_rounded,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  _Simulacion _simular({
    double? presentacion,
    double? pctExamen,
    required double objetivo,
    double? eximir,
  }) {
    if (presentacion == null ||
        pctExamen == null ||
        pctExamen <= 0 ||
        pctExamen >= 100) {
      return const _Simulacion.esperando();
    }

    final pesoExamen = pctExamen / 100.0;
    final pesoPresentacion = 1 - pesoExamen;
    final eximido = eximir != null && presentacion >= eximir;
    final notaExamen = CalculoService.notaNecesariaExamen(
      objetivo: objetivo,
      presentacion: presentacion,
      pesoPresentacion: pesoPresentacion,
      pesoExamen: pesoExamen,
    );
    final distancia = eximir == null ? null : eximir - presentacion;

    return _Simulacion(
      eximido: eximido,
      notaExamenNecesaria: notaExamen,
      distanciaEximicion: distancia,
    );
  }
}

class _Simulacion {
  const _Simulacion({
    required this.eximido,
    required this.notaExamenNecesaria,
    required this.distanciaEximicion,
  }) : esperando = false;

  const _Simulacion.esperando()
    : eximido = false,
      notaExamenNecesaria = null,
      distanciaEximicion = null,
      esperando = true;

  final bool esperando;
  final bool eximido;
  final double? notaExamenNecesaria;
  final double? distanciaEximicion;

  String get tituloEstado {
    if (esperando) return 'Ingresa tus datos';
    if (eximido) return '¡Estás eximido!';
    final n = notaExamenNecesaria!;
    if (n > AppConstants.notaMax) return 'Imposible aprobar';
    if (n <= AppConstants.notaMin) return '¡Aprobado asegurado!';
    return 'Necesitas rendir';
  }

  String get subtituloEstado {
    if (esperando) return 'Completa la presentación y ponderación';
    if (eximido) return 'Tu presentación supera la nota de eximición ✓';
    final n = notaExamenNecesaria!;
    if (n > AppConstants.notaMax) {
      return 'Ni con un 7.0 en el examen alcanzas la nota de aprobación';
    }
    if (n <= AppConstants.notaMin) {
      return 'Apruebas con cualquier nota en el examen';
    }
    return 'Necesitas al menos ${n.toStringAsFixed(1)} en el examen';
  }

  Color get colorEstado {
    if (esperando) return AppColors.textMuted;
    if (eximido) return AppColors.aprobado;
    final n = notaExamenNecesaria!;
    if (n > AppConstants.notaMax) return AppColors.reprobado;
    if (n <= AppConstants.notaMin) return AppColors.aprobado;
    return AppColors.examen;
  }

  double get progreso {
    if (esperando || notaExamenNecesaria == null) return 0;
    return (notaExamenNecesaria! / AppConstants.notaMax).clamp(0.0, 1.0);
  }

  String get textoNotaExamen {
    if (esperando) return '—';
    if (eximido) return 'Eximido';
    final n = notaExamenNecesaria!;
    if (n > AppConstants.notaMax) return 'Imposible';
    if (n <= AppConstants.notaMin) return 'Cualquiera';
    return n.toStringAsFixed(1);
  }

  Color get colorNotaExamen => colorEstado;

  String get textoDistanciaEximicion {
    if (distanciaEximicion == null) return '—';
    final d = distanciaEximicion!;
    if (d <= 0) return 'Eximido';
    return '+${d.toStringAsFixed(1)}';
  }

  Color get colorEximicion {
    if (distanciaEximicion == null) return AppColors.textMuted;
    return distanciaEximicion! <= 0 ? AppColors.aprobado : AppColors.primary;
  }
}

// --- Widgets ---

class _ResultadoPrincipal extends StatelessWidget {
  const _ResultadoPrincipal({required this.sim});
  final _Simulacion sim;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Row(
        children: [
          // Donut
          PromedioDonut(
            progreso: sim.progreso,
            valorCentral: sim.esperando ? '?' : sim.textoNotaExamen,
            etiqueta: 'en examen',
            size: 120,
            color: sim.colorEstado,
          ),
          const SizedBox(width: AppDimensions.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sim.tituloEstado,
                  style: AppTypography.h3.copyWith(color: sim.colorEstado),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(sim.subtituloEstado, style: AppTypography.bodySecondary),
                if (!sim.esperando && !sim.eximido) ...[
                  const SizedBox(height: AppDimensions.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sim.colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                    ),
                    child: Text(
                      sim.eximido ? '✓ Eximido' : 'Debe rendir examen',
                      style: AppTypography.caption.copyWith(
                        color: sim.colorEstado,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icon,
  });
  final String titulo;
  final String valor;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(titulo, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(valor, style: AppTypography.h2.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InputNota extends StatelessWidget {
  const _InputNota({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.suffix,
    this.icon,
  });
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? suffix;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textMuted)
                : null,
          ),
        ),
      ],
    );
  }
}
