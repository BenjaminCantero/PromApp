import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';


const _kOnboardingKey = 'onboarding_done';

/// Verifica si el onboarding ya fue completado.
Future<bool> onboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingKey) ?? false;
}

/// Marca el onboarding como completado.
Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingKey, true);
}

// ─────────────────────────────────────────────────────────────
// Modelo de cada slide
// ─────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.gradiente,
    required this.detalle,
  });

  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final LinearGradient gradiente;
  final List<String> detalle;
}

const _slides = [
  _Slide(
    icon: Icons.school_rounded,
    titulo: 'Controla tus ramos',
    descripcion:
        'Registra cada evaluación con su ponderación y PromApp calcula tu promedio automáticamente.',
    color: AppColors.primary,
    gradiente: AppColors.primaryGradient,
    detalle: [
      '📚  Agrega tus ramos del semestre',
      '✏️  Ingresa evaluaciones y ponderaciones',
      '📊  Ve tu promedio actualizado al instante',
    ],
  ),
  _Slide(
    icon: Icons.trending_up_rounded,
    titulo: 'Simula tu examen',
    descripcion:
        '¿Cuánto necesitas en el examen para aprobar? PromApp te lo dice en segundos.',
    color: AppColors.examen,
    gradiente: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    ),
    detalle: [
      '🎯  Ingresa tu nota de presentación',
      '⚖️  Define la ponderación del examen',
      '✅  Descubre si puedes eximirte',
    ],
  ),
  _Slide(
    icon: Icons.calculate_rounded,
    titulo: 'Calculadora libre',
    descripcion:
        'Calcula cualquier promedio ponderado al vuelo, sin guardar nada. Solo notas y ponderaciones.',
    color: AppColors.aprobado,
    gradiente: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF059669), Color(0xFF10B981)],
    ),
    detalle: [
      '➕  Agrega tantas notas como necesites',
      '🔢  Con o sin ponderación de examen final',
      '⚡  Resultado en tiempo real',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
// Pantalla de Onboarding
// ─────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinish});
  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _pagina = 0;

  late final AnimationController _iconAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _iconAnim.dispose();
    super.dispose();
  }

  void _irASiguiente() {
    if (_pagina < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _entrarApp();
    }
  }

  void _irAAnterior() {
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _entrarApp() async {
    await markOnboardingDone();
    if (!mounted) return;
    widget.onFinish?.call();
  }

  void _onPageChanged(int p) {
    setState(() => _pagina = p);
    _iconAnim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final slide = _slides[_pagina];
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Fondo animado con gradiente del slide ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  slide.color.withValues(alpha: 0.18),
                  AppColors.background,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
          ),

          // ── Orbe decorativo superior ──
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.color.withValues(alpha: 0.25),
                    slide.color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: topPad + AppDimensions.lg),

              // ── Botón saltar (solo en los primeros slides) ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo pequeño
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'PromApp',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (_pagina < _slides.length - 1)
                      TextButton(
                        onPressed: _entrarApp,
                        child: Text(
                          'Saltar',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── PageView ──
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
                ),
              ),

              // ── Indicadores de página ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _pagina;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xs,
                    ),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? slide.color : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.xl),

              // ── Botones de navegación ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  0,
                  AppDimensions.screenPadding,
                  botPad + AppDimensions.xl,
                ),
                child: Row(
                  children: [
                    // Botón atrás
                    if (_pagina > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _irAAnterior,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            minimumSize: const Size(
                              0,
                              AppDimensions.buttonHeight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text('Atrás'),
                        ),
                      ),
                    if (_pagina > 0) const SizedBox(width: AppDimensions.md),

                    // Botón siguiente / entrar
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: slide.gradiente,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: slide.color.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _irASiguiente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(
                              0,
                              AppDimensions.buttonHeight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _pagina == _slides.length - 1
                                    ? 'Comenzar'
                                    : 'Siguiente',
                                style: AppTypography.button.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.sm),
                              Icon(
                                _pagina == _slides.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────
// Widget de cada slide
// ─────────────────────────────────────────────────────────────

class _SlideWidget extends StatefulWidget {
  const _SlideWidget({required this.slide});
  final _Slide slide;

  @override
  State<_SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<_SlideWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _scale = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.elasticOut,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.6),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slide;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono animado
          ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: s.gradiente,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXl + 8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Icon(s.icon, size: 56, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),

          // Título
          FadeTransition(
            opacity: _fade,
            child: Text(
              s.titulo,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Descripción
          FadeTransition(
            opacity: _fade,
            child: Text(
              s.descripcion,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.xxl),

          // Puntos de detalle
          FadeTransition(
            opacity: _fade,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: s.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: s.detalle.map((d) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.xs + 1,
                    ),
                    child: Text(
                      d,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
