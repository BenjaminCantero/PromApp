import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Card premium de PromApp — dark glassmorphism con borde sutil y sombra.
///
/// Soporta: gradiente de fondo, tap con ripple, borde personalizable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.lg),
    this.color,
    this.gradient,
    this.onTap,
    this.border = true,
    this.borderColor,
    this.glowColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool border;
  final Color? borderColor;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg);

    final List<BoxShadow> shadows = [
      ...AppColors.cardShadow,
      if (glowColor != null)
        BoxShadow(
          color: glowColor!.withValues(alpha: 0.3),
          blurRadius: 32,
          offset: Offset.zero,
        ),
    ];

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: br,
        border: border
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: 1,
              )
            : null,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

/// Variante de card con gradiente primario (indigo → violet) para acciones destacadas.
class AppCardPrimary extends StatelessWidget {
  const AppCardPrimary({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      gradient: AppColors.primaryGradient,
      border: false,
      glowColor: AppColors.primary,
      onTap: onTap,
      child: child,
    );
  }
}
