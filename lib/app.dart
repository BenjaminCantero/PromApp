import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/onboarding_screen.dart';

final onboardingProvider = FutureProvider<bool>((ref) async {
  return onboardingDone();
});

/// Widget raíz de PromApp: configura tema y decide
/// mostrar el onboarding (primera vez) o la app completa.
class PromApp extends ConsumerWidget {
  const PromApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    return onboarding.when(
      loading: () => _appBase(home: const _Splash()),
      error: (_, _) => _appBase(home: const _Splash()),
      data: (done) {
        if (!done) {
          return _appBase(
            home: OnboardingScreen(
              onFinish: () => ref.invalidate(onboardingProvider),
            ),
          );
        }
        
        final router = ref.watch(goRouterProvider);
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
        );
      },
    );
  }

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
