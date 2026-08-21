import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../config/app_colors.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true, // Allows body to scroll under the transparent nav bar
      bottomNavigationBar: _PasarSoreBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
      ),
    );
  }
}

class _PasarSoreBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PasarSoreBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Signature: Glassmorphism base with floating central action
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.textMuted.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.space_dashboard_rounded, 'Beranda'),
                _buildNavItem(1, Icons.explore_rounded, 'Pasar'),
                _buildCenterItem(2, Icons.lightbulb_rounded),
                _buildNavItem(3, Icons.chat_bubble_rounded, 'AI Chat'),
                _buildNavItem(4, Icons.camera_alt_rounded, 'Foto'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primaryLight : AppColors.textMuted;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Signature interaction: Active indicator dot slides in
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 4,
              width: isActive ? 16 : 0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            ),
            Icon(
              icon,
              color: color,
              size: 24,
            ).animate(target: isActive ? 1 : 0).scale(
                  end: const Offset(1.1, 1.1),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, IconData icon) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF1B2838), // Dark contrast icon
            size: 28,
          )
              .animate(target: isActive ? 1 : 0)
              .rotate(end: 0.05, duration: 300.ms) // Subtle playful tilt
              .scale(end: const Offset(1.1, 1.1), duration: 200.ms),
        ),
      ),
    );
  }
}
