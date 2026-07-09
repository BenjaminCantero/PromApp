import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../dashboard/presentation/widgets/promedio_donut.dart';

/// Calculadora libre de notas — sin guardar ramo ni progreso.
/// El usuario agrega notas + ponderaciones y ve el promedio en tiempo real.
class CalculadoraLibreScreen extends StatefulWidget {
  const CalculadoraLibreScreen({super.key});

  @override
  State<CalculadoraLibreScreen> createState() => _CalculadoraLibreScreenState();
}

class _CalculadoraLibreScreenState extends State<CalculadoraLibreScreen>
    with TickerProviderStateMixin {
  final List<_FilaNota> _filas = [];
  late AnimationController _resultAnim;
  late Animation<double> _resultScale;

  // ── Sección examen ──
  bool _conExamen = false;
  final _notaExamenCtrl = TextEditingController();
  final _pctExamenCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resultAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resultScale = CurvedAnimation(parent: _resultAnim, curve: Curves.elasticOut);
    for (int i = 0; i < 3; i++) {
      _filas.add(_FilaNota());
    }
  }

  @override
  void dispose() {
    _resultAnim.dispose();
    _notaExamenCtrl.dispose();
    _pctExamenCtrl.dispose();
    for (final f in _filas) {
      f.dispose();
    }
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Cálculos
  // ──────────────────────────────────────────────

  _Resultado _calcular() {
    final validas = _filas.where((f) => f.nota != null && f.pct != null).toList();
    if (validas.isEmpty) return const _Resultado.vacia();

    final sumaPct = validas.fold<double>(0, (acc, f) => acc + f.pct!);
    if (sumaPct <= 0) return const _Resultado.vacia();

    final sumaPond = validas.fold<double>(0, (acc, f) => acc + f.nota! * f.pct!);
    final promedioPres = sumaPond / sumaPct;
    final pctUsado = _filas.fold<double>(0, (acc, f) => acc + (f.pct ?? 0));

    // ── Cálculo con examen ──
    final notaEx  = double.tryParse(_notaExamenCtrl.text.replaceAll(',', '.'));
    final pctEx   = double.tryParse(_pctExamenCtrl.text.replaceAll(',', '.'));
    double? notaFinal;
    if (_conExamen && notaEx != null && pctEx != null && pctEx > 0 && pctEx < 100) {
      final pesoEx  = pctEx / 100.0;
      final pesoPresEfectivo = 1.0 - pesoEx;
      notaFinal = promedioPres * pesoPresEfectivo + notaEx * pesoEx;
    }

    return _Resultado(
      promedioPresentacion: promedioPres,
      pctUsado: pctUsado.clamp(0, 100),
      cantNotas: validas.length,
      notaFinal: notaFinal,
    );
  }

  void _onChanged(String _) {
    _resultAnim.forward(from: 0);
    setState(() {});
  }

  void _agregarFila() {
    setState(() => _filas.add(_FilaNota()));
    _resultAnim.forward(from: 0);
  }

  void _eliminarFila(int index) {
    _filas[index].dispose();
    setState(() => _filas.removeAt(index));
  }

  void _limpiarTodo() {
    for (final f in _filas) {
      f.dispose();
    }
    _notaExamenCtrl.clear();
    _pctExamenCtrl.clear();
    setState(() {
      _filas.clear();
      _conExamen = false;
      for (int i = 0; i < 3; i++) {
        _filas.add(_FilaNota());
      }
    });
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final resultado = _calcular();
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textOnDark,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.textOnDark.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CALCULADORA', style: AppTypography.captionUppercase),
                        const SizedBox(height: 4),
                        Text(
                          'Cálculo Libre',
                          style: AppTypography.h1.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sin guardar · Solo calcula',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textOnDark.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botón limpiar
                  IconButton(
                    onPressed: _limpiarTodo,
                    tooltip: 'Limpiar todo',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textOnDark,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.textOnDark.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.xl,
              AppDimensions.screenPadding,
              120,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // --- Resultado principal ---
                ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(_resultScale),
                  child: _ResultadoCard(resultado: resultado),
                ),
                const SizedBox(height: AppDimensions.xl),

                // --- Stats rápidos ---
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Notas ingresadas',
                        value: resultado.cantNotas.toString(),
                        icon: Icons.edit_note_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _MiniStat(
                        label: '% ponderado',
                        value: resultado.vacia
                            ? '—'
                            : '${resultado.pctUsado.toStringAsFixed(0)}%',
                        icon: Icons.pie_chart_rounded,
                        color: resultado.pctUsado > 100
                            ? AppColors.reprobado
                            : AppColors.accentTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),

                // --- Tabla de notas ---
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabecera
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.xs + 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSm - 2),
                            ),
                            child: const Icon(
                              Icons.table_rows_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text('Notas & Ponderaciones', style: AppTypography.h3),
                          const Spacer(),
                          Text(
                            '${_filas.length} filas',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // Encabezados de columnas
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.xs,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 36),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'NOTA (1.0 – 7.0)',
                                style: AppTypography.captionUppercase,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'PONDERACIÓN %',
                                style: AppTypography.captionUppercase,
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),

                      // Filas de notas
                      ...List.generate(_filas.length, (i) {
                        return _FilaNotaWidget(
                          key: ValueKey(_filas[i].id),
                          fila: _filas[i],
                          index: i,
                          onChanged: _onChanged,
                          onDelete: _filas.length > 1
                              ? () => _eliminarFila(i)
                              : null,
                        );
                      }),

                      const SizedBox(height: AppDimensions.md),

                      // Botón agregar fila
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _agregarFila,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Agregar nota'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimensions.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Advertencia ponderación > 100% ---
                if (!resultado.vacia && resultado.pctUsado > 100.5) ...[
                  const SizedBox(height: AppDimensions.md),
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    borderColor: AppColors.reprobado.withValues(alpha: 0.4),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.reprobado, size: 18),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            'La suma de ponderaciones supera el 100%.',
                            style: AppTypography.caption.copyWith(color: AppColors.reprobado),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // --- Sección examen ---
                const SizedBox(height: AppDimensions.xl),
                _SeccionExamen(
                  activo: _conExamen,
                  notaCtrl: _notaExamenCtrl,
                  pctCtrl: _pctExamenCtrl,
                  onToggle: (v) { setState(() => _conExamen = v); _resultAnim.forward(from: 0); },
                  onChanged: _onChanged,
                  resultado: resultado,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Modelo de una fila de nota
// ─────────────────────────────────────────────────────────────

class _FilaNota {
  _FilaNota() : id = _nextId++;
  static int _nextId = 0;

  final int id;
  final notaCtrl = TextEditingController();
  final pctCtrl = TextEditingController();

  double? get nota => double.tryParse(notaCtrl.text.replaceAll(',', '.'));
  double? get pct => double.tryParse(pctCtrl.text.replaceAll(',', '.'));

  void dispose() {
    notaCtrl.dispose();
    pctCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Modelo de resultado
// ─────────────────────────────────────────────────────────────

class _Resultado {
  const _Resultado({
    required this.promedioPresentacion,
    required this.pctUsado,
    required this.cantNotas,
    this.notaFinal,
  }) : vacia = false;

  const _Resultado.vacia()
      : promedioPresentacion = 0,
        pctUsado = 0,
        cantNotas = 0,
        notaFinal = null,
        vacia = true;

  final bool vacia;
  final double promedioPresentacion;
  final double pctUsado;
  final int cantNotas;
  final double? notaFinal;

  /// Nota a mostrar en el donut (final si hay examen, presentación si no)
  double get promedio => notaFinal ?? promedioPresentacion;

  bool get aprobado => promedio >= 4.0;
  bool get tieneExamen => notaFinal != null;

  Color _colorPara(double n) {
    if (n >= 5.5) return AppColors.aprobado;
    if (n >= 4.0) return const Color(0xFF34D399);
    if (n >= 3.5) return AppColors.examen;
    return AppColors.reprobado;
  }

  Color get color => vacia ? AppColors.textMuted : _colorPara(promedio);
  Color get colorPres => vacia ? AppColors.textMuted : _colorPara(promedioPresentacion);

  String get texto => vacia ? '—' : promedio.toStringAsFixed(1);
  String get textoPres => vacia ? '—' : promedioPresentacion.toStringAsFixed(1);

  String get etiqueta {
    if (vacia) return 'sin datos';
    if (promedio >= 5.5) return 'Excelente';
    if (promedio >= 4.0) return 'Aprobado';
    if (promedio >= 3.5) return 'Límite';
    return 'Reprobado';
  }

  double get progreso => vacia ? 0 : (promedio / 7.0).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────────────────────
// Widget: Card de resultado principal
// ─────────────────────────────────────────────────────────────

class _ResultadoCard extends StatelessWidget {
  const _ResultadoCard({required this.resultado});
  final _Resultado resultado;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.xl),
      glowColor: resultado.vacia ? null : resultado.color,
      child: Row(
        children: [
          PromedioDonut(
            progreso: resultado.progreso,
            valorCentral: resultado.texto,
            etiqueta: 'promedio',
            size: 120,
            color: resultado.color,
          ),
          const SizedBox(width: AppDimensions.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultado.vacia ? 'Ingresa tus notas' : resultado.etiqueta,
                  style: AppTypography.h2.copyWith(color: resultado.color),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  resultado.vacia
                      ? 'Agrega nota y ponderación para calcular el promedio al instante.'
                      : 'Promedio ponderado de ${resultado.cantNotas} ${resultado.cantNotas == 1 ? 'nota' : 'notas'} ingresadas.',
                  style: AppTypography.bodySecondary,
                ),
                if (!resultado.vacia) ...[
                  const SizedBox(height: AppDimensions.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: resultado.color.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      resultado.aprobado ? '✓ Aprueba' : '✗ Reprueba',
                      style: AppTypography.caption.copyWith(
                        color: resultado.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (resultado.tieneExamen) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        Text('Presentación: ', style: AppTypography.caption),
                        Text(
                          resultado.textoPres,
                          style: AppTypography.caption.copyWith(
                            color: resultado.colorPres,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Mini stat card
// ─────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.h2.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Fila de nota editable
// ─────────────────────────────────────────────────────────────

class _FilaNotaWidget extends StatelessWidget {
  const _FilaNotaWidget({
    super.key,
    required this.fila,
    required this.index,
    required this.onChanged,
    this.onDelete,
  });

  final _FilaNota fila;
  final int index;
  final ValueChanged<String> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool tieneNota = fila.nota != null;
    final bool tienePct = fila.pct != null;
    final bool completa = tieneNota && tienePct;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Número de fila
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              style: AppTypography.caption.copyWith(
                color: completa
                    ? AppColors.primary
                    : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Campo nota
          Expanded(
            flex: 5,
            child: _CampoNota(
              controller: fila.notaCtrl,
              hint: '1.0 – 7.0',
              onChanged: onChanged,
              isValid: tieneNota,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Campo ponderación
          Expanded(
            flex: 4,
            child: _CampoNota(
              controller: fila.pctCtrl,
              hint: 'Ej: 25',
              suffix: '%',
              onChanged: onChanged,
              isValid: tienePct,
            ),
          ),
          const SizedBox(width: AppDimensions.xs),

          // Botón eliminar
          SizedBox(
            width: 32,
            child: onDelete != null
                ? IconButton(
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CampoNota extends StatelessWidget {
  const _CampoNota({
    required this.controller,
    required this.onChanged,
    this.hint,
    this.suffix,
    this.isValid = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? suffix;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      style: AppTypography.body.copyWith(
        color: isValid ? AppColors.textPrimary : AppColors.textSecondary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm + 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: BorderSide(
            color: isValid
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceAlt,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Sección de examen final
// ─────────────────────────────────────────────────────────────

class _SeccionExamen extends StatelessWidget {
  const _SeccionExamen({
    required this.activo,
    required this.notaCtrl,
    required this.pctCtrl,
    required this.onToggle,
    required this.onChanged,
    required this.resultado,
  });

  final bool activo;
  final TextEditingController notaCtrl;
  final TextEditingController pctCtrl;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onChanged;
  final _Resultado resultado;

  @override
  Widget build(BuildContext context) {
    final notaEx = double.tryParse(notaCtrl.text.replaceAll(',', '.'));
    final pctEx  = double.tryParse(pctCtrl.text.replaceAll(',', '.'));
    final listo  = activo && notaEx != null && pctEx != null && pctEx > 0 && pctEx < 100;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      borderColor: activo
          ? AppColors.examen.withValues(alpha: 0.4)
          : AppColors.border,
      glowColor: listo ? AppColors.examen : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera con toggle ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.xs + 2),
                decoration: BoxDecoration(
                  color: AppColors.examen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm - 2),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 14,
                  color: AppColors.examen,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Examen Final', style: AppTypography.h3),
                    Text(
                      'Pondera tu nota de presentación con el examen',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Switch(
                value: activo,
                onChanged: onToggle,
                activeThumbColor: AppColors.examen,
                trackColor: WidgetStateProperty.resolveWith((s) {
                  if (s.contains(WidgetState.selected)) {
                    return AppColors.examen.withValues(alpha: 0.3);
                  }
                  return AppColors.border;
                }),
              ),
            ],
          ),

          // ── Campos (solo cuando activo) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: activo
                ? Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.lg),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nota examen', style: AppTypography.label),
                                  const SizedBox(height: 6),
                                  _CampoNota(
                                    controller: notaCtrl,
                                    hint: '1.0 – 7.0',
                                    onChanged: onChanged,
                                    isValid: notaEx != null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ponderación examen', style: AppTypography.label),
                                  const SizedBox(height: 6),
                                  _CampoNota(
                                    controller: pctCtrl,
                                    hint: 'Ej: 40',
                                    suffix: '%',
                                    onChanged: onChanged,
                                    isValid: pctEx != null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ── Resultado final si hay datos suficientes ──
                        if (listo && !resultado.vacia) ...[
                          const SizedBox(height: AppDimensions.lg),
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(
                                  color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _ResumenNota(
                                  label: 'Presentación',
                                  valor: resultado.textoPres,
                                  pct: '${(100 - pctEx).toStringAsFixed(0)}%',
                                  color: resultado.colorPres,
                                ),
                                const Icon(
                                  Icons.add_rounded,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                                _ResumenNota(
                                  label: 'Examen',
                                  valor: notaEx.toStringAsFixed(1),
                                  pct: '${pctEx.toStringAsFixed(0)}%',
                                  color: AppColors.examen,
                                ),
                                const Icon(
                                  Icons.drag_handle_rounded,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                                _ResumenNota(
                                  label: 'Nota Final',
                                  valor: resultado.texto,
                                  pct: '',
                                  color: resultado.color,
                                  grande: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ResumenNota extends StatelessWidget {
  const _ResumenNota({
    required this.label,
    required this.valor,
    required this.pct,
    required this.color,
    this.grande = false,
  });
  final String label;
  final String valor;
  final String pct;
  final Color color;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 2),
        Text(
          valor,
          style: (grande ? AppTypography.h1 : AppTypography.h2)
              .copyWith(color: color),
        ),
        if (pct.isNotEmpty)
          Text(pct, style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
          )),
      ],
    );
  }
}
