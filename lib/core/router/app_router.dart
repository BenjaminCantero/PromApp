import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/asignaturas/presentation/asignatura_config_screen.dart';
import '../../features/asignaturas/presentation/asignatura_detalle_screen.dart';
import '../../features/asignaturas/presentation/asignaturas_screen.dart';
import '../../features/auth/presentation/perfil_screen.dart';
import '../../features/auth/presentation/privacidad_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/herramientas/presentation/calculadora_libre_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Rutas de la app.
abstract class AppRoutes {
  static const dashboard = '/';
  static const asignaturas = '/asignaturas';
  static const resumen = '/resumen';

  // Full-screen (sobre el shell)
  static const asignaturaNueva = '/asignatura/nueva';
  static const perfil = '/perfil';
  static const privacidad = '/privacidad';
  static String asignaturaDetalle(String id) => '/asignatura/$id';
  static String asignaturaEditar(String id) => '/asignatura/$id/editar';
}

/// Router raíz de PromApp.
///
/// - `StatefulShellRoute` → 3 tabs con stack independiente (bottom nav).
/// - Rutas de nivel superior (detalle / configuración) → se abren en el
///   navigator raíz, cubriendo el bottom nav (full-screen).
///
/// Es un **provider** y no un singleton global a propósito: el router crea
/// `GlobalKey`s internas (navigator raíz y shell de tabs). Si se comparten
/// entre montajes del árbol —al cambiar de sesión (login ↔ app) o entre
/// pruebas— Flutter lanza «Duplicate GlobalKey». Con un provider, cada
/// `ProviderScope` obtiene un router con claves propias.
final goRouterProvider = Provider<GoRouter>((ref) => _crearRouter());

GoRouter _crearRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) =>
                    const CalculadoraLibreScreen(showBackButton: false),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.resumen,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.asignaturas,
                builder: (context, state) => const AsignaturasScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- Full-screen ---
      GoRoute(
        path: AppRoutes.asignaturaNueva,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AsignaturaConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.perfil,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacidad,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PrivacidadScreen(),
      ),
      GoRoute(
        path: '/asignatura/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            AsignaturaDetalleScreen(asignaturaId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'editar',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => AsignaturaConfigScreen(
              asignaturaId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
    ],
  );
}
