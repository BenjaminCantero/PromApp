/// Tokens de espaciado, radios y tamaños fijos.
///
/// Usar siempre estas constantes en lugar de números mágicos.
class AppDimensions {
  AppDimensions._();

  // Espaciado (múltiplos de 4)
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

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

  static const double chartStroke = 16; // grosor del donut de promedio
}
