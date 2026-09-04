import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/ite_avatar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    setState(() => _isLoading = true);
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) context.go('/login');
    }
  }

  Future<void> _requestLocationAndFinish() async {
    setState(() => _isLoading = true);
    try {
      await Geolocator.requestPermission();
    } catch (e) {
      // Ignore if it fails, we still want to proceed
    }
    await _checkAuth();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _requestLocationAndFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top (if not on last page)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < 4)
                    TextButton(
                      onPressed: () => _pageController.animateToPage(
                        4,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48), // Placeholder to maintain height
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                physics: const BouncingScrollPhysics(),
                children: [
                  // SLIDE 1: Perkenalan
                  _buildSlide(
                    visual: Image.asset(
                      'assets/perkenalan.png',
                      fit: BoxFit.contain,
                    ),
                    title: 'Ide kamu,\nSolusi nyata.',
                    subtitle: 'Temukan ide, dapatkan konsultasi, wujudkan bersama kami.',
                  ),

                  // SLIDE 2: Cek Ide
                  _buildSlide(
                    visual: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/cek ide.png',
                          fit: BoxFit.contain,
                        ),
                        // Mini visual of score
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.speed_rounded, color: AppColors.scoreHigh, size: 24),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Peluang', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    Text('Sangat Bagus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.scoreHigh)),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        ),
                      ],
                    ),
                    title: 'Jangan asal jualan,\ncek dulu peluangnya',
                    subtitle: 'Ketahui seberapa besar peluang sukses idemu sebelum mulai mengeluarkan modal.',
                  ),

                  // SLIDE 3: Peta Kompetitor
                  _buildSlide(
                    visual: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fake Map Background
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E9E2), // map-like color
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 4),
                            image: const DecorationImage(
                              image: AssetImage('assets/Celah Pasar.jpg'), // Fallback map-like image if available
                              fit: BoxFit.cover,
                              opacity: 0.5,
                            ),
                          ),
                        ),
                        // Bear Markers Mockup
                        Positioned(
                          top: 40, left: 60,
                          child: _buildMockMarker().animate().scale(delay: 200.ms, duration: 300.ms),
                        ),
                        Positioned(
                          bottom: 60, right: 80,
                          child: _buildMockMarker().animate().scale(delay: 400.ms, duration: 300.ms),
                        ),
                        Positioned(
                          top: 80, right: 50,
                          child: _buildMockMarker().animate().scale(delay: 600.ms, duration: 300.ms),
                        ),
                        // Center Ite looking around
                        const IteAvatar(pose: ItePose.market, size: 100),
                      ],
                    ),
                    title: 'Lihat langsung siapa saingan kamu di peta',
                    subtitle: 'Ite bantu cari tahu letak kompetitor di sekitarmu, biar kamu bisa curi celah pasar yang kosong.',
                  ),

                  // SLIDE 4: Konsultasi & Produk
                  _buildSlide(
                    visual: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/konsultasi.png',
                          fit: BoxFit.contain,
                        ),
                        // Floating camera icon
                        Positioned(
                          top: 40,
                          left: 40,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                          ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
                        ),
                      ],
                    ),
                    title: 'Bingung? Tanya aja.',
                    subtitle: 'Mulai dari konsultasi bisnis dengan AI sampai bikin foto produk super keren, semua ada di sini.',
                  ),

                  // SLIDE 5: Location Permission
                  _buildSlide(
                    visual: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const IteAvatar(pose: ItePose.greet, size: 160),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Kami butuh lokasi kamu buat cek siapa saja saingan di sekitar 📍',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms).fadeIn(),
                      ],
                    ),
                    title: 'Siap mulai perjalanan bisnismu?',
                    subtitle: 'Satu langkah lagi untuk melihat peluang pasarmu. Jangan lupa izinkan lokasi ya!',
                  ),
                ],
              ),
            ),

            // Bottom Navigation and Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next / Finish Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _currentPage == 4 ? 'Beri Akses & Mulai' : 'Lanjut',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  if (_currentPage == 4) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _checkAuth,
                      child: const Text(
                        'Nanti saja',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required Widget visual,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(child: visual),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.displayFont(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMarker() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset('assets/icons/market_mind_logo.png', fit: BoxFit.contain),
      ),
    );
  }
}
