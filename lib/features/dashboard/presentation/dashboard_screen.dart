import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../../auth/data/auth_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authRepo = AuthRepository();
  String _userName = '';

  // Rotating playful greetings
  static const _greetings = [
    'Hari ini mau riset apa nih? 🔍',
    'Yuk cek peluang baru bareng Ite! 🐻',
    'Siap validasi ide bisnis hari ini? 💡',
    'Ada ide seru? Ite bantu cek! 🚀',
  ];

  late String _greeting;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _greeting = _greetings[DateTime.now().minute % _greetings.length];
  }

  Future<void> _loadProfile() async {
    final profile = await _authRepo.getProfile();
    if (mounted) {
      setState(() {
        final fullName = profile?['display_name'] ??
            _authRepo.currentUser?.email?.split('@').first ??
            'User';
        _userName = fullName.split(' ').first;
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
          backgroundColor: AppColors.bgLightSecondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header with Ite ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Halo, $_userName!',
                              style: AppTheme.displayFont(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const IteAvatar(
                              pose: ItePose.greet,
                              size: 30,
                              showEntrance: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _greeting,
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
                      color: AppColors.glassWhite(0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.glassBorder(),
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

              // ── Fitur Aplikasi ──
              Text(
                'Mau ngapain hari ini?',
                style: AppTheme.displayFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ModuleCard(
                      title: 'Cek Ide Bisnis',
                      subtitle: 'Validasi ide dengan data pasar',
                      pose: ItePose.idea,
                      onTap: () => context.push('/idea-check'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModuleCard(
                      title: 'Cari Celah Pasar',
                      subtitle: 'Temukan peluang bisnis baru',
                      pose: ItePose.market,
                      onTap: () => context.push('/market-gap'),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ModuleCard(
                      title: 'Konsultasi AI',
                      subtitle: 'Curhat bisnis sama Ite',
                      pose: ItePose.chat,
                      onTap: () => context.push('/ai-chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModuleCard(
                      title: 'Studio Foto',
                      subtitle: 'Percantik foto produkmu',
                      pose: ItePose.camera,
                      onTap: () => context.push('/product-photo'),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),

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
                            'Intip lagi hasil cek ide bisnismu',
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
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Aktivitas',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
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
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                  'Konsultasi', '—', Icons.chat_bubble_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem('Foto', '—', Icons.camera_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    const textColor = Colors.white;
    return Column(
      children: [
        Icon(icon, color: textColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.displayFont(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Module card with Ite mascot icon for each feature.
class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final ItePose pose;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.pose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IteAvatar(pose: pose, size: 36, showEntrance: false),
          const SizedBox(height: 10),
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
