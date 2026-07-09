import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Shell principal: mantiene el estado de cada tab (StatefulShellRoute) y
/// muestra la barra de navegación inferior flotante.
///
/// Usa fade manual con AnimationController para evitar el bug de
/// GlobalKey duplicada que ocurre con AnimatedSwitcher + KeyedSubtree.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    value: 1.0,
  );

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap(int index) async {
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }
    // Fade out → cambiar tab → fade in
    await _fadeCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeIn,
    );
    if (!mounted) return;
    widget.navigationShell.goBranch(index);
    await _fadeCtrl.animateTo(
      1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: AppBottomNav(
        items: _items,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
