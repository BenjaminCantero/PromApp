import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Shell principal: mantiene el estado de cada tab (StatefulShellRoute) y
/// muestra la barra de navegación inferior flotante.
///
/// Añade una transición suave (fade + leve slide vertical) al cambiar de tab.
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

  int _prevIndex = 0;

  void _onTap(int index) {
    setState(() => _prevIndex = widget.navigationShell.currentIndex);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    // Dirección: hacia la derecha si el índice sube, hacia la izquierda si baja
    final goingRight = currentIndex > _prevIndex;
    final slideBegin = Offset(goingRight ? 0.04 : -0.04, 0.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final fadeAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          final slideAnim = Tween<Offset>(
            begin: slideBegin,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: child,
            ),
          );
        },
        // La key debe cambiar al cambiar de tab para que AnimatedSwitcher detecte el swap
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
