import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../../auth/data/auth_repository.dart';
import '../../idea_check/data/idea_check_repository.dart';
import '../../market_gap/data/market_gap_repository.dart';
import '../../ai_chat/data/chat_repository.dart';
import '../../product_photo/data/photo_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authRepo = AuthRepository();
  String _userName = '';
  
  // Stats
  int _ideaChecksCount = 0;
  int _consultationCount = 0;
  int _photoCount = 0;
  bool _isLoadingStats = true;

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
    _loadAllData();
    _greeting = _greetings[DateTime.now().minute % _greetings.length];
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadProfile(),
      _loadStats(),
    ]);
  }

  Future<void> _loadStats() async {
    try {
      final ideaCount = (await IdeaCheckRepository().getHistory()).length;
      final gapCount = (await MarketGapRepository().getHistory()).length;
      final chatCount = (await ChatRepository().getSessions()).length;
      final photoCount = (await PhotoRepository().getPhotos()).length;

      if (mounted) {
        setState(() {
          _ideaChecksCount = ideaCount + gapCount;
          _consultationCount = chatCount;
          _photoCount = photoCount;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
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
          onRefresh: _loadAllData,
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
                  // Notification bell
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
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

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _ModuleCard(
                    title: 'Cek Ide',
                    subtitle: 'Validasi ide kamu',
                    imagePath: 'assets/Cek Ide.jpg',
                    bgColor: AppColors.primary,
                    onTap: () => context.push('/idea-check'),
                  ),
                  _ModuleCard(
                    title: 'Celah Pasar',
                    subtitle: 'Temukan peluang',
                    imagePath: 'assets/Celah Pasar.jpg',
                    bgColor: AppColors.scoreMedium,
                    onTap: () => context.push('/market-gap'),
                  ),
                  _ModuleCard(
                    title: 'Konsultasi',
                    subtitle: 'Diskusi dengan ahli',
                    imagePath: 'assets/Konsultasi.jpg',
                    bgColor: AppColors.secondary,
                    onTap: () => context.push('/ai-chat'),
                  ),
                  _ModuleCard(
                    title: 'Studio Foto',
                    subtitle: 'Foto produkmu',
                    imagePath: 'assets/Studio Foto.jpg',
                    bgColor: AppColors.scoreHigh,
                    onTap: () => context.push('/product-photo'),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),

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
                  'Ide Dicek', 
                  _isLoadingStats ? '-' : _ideaChecksCount.toString(), 
                  Icons.lightbulb_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                  'Konsultasi', 
                  _isLoadingStats ? '-' : _consultationCount.toString(), 
                  Icons.chat_bubble_outline),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                  'Foto', 
                  _isLoadingStats ? '-' : _photoCount.toString(), 
                  Icons.camera_alt_outlined),
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
  final ItePose? pose;
  final String? imagePath;
  final VoidCallback onTap;
  final Color bgColor;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    this.pose,
    this.imagePath,
    required this.onTap,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imagePath != null
                        ? Image.asset(
                            imagePath!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: IteAvatar(
                              pose: pose ?? ItePose.idea,
                              size: 50,
                              showEntrance: false,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
