import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Shell principal: mantiene el estado de cada tab (StatefulShellRoute) y
/// muestra la barra de navegación inferior flotante.
///
/// ⚠️ No envolver `navigationShell` en un `AnimatedSwitcher` (ni en nada que
/// mantenga el hijo saliente y el entrante vivos a la vez): `navigationShell`
/// lleva una `GlobalKey` interna y tener dos instancias montadas rompe el
/// árbol con «Duplicate GlobalKey». Para animar el cambio de tab hay que
/// hacerlo dentro de `StatefulShellRoute.navigatorContainerBuilder`.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _items = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
    ),
    NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Ramos',
    ),
    NavItem(
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate_rounded,
      label: 'Calcular',
    ),
  ];

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
