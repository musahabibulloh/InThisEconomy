import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $_userName! 👋',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
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
                        color: AppColors.textMuted.withValues(alpha: 0.2),
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

              // Stats Card (quick overview)
              _buildStatsCard(context)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Module Cards
              Text(
                'Modul',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 12),

              // Module 1: Cek Ide Bisnis
              _ModuleCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Cek Ide Bisnis',
                subtitle: 'Validasi ide usahamu dengan data kompetitor & tren pasar nyata',
                gradient: AppColors.primaryGradient,
                onTap: () => context.push('/idea-check'),
                delay: 300,
              ),

              // Module 1B: Cari Celah Pasar
              _ModuleCard(
                icon: Icons.explore_outlined,
                title: 'Cari Celah Pasar',
                subtitle: 'Temukan peluang bisnis yang belum ada di sekitar lokasimu',
                gradient: AppColors.accentGradient,
                onTap: () => context.push('/market-gap'),
                delay: 400,
              ),

              // Module 2: Konsultasi AI
              _ModuleCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Konsultasi AI',
                subtitle: 'Tanya jawab tentang ide bisnismu dengan AI yang paham konteks',
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.secondaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.push('/ai-chat'),
                delay: 500,
              ),

              // Module 3: Cek Produk
              _ModuleCard(
                icon: Icons.camera_alt_outlined,
                title: 'Cek Produk',
                subtitle: 'Foto produk → hapus background → siap untuk marketplace',
                gradient: AppColors.dangerGradient,
                onTap: () => context.push('/product-photo'),
                delay: 600,
              ),

              const SizedBox(height: 20),

              // History quick access
              GlassCard(
                onTap: () => context.push('/idea-check/history'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
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
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),
            ],
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
            color: AppColors.primary.withValues(alpha: 0.35),
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
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Aktivitas',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Ide Dicek', '—', Icons.lightbulb_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _buildStatItem('Konsultasi', '—', Icons.chat_bubble_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _buildStatItem('Foto', '—', Icons.camera_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
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
                      fontSize: 16,
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
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideX(begin: 0.15, end: 0);
  }
}
