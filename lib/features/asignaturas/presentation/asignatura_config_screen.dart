import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/error_messages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../calculos/domain/validators.dart';
import '../application/asignatura_providers.dart';
import '../application/asignaturas_controller.dart';
import '../domain/asignatura.dart';
import '../domain/evaluacion.dart';

const _uuid = Uuid();

/// Borrador editable de una evaluación.
class _EvalDraft {
  _EvalDraft({String? id, String nombre = '', String pct = '', this.tipo})
    : id = id ?? _uuid.v4(),
      nombreCtrl = TextEditingController(text: nombre),
      pctCtrl = TextEditingController(text: pct);

  final String id;
  final TextEditingController nombreCtrl;
  final TextEditingController pctCtrl;
  String? tipo;

  double get pct => double.tryParse(pctCtrl.text.replaceAll(',', '.')) ?? 0;

  Evaluacion toEvaluacion(Evaluacion? previa) => Evaluacion(
    id: id,
    nombre: nombreCtrl.text.trim(),
    porcentaje: pct,
    tipo: tipo,
    nota: previa?.nota,
    fecha: previa?.fecha,
  );

  void dispose() {
    nombreCtrl.dispose();
    pctCtrl.dispose();
  }
}

/// Pantalla crear / editar asignatura — Diseño Premium Dark.
class AsignaturaConfigScreen extends ConsumerStatefulWidget {
  const AsignaturaConfigScreen({super.key, this.asignaturaId});

  final String? asignaturaId;

  bool get esEdicion => asignaturaId != null;

  @override
  ConsumerState<AsignaturaConfigScreen> createState() =>
      _AsignaturaConfigScreenState();
}

