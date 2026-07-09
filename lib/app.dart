import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';

/// Widget raíz de PromApp: configura tema y decide, según la sesión, si
/// mostrar el onboarding (primera vez), el login o la app completa.
class PromApp extends ConsumerWidget {
  const PromApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(authControllerProvider);

    return sesion.when(
      loading: () => _appBase(home: const _Splash()),
      error: (_, _) => _appBase(home: const _AuthGate()),
      data: (user) => user == null
          ? _appBase(home: const _AuthGate())
          : Consumer(
              builder: (context, ref, _) {
                final router = ref.watch(goRouterProvider);
                return MaterialApp.router(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  routerConfig: router,
                );
              },
            ),
    );
  }

  Widget _appBase({required Widget home}) => MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: home,
      );
}

/// Decide si mostrar Onboarding o Login según SharedPreferences.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: onboardingDone(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return snap.data! ? const AuthScreen() : const OnboardingScreen();
      },
    );
  }
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
