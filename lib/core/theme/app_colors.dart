import 'package:flutter/material.dart';

/// Paleta carbón cálido central de PromApp.
///
/// Tonos definidos para la identidad visual:
///   #242321 · #4A4743 · #80766D · #E5E1DC · #F3F0EC
class AppColors {
  AppColors._();

  // Paleta base cálida
  static const Color gray900 = Color(0xFF242321); // carbón
  static const Color gray700 = Color(0xFF4A4743); // grafito cálido
  static const Color gray500 = Color(0xFF80766D); // taupe
  static const Color gray200 = Color(0xFFE5E1DC); // fondo cálido
  static const Color gray100 = Color(0xFFF3F0EC); // superficie

  // Marca / primarios
  static const Color primary = gray900;
  static const Color primaryDark = gray900;
  static const Color primaryLight = gray700;
  static const Color accent = gray700;
  static const Color accentDark = gray900;

  // Alias conservados para componentes existentes
  static const Color ocean1 = gray900;
  static const Color ocean2 = gray700;
  static const Color ocean3 = gray500;
  static const Color ocean4 = gray200;
  static const Color ocean5 = gray100;
  static const Color navy = gray900;
  static const Color navyDark = gray900;
  static const Color celeste = gray700;

  // Superficies claras con un fondo ligeramente más sombrío
  static const Color background = gray200;
  static const Color surface = gray100;
  static const Color surfaceElevated = gray100;
  static const Color surfaceAlt = gray200;
  static const Color border = gray500;
  static const Color borderLight = gray700;

  // Texto
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray700;
  static const Color textMuted = gray700;
  static const Color textOnDark = gray100;
  static const Color textOnPrimary = gray100;

  // Estados semánticos para comunicar el resultado de las notas
  static const Color aprobado = Color(0xFF16A34A);
  static const Color aprobadoLight = Color(0xFF4ADE80);
  static const Color reprobado = Color(0xFFDC2626);
  static const Color reprobadoLight = Color(0xFFF87171);
  static const Color examen = Color(0xFFD49B00);
  static const Color examenLight = Color(0xFFFBBF24);
  static const Color info = gray700;

  // Acentos por categoría
  static const Color accentRed = reprobado;
  static const Color accentBlue = gray900;
  static const Color accentPurple = gray500;
  static const Color accentTeal = aprobado;
  static const Color accentAmber = examen;

  static const Color badgeRedBg = Color(0x33DC2626);
  static const Color badgeBlueBg = Color(0x33242321);
  static const Color badgePurpleBg = Color(0x3380766D);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gray900, gray700],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gray900, gray700, gray900],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gray200, gray100],
  );

  static const LinearGradient aprobadoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aprobado, aprobadoLight],
  );
  static const LinearGradient reprobadoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [reprobado, reprobadoLight],
  );

  static const Color shadow = Color(0x24242321);
  static const Color glowPrimary = Color(0x29242321);

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x18242321), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static List<BoxShadow> get primaryGlow => const [
    BoxShadow(color: Color(0x33242321), blurRadius: 20, offset: Offset(0, 4)),
  ];
}
