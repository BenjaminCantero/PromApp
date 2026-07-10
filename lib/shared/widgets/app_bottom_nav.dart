import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

/// Item de navegación de la barra inferior.
class NavItem {
  const NavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Barra de navegación inferior flotante de PromApp — Premium Dark Edition.
///
/// Glassmorphism con blur, pill activo con gradiente indigo → violet.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.xl,
        0,
        AppDimensions.xl,
        MediaQuery.of(context).padding.bottom + (AppDimensions.xl * 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x800F0E1A),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x206366F1),
                  blurRadius: 16,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.sm - 2,
              ),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                boxShadow: selected ? AppColors.primaryGlow : null,
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                size: 20,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
