import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../application/auth_controller.dart';
import '../data/auth_repository.dart';

/// Pantalla de acceso: alterna entre **Iniciar sesión** y **Crear cuenta**.
///
/// Al autenticar con éxito, `AuthController` actualiza la sesión y el
/// `AuthGate` (en app.dart) reemplaza esta pantalla por la app.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _esRegistro = false;
  bool _cargando = false;
  bool _verPassword = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _cambiarModo() {
    setState(() {
      _esRegistro = !_esRegistro;
      _error = null;
    });
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final auth = ref.read(authControllerProvider.notifier);
      if (_esRegistro) {
        await auth.register(
          nombre: _nombre.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await auth.login(_email.text, _password.text);
      }
      // En éxito no hacemos nada: el AuthGate cambia de pantalla solo.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _logo(),
                    const SizedBox(height: AppDimensions.xxl),
                    Text(
                      _esRegistro ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                      style: AppTypography.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      _esRegistro
                          ? 'Empieza a calcular tus promedios'
                          : 'Ingresa para ver tus ramos',
                      style: AppTypography.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.xxl),
                    if (_esRegistro) ...[
                      _campo(
                        controller: _nombre,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Ingresa tu nombre'
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                    ],
                    _campo(
                      controller: _email,
                      label: 'Correo',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Ingresa tu correo';
                        if (!s.contains('@') || !s.contains('.')) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _campo(
                      controller: _password,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscure: !_verPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppDimensions.lg),
                      _bannerError(_error!),
                    ],
                    const SizedBox(height: AppDimensions.xl),
                    _botonPrincipal(),
                    const SizedBox(height: AppDimensions.lg),
                    _toggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: AppColors.primaryGlow,
          ),
          child: const Icon(Icons.school_rounded,
              color: AppColors.textOnPrimary, size: 38),
        ),
        const SizedBox(height: AppDimensions.md),
        Text('PromApp', style: AppTypography.h2),
      ],
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: AppTypography.body,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _bannerError(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.badgeRedBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.reprobado, size: 18),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              mensaje,
              style: AppTypography.body.copyWith(color: AppColors.reprobadoLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonPrincipal() {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: _cargando ? null : AppColors.primaryGlow,
        ),
        child: ElevatedButton(
          onPressed: _cargando ? null : _enviar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: _cargando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Text(
                  _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                  style: AppTypography.button
                      .copyWith(color: AppColors.textOnPrimary),
                ),
        ),
      ),
    );
  }

  Widget _toggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _esRegistro ? '¿Ya tienes cuenta?' : '¿No tienes cuenta?',
          style: AppTypography.bodySecondary,
        ),
        TextButton(
          onPressed: _cargando ? null : _cambiarModo,
          child: Text(
            _esRegistro ? 'Inicia sesión' : 'Regístrate',
            style: AppTypography.bodyBold.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
