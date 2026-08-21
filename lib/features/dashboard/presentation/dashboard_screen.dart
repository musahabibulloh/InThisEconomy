import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/data/auth_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authRepo = AuthRepository();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _authRepo.getProfile();
    if (mounted) {
      setState(() {
        _userName = profile?['display_name'] ??
            _authRepo.currentUser?.email?.split('@').first ??
            'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $_userName! 👋',
                          style: AppTheme.displayFont(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mau validasi ide bisnis apa hari ini?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Logout button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.textMuted.withValues(alpha: 0.15),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () async {
                        await _authRepo.signOut();
                        if (context.mounted) context.go('/login');
                      },
                      tooltip: 'Keluar',
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.1, end: 0),

              const SizedBox(height: 28),

              // ── Stats Card (activity overview) ──
              _buildStatsCard(context)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 28),

              // ── Primary Module (Cek Ide Bisnis — bigger card) ──
              Text(
                'Fitur Utama',
                style: AppTheme.displayFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 12),

              _PrimaryModuleCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Cek Ide Bisnis',
                subtitle:
                    'Punya ide bisnis? Cek dulu peluang, persaingan, dan tren pasarnya dengan data nyata sebelum kamu keluar modal.',
                gradient: AppColors.primaryGradient,
                onTap: () => context.push('/idea-check'),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: 20),

              // ── Supporting Modules ──
              Text(
                'Fitur Pendukung',
                style: AppTheme.displayFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

              const SizedBox(height: 12),

              // Two-column layout for supporting modules
              Row(
                children: [
                  Expanded(
                    child: _SupportModuleCard(
                      icon: Icons.explore_outlined,
                      title: 'Cari Celah Pasar',
                      subtitle: 'Belum punya ide? Temukan peluang di sekitarmu',
                      color: AppColors.secondary,
                      onTap: () => context.push('/market-gap'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SupportModuleCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Konsultasi AI',
                      subtitle: 'Tanya AI tentang ide bisnismu',
                      color: AppColors.primaryLight,
                      onTap: () => context.push('/ai-chat'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.15, end: 0),

              const SizedBox(height: 12),

              _ModuleCard(
                icon: Icons.camera_alt_outlined,
                title: 'Cek Produk',
                subtitle:
                    'Foto produk → hapus background → siap untuk marketplace',
                gradient: AppColors.dangerGradient,
                onTap: () => context.push('/product-photo'),
                delay: 500,
              ),

              const SizedBox(height: 16),

              // ── History quick access ──
              GlassCard(
                onTap: () => context.push('/idea-check/history'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppColors.primaryLight,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Analisis',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Lihat semua hasil cek ide bisnismu',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded,
                  color: Color(0xFF1B2838), size: 18),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Aktivitas',
                style: TextStyle(
                  color: const Color(0xFF1B2838).withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Ide Dicek', '—', Icons.lightbulb_outline),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFF1B2838).withValues(alpha: 0.2),
              ),
              _buildStatItem(
                  'Konsultasi', '—', Icons.chat_bubble_outline),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFF1B2838).withValues(alpha: 0.2),
              ),
              _buildStatItem('Foto', '—', Icons.camera_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    const darkColor = Color(0xFF1B2838);
    return Column(
      children: [
        Icon(icon, color: darkColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.displayFont(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: darkColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: darkColor.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Large hero card for the primary module (Cek Ide Bisnis).
/// Visually bigger and more prominent than supporting modules.
class _PrimaryModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _PrimaryModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF1B2838), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.displayFont(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⭐ Fitur Andalan',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact square card for supporting modules in 2-column layout.
class _SupportModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Standard row-based module card for tertiary features.
class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final int delay;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideX(begin: 0.15, end: 0);
  }
}
