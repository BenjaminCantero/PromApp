import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promapp/features/asignaturas/application/asignatura_providers.dart';
import 'package:promapp/features/asignaturas/data/mock_asignatura_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simula SharedPreferences con el onboarding ya visto.
///
/// Sin esto, PromApp se queda esperando `onboardingDone()`
/// para siempre: el canal de plataforma no existe en `flutter test`.
void mockOnboardingVisto() {
  SharedPreferences.setMockInitialValues({'onboarding_done': true});
}

/// Repositorio en memoria (mock) en vez de la DB real.
final mockRepoOverride =
    asignaturaRepositoryProvider.overrideWith((ref) => MockAsignaturaRepository());

/// Overrides habituales para montar `PromApp` en pruebas de UI.
final testOverrides = [mockRepoOverride];
