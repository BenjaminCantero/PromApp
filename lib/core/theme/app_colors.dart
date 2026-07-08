import 'package:flutter/material.dart';

/// Paleta central de PromApp — Diseño Premium Dark.
///
/// Deep Navy + Indigo/Violet gradients, emerald/amber/rose semantics.
class AppColors {
  AppColors._();

  // --- Marca / Primarios ---
  static const Color primary = Color(0xFF6366F1);       // Indigo vibrante
  static const Color primaryDark = Color(0xFF4F46E5);   // Indigo oscuro
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo claro
  static const Color accent = Color(0xFF8B5CF6);        // Violet acento
  static const Color accentDark = Color(0xFF7C3AED);

  // Compatibilidad con código existente
  static const Color navy = Color(0xFF1E1B4B);       // deep navy (fondo cards oscuras)
  static const Color navyDark = Color(0xFF13104A);
  static const Color celeste = Color(0xFF6366F1);    // ahora es indigo

  // --- Superficies (dark theme) ---
  static const Color background = Color(0xFF0F0E1A);   // casi negro violáceo
  static const Color surface = Color(0xFF1A1830);      // card principal
  static const Color surfaceElevated = Color(0xFF221F3A); // card elevada
  static const Color surfaceAlt = Color(0xFF252245);   // card secundaria
  static const Color border = Color(0xFF2D2B4E);       // borde sutil
  static const Color borderLight = Color(0xFF3D3A5E);  // borde más visible

  // --- Texto ---
  static const Color textPrimary = Color(0xFFF1F0FF);    // casi blanco violáceo
  static const Color textSecondary = Color(0xFFA5A3C2);  // gris-violáceo medio
  static const Color textMuted = Color(0xFF6B6888);      // gris apagado
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Estados semánticos ---
  static const Color aprobado = Color(0xFF10B981);   // Emerald 500
  static const Color aprobadoLight = Color(0xFF6EE7B7); // Emerald 300
  static const Color reprobado = Color(0xFFF43F5E);  // Rose 500
  static const Color reprobadoLight = Color(0xFFFDA4AF); // Rose 300
  static const Color examen = Color(0xFFF59E0B);     // Amber 500
  static const Color examenLight = Color(0xFFFCD34D); // Amber 300
  static const Color info = Color(0xFF6366F1);

  // --- Acentos por categoría ---
  static const Color accentRed = Color(0xFFF43F5E);
  static const Color accentBlue = Color(0xFF6366F1);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Fondos de badges (glassmorphism suave)
  static const Color badgeRedBg = Color(0x33F43F5E);
  static const Color badgeBlueBg = Color(0x336366F1);
  static const Color badgePurpleBg = Color(0x338B5CF6);

  // --- Gradientes ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF2D1B69), Color(0xFF1E1B4B)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1830), Color(0xFF221F3A)],
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
  static const Color shadow = Color(0x660F0E1A);
  static const Color glowPrimary = Color(0x336366F1);

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x660F0E1A),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x1A6366F1),
          blurRadius: 40,
          offset: Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get primaryGlow => const [
        BoxShadow(
          color: Color(0x406366F1),
          blurRadius: 24,
          offset: Offset(0, 4),
        ),
      ];
}
