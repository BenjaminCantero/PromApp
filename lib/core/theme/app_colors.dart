import 'package:flutter/material.dart';

/// Paleta central de PromApp — Ocean Edition.
///
/// Basada en 5 colores oceánicos del usuario:
///   #133b5f → navy profundo   (fondo / superficies oscuras)
///   #125277 → azul océano     (cards / superficies)
///   #157896 → azul cielo mar  (bordes / acentos secundarios)
///   #1aa6b2 → teal            (primario)
///   #20dbc8 → cyan brillante  (acento / highlights)
class AppColors {
  AppColors._();

  // --- Paleta océano (5 tonos base del usuario) ---
  static const Color ocean1 = Color(0xFF133b5f); // navy profundo
  static const Color ocean2 = Color(0xFF125277); // azul océano
  static const Color ocean3 = Color(0xFF157896); // azul cielo mar
  static const Color ocean4 = Color(0xFF1aa6b2); // teal
  static const Color ocean5 = Color(0xFF20dbc8); // cyan brillante

  // --- Marca / Primarios ---
  static const Color primary      = Color(0xFF1aa6b2); // teal (ocean4)
  static const Color primaryDark  = Color(0xFF157896); // ocean3
  static const Color primaryLight = Color(0xFF20dbc8); // cyan (ocean5)
  static const Color accent       = Color(0xFF20dbc8); // cyan acento
  static const Color accentDark   = Color(0xFF1aa6b2); // teal

  // Compatibilidad con código existente
  static const Color navy     = Color(0xFF0d2a44); // más oscuro que ocean1
  static const Color navyDark = Color(0xFF091e32);
  static const Color celeste  = Color(0xFF1aa6b2); // ahora es teal

  // --- Superficies (dark theme oceánico) ---
  static const Color background      = Color(0xFF0b2236); // casi negro azulado
  static const Color surface         = Color(0xFF112f4e); // card principal
  static const Color surfaceElevated = Color(0xFF133b5f); // ocean1
  static const Color surfaceAlt      = Color(0xFF164462); // entre ocean1 y ocean2
  static const Color border          = Color(0xFF1a5070); // borde sutil
  static const Color borderLight     = Color(0xFF1d6080); // borde más visible

  // --- Texto ---
  static const Color textPrimary   = Color(0xFFE8F8F9); // blanco azulado suave
  static const Color textSecondary = Color(0xFF8EC9D4); // teal claro medio
  static const Color textMuted     = Color(0xFF5895a3); // teal apagado
  static const Color textOnDark    = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Estados semánticos (universales) ---
  static const Color aprobado      = Color(0xFF10B981); // Emerald 500
  static const Color aprobadoLight = Color(0xFF6EE7B7); // Emerald 300
  static const Color reprobado     = Color(0xFFF43F5E); // Rose 500
  static const Color reprobadoLight= Color(0xFFFDA4AF); // Rose 300
  static const Color examen        = Color(0xFFF59E0B); // Amber 500
  static const Color examenLight   = Color(0xFFFCD34D); // Amber 300
  static const Color info          = Color(0xFF1aa6b2); // teal

  // --- Acentos por categoría ---
  static const Color accentRed    = Color(0xFFF43F5E);
  static const Color accentBlue   = Color(0xFF1aa6b2); // teal
  static const Color accentPurple = Color(0xFF7C9CBF); // azul grisáceo
  static const Color accentTeal   = Color(0xFF20dbc8); // cyan
  static const Color accentAmber  = Color(0xFFF59E0B);

  // Fondos de badges (glassmorphism suave)
  static const Color badgeRedBg    = Color(0x33F43F5E);
  static const Color badgeBlueBg   = Color(0x331aa6b2);
  static const Color badgePurpleBg = Color(0x331d6080);

  // --- Gradientes ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1aa6b2), Color(0xFF20dbc8)], // teal → cyan
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0d2a44), Color(0xFF125277), Color(0xFF0d2a44)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF112f4e), Color(0xFF133b5f)],
  );

  static const LinearGradient aprobadoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient reprobadoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
  );

  // --- Sombras ---
  static const Color shadow      = Color(0x660b2236);
  static const Color glowPrimary = Color(0x331aa6b2);

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x660b2236),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x1A1aa6b2),
          blurRadius: 40,
          offset: Offset.zero,
        ),
      ];

  static List<BoxShadow> get primaryGlow => const [
        BoxShadow(
          color: Color(0x401aa6b2),
          blurRadius: 24,
          offset: Offset(0, 4),
        ),
      ];
}