class _AsignaturaConfigScreenState
    extends ConsumerState<AsignaturaConfigScreen> {
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _semestreCtrl = TextEditingController();
  final _eximirCtrl = TextEditingController();

  final List<_EvalDraft> _evaluaciones = [];
  Asignatura? _original;

  bool _tieneExamen = false;
  double _pesoPresentacion = AppConstants.defaultPesoPresentacion;
  bool _inicializado = false;
  bool _guardando = false;

  static const _tipos = [
    'Solemne',
    'Control',
    'Prueba',
    'Tarea',
    'Proyecto',
    'Taller',
    'Laboratorio',
    'Ensayo',
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _semestreCtrl.dispose();
    _eximirCtrl.dispose();
    for (final e in _evaluaciones) {
      e.dispose();
    }
    super.dispose();
  }

  void _inicializarDesde(Asignatura a) {
    _original = a;
    _nombreCtrl.text = a.nombre;
    _codigoCtrl.text = a.codigo ?? '';
    _semestreCtrl.text = a.semestre ?? '';
    _tieneExamen = a.tieneExamen;
    _pesoPresentacion = a.pesoPresentacion;
    _eximirCtrl.text = a.notaEximir?.toString() ?? '';
    for (final e in a.evaluaciones) {
      _evaluaciones.add(
        _EvalDraft(
          id: e.id,
          nombre: e.nombre,
          pct: e.porcentaje.toStringAsFixed(0),
          tipo: e.tipo,
        ),
      );
    }
    _inicializado = true;
  }

  double get _sumaPct => _evaluaciones.fold<double>(0, (acc, e) => acc + e.pct);

  void _agregarEvaluacion() {
    setState(() => _evaluaciones.add(_EvalDraft()));
  }

  void _quitarEvaluacion(String id) {
    setState(() {
      _evaluaciones.removeWhere((e) => e.id == id);
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      _error('Ingresa el nombre de la asignatura');
      return;
    }
    if (_evaluaciones.isEmpty) {
      _error('Agrega al menos una evaluación');
      return;
    }
    final evals = _evaluaciones.map((d) {
      final previa = _original?.evaluaciones
          .where((e) => e.id == d.id)
          .cast<Evaluacion?>()
          .firstWhere((_) => true, orElse: () => null);
      return d.toEvaluacion(previa);
    }).toList();

    final sumaValida = Validators.sumaPorcentajes(evals);
    if (!sumaValida.esValido) {
      _error(sumaValida.error!);
      return;
    }

    final pesoExamen = 1 - _pesoPresentacion;
    final eximir = double.tryParse(_eximirCtrl.text.replaceAll(',', '.'));

    final asignatura = Asignatura(
      id: widget.asignaturaId ?? _uuid.v4(),
      nombre: nombre,
      codigo: _codigoCtrl.text.trim().isEmpty ? null : _codigoCtrl.text.trim(),
      semestre: _semestreCtrl.text.trim().isEmpty
          ? null
          : _semestreCtrl.text.trim(),
      evaluaciones: evals,
      tieneExamen: _tieneExamen,
      pesoPresentacion: _pesoPresentacion,
      pesoExamen: pesoExamen,
      notaExamen: _original?.notaExamen,
      notaEximir: _tieneExamen ? eximir : null,
    );

    setState(() => _guardando = true);
    try {
      await ref
          .read(asignaturasControllerProvider.notifier)
          .guardar(asignatura);
      if (!mounted) return;
      mostrarExito(context, 'Ramo guardado');
      Navigator.of(context).pop();
    } catch (e) {
      // La API falló: NO cerramos la pantalla — los datos del formulario
      // siguen ahí para que el usuario reintente sin perder lo escrito.
      if (mounted) _error(mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _error(String msg) => mostrarError(context, msg);

  @override
  Widget build(BuildContext context) {
    if (widget.esEdicion && !_inicializado) {
      final async = ref.watch(asignaturaProvider(widget.asignaturaId!));
      return async.when(
        loading: () => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: Text('Error: $e')),
        ),
        data: (a) {
          if (a == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: Text('Asignatura no encontrada')),
            );
          }
          _inicializarDesde(a);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final sumaOk = (_sumaPct - 100).abs() <= AppConstants.pctTolerancia;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Encabezado
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                topPad + AppDimensions.sm,
                AppDimensions.screenPadding,
                AppDimensions.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textOnDark,
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.textOnDark.withValues(
                        alpha: 0.1,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.sm),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    widget.esEdicion ? 'Editar Ramo' : 'Nuevo Ramo',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.esEdicion
                        ? 'Modifica la configuración del ramo'
                        : 'Configura tu asignatura y sus evaluaciones',
                    style: AppTypography.bodySecondary.copyWith(
                      color: AppColors.textOnDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Formulario
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              AppDimensions.xl,
              AppDimensions.screenPadding,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Información general
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardTitle(
                        icon: Icons.info_outline_rounded,
                        texto: 'Información General',
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _Campo(
                        label: 'Nombre del ramo *',
                        controller: _nombreCtrl,
                        hint: 'Ej: Cálculo I',
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Row(
                        children: [
                          Expanded(
                            child: _Campo(
                              label: 'Código',
                              controller: _codigoCtrl,
                              hint: 'Ej: MAT101',
                            ),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: _Campo(
                              label: 'Semestre',
                              controller: _semestreCtrl,
                              hint: '2025-1',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // Evaluaciones
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CardTitle(
                            icon: Icons.list_alt_rounded,
                            texto: 'Evaluaciones',
                          ),
                          _SumaBadge(suma: _sumaPct, ok: sumaOk),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      if (_evaluaciones.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.lg,
                          ),
                          child: Center(
                            child: Text(
                              'Aún no hay evaluaciones',
                              style: AppTypography.bodySecondary,
                            ),
                          ),
                        ),
                      for (final draft in _evaluaciones)
                        _FilaEvalEditable(
                          key: ValueKey(draft.id),
                          draft: draft,
                          tipos: _tipos,
                          onChanged: () => setState(() {}),
                          onQuitar: () => _quitarEvaluacion(draft.id),
                        ),
                      const SizedBox(height: AppDimensions.sm),
                      // Botón añadir
                      GestureDetector(
                        onTap: _agregarEvaluacion,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppDimensions.xs),
                              Text(
                                'Añadir evaluación',
                                style: AppTypography.bodyBold.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // Examen
                AppCard(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardTitle(
                        icon: Icons.assignment_rounded,
                        texto: 'Configuración de Examen',
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Este ramo tiene examen',
                          style: AppTypography.body,
                        ),
                        value: _tieneExamen,
                        onChanged: (v) => setState(() => _tieneExamen = v),
                      ),
                      if (_tieneExamen) ...[
                        const SizedBox(height: AppDimensions.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Presentación',
                                  style: AppTypography.caption,
                                ),
                                Text(
                                  '${(_pesoPresentacion * 100).toStringAsFixed(0)}%',
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Examen', style: AppTypography.caption),
                                Text(
                                  '${((1 - _pesoPresentacion) * 100).toStringAsFixed(0)}%',
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Slider(
                          value: _pesoPresentacion,
                          min: 0.5,
                          max: 0.9,
                          divisions: 8,
                          label:
                              '${(_pesoPresentacion * 100).toStringAsFixed(0)}%',
                          onChanged: (v) =>
                              setState(() => _pesoPresentacion = v),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        _Campo(
                          label: 'Nota para eximirse (opcional)',
                          controller: _eximirCtrl,
                          numerico: true,
                          hint: 'Ej: 5.5',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Botón guardar con gradiente (bloqueado mientras guarda)
                GestureDetector(
                  onTap: _guardando ? null : _guardar,
                  child: Opacity(
                    opacity: _guardando ? 0.6 : 1,
                    child: Container(
                      height: AppDimensions.buttonHeight,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        boxShadow: AppColors.primaryGlow,
                      ),
                      child: Center(
                        child: _guardando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.textOnDark,
                                ),
                              )
                            : Text(
                                widget.esEdicion
                                    ? 'Guardar cambios'
                                    : 'Crear asignatura',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.textOnDark,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widgets auxiliares ---

class _SumaBadge extends StatelessWidget {
  const _SumaBadge({required this.suma, required this.ok});
  final double suma;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.aprobado : AppColors.reprobado;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${suma.toStringAsFixed(0)}% / 100%',
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.texto});
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

class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.controller,
    this.numerico = false,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final bool numerico;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: numerico
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint, isDense: true),
        ),
      ],
    );
  }
}

class _FilaEvalEditable extends StatelessWidget {
  const _FilaEvalEditable({
    super.key,
    required this.draft,
    required this.tipos,
    required this.onChanged,
    required this.onQuitar,
  });

  final _EvalDraft draft;
  final List<String> tipos;
  final VoidCallback onChanged;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: draft.nombreCtrl,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      hintText: 'Nombre',
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: false,
                    ),
                  ),
                ),
                Container(
                  width: 96,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                  ),
                  child: TextField(
                    controller: draft.pctCtrl,
                    onChanged: (_) => onChanged(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: '%',
                      suffixStyle: AppTypography.bodyBold.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.sm,
                      ),
                      fillColor: AppColors.surfaceElevated,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onQuitar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.reprobado.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.reprobado,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
