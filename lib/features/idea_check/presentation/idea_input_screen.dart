import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/idea_check_repository.dart';

class IdeaInputScreen extends StatefulWidget {
  const IdeaInputScreen({super.key});

  @override
  State<IdeaInputScreen> createState() => _IdeaInputScreenState();
}

class _IdeaInputScreenState extends State<IdeaInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ideaController = TextEditingController();
  final _locationController = TextEditingController();
  final _ideaRepo = IdeaCheckRepository();
  bool _isLoading = false;
  double _radiusKm = 2.0;

  // Default location (Jakarta center, user should change)
  final double _latitude = -6.2088;
  final double _longitude = 106.8456;

  @override
  void dispose() {
    _ideaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await _ideaRepo.analyzeIdea(
        inputText: _ideaController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationController.text.trim(),
        radiusKm: _radiusKm,
      );

      if (mounted) {
        context.push('/idea-check/result/${result.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cek Ide Bisnis'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Info card
                GlassCard(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Ceritakan ide bisnis dan lokasi yang kamu inginkan. Kami akan menganalisis kompetitor, tren, dan peluangmu.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // Idea input
                _buildSectionTitle(
                  'Ide Bisnis',
                  Icons.lightbulb_outline_rounded,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ideaController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Saya ingin menjual dessert box, minuman boba, atau warung bakso...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan jelaskan ide bisnismu';
                    }
                    if (value.length < 5) {
                      return 'Jelaskan lebih detail';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 24),

                // Location input
                _buildSectionTitle('Lokasi Usaha', Icons.location_on_outlined),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Jember, Malang, atau alamat lengkap...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location_rounded,
                            color: AppColors.primaryLight, size: 20),
                        onPressed: _useCurrentLocation,
                        tooltip: 'Gunakan lokasi saat ini',
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lokasi wajib diisi';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 8),

                // Coordinate display
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.pin_drop_outlined,
                          color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Koordinat: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Radius slider
                _buildSectionTitle(
                  'Radius Pencarian',
                  Icons.radar_rounded,
                ),
                const SizedBox(height: 10),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jarak dari titik lokasi',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_radiusKm.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.textMuted.withValues(alpha: 0.2),
                          thumbColor: AppColors.primaryLight,
                          overlayColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _radiusKm,
                          min: 0.5,
                          max: 5.0,
                          divisions: 9,
                          onChanged: (val) =>
                              setState(() => _radiusKm = val),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0.5 km',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          Text('5 km',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 32),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.scoreMedium.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.scoreMedium.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.scoreMedium, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hasil analisis berdasarkan data Google Maps & tren pencarian. Data mungkin tidak mencakup UMKM rumahan yang hanya jualan online. Gunakan sebagai perkiraan, bukan jaminan.',
                          style: TextStyle(
                            color: AppColors.scoreMedium.withValues(alpha: 0.9),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Analyze button
                GradientButton(
                  text: 'Analisis Ide Saya',
                  onPressed: _handleAnalyze,
                  isLoading: _isLoading,
                  icon: Icons.auto_awesome_rounded,
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _useCurrentLocation() {
    // In production, use geolocator package to get real GPS coordinates
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Fitur lokasi GPS akan tersedia setelah setup Google Maps API key'),
        backgroundColor: AppColors.surfaceDarkElevated,
      ),
    );
  }
}
