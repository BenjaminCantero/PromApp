import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';

/// Widget raíz de PromApp: configura tema y decide, según la sesión, si
/// mostrar el login o la app completa (router con tabs).
class PromApp extends ConsumerWidget {
  const PromApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(authControllerProvider);

    return sesion.when(
      // Arrancando: validando el token guardado.
      loading: () => _appBase(home: const _Splash()),
      // Falla inesperada al arrancar → tratar como sin sesión.
      error: (_, _) => _appBase(home: const AuthScreen()),
      data: (user) => user == null
          ? _appBase(home: const AuthScreen())
          : MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: appRouter,
            ),
    );
  }

  /// MaterialApp sin router (para login / splash).
  Widget _appBase({required Widget home}) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: home,
      );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
