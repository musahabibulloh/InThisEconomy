import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Colorful blobs for Glassmorphism background refraction
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Blur the blobs to create a smooth mesh gradient effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          // Main content on top
          navigationShell,
        ],
      ),
      extendBody: true, // Allows body to scroll under the transparent nav bar
      bottomNavigationBar: _GlassBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Floating glass navigation bar — frosted white, hovering above content
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow(0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.glassShadow(0.04),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.glassWhite(0.4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.glassBorder(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, 'assets/icons/ite_dashboard.svg', 'Beranda'),
                _buildNavItem(1, 'assets/icons/ite_market.svg', 'Pasar'),
                _buildCenterItem(2, 'assets/icons/ite_idea.svg'),
                _buildNavItem(3, 'assets/icons/ite_chat.svg', 'AI Chat'),
                _buildNavItem(4, 'assets/icons/ite_camera.svg', 'Produk'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, dynamic iconDataOrPath, String label) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.textMuted;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator: a sliding glass pill
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
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            ),
            iconDataOrPath is IconData
                ? Icon(
                    iconDataOrPath,
                    color: color,
                    size: 24,
                  ).animate(target: isActive ? 1 : 0).scale(
                      end: const Offset(1.1, 1.1),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    )
                : SvgPicture.asset(
                    iconDataOrPath as String,
                    width: 26,
                    height: 26,
                  ).animate(target: isActive ? 1 : 0).scale(
                      end: const Offset(1.15, 1.15),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, dynamic iconDataOrPath) {
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
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: (iconDataOrPath is IconData
                  ? Icon(
                      iconDataOrPath,
                      color: Colors.white,
                      size: 28,
                    )
                  : SvgPicture.asset(
                      iconDataOrPath as String,
                      width: 38,
                      height: 38,
                    ))
              .animate(target: isActive ? 1 : 0)
              .rotate(end: 0.05, duration: 300.ms) // Subtle playful tilt
              .scale(end: const Offset(1.15, 1.15), duration: 200.ms),
        ),
      ),
    );
  }
}
