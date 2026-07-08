/// Tokens de espaciado, radios y tamaños fijos.
///
/// Usar siempre estas constantes en lugar de números mágicos.
class AppDimensions {
  AppDimensions._();

  // Espaciado (múltiplos de 4)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Radios
  static const double radiusSm = 10;
  static const double radiusMd = 16;   // radio estándar de cards
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // Padding de pantalla
  static const double screenPadding = 20;

  // Componentes
  static const double buttonHeight = 54;
  static const double inputHeight = 54;
  static const double bottomNavHeight = 72;
  static const double chartStroke = 16; // grosor del donut de promedio
}
