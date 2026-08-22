import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/idea_check_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  double _latitude = -6.2088;
  double _longitude = 106.8456;
  bool _isLocating = false;

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
            content: Text('Gagal menganalisis: ${e.toString()}'),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
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
                          'Ceritakan ide bisnismu dan pilih lokasi. Kami cek kompetitor, tren, dan peluangmu di sana.',
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
                  'Ide Bisnis Kamu',
                  Icons.lightbulb_outline_rounded,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ideaController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Jualan dessert box, warung bakso, laundry kiloan...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tulis ide bisnismu dulu, ya';
                    }
                    if (value.length < 5) {
                      return 'Coba jelaskan lebih detail biar hasilnya lebih akurat';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),

                const SizedBox(height: 24),

                // Location input
                _buildSectionTitle('Di Mana Lokasinya?', Icons.location_on_outlined),
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                        child: _isLocating 
                           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight))
                           : IconButton(
                               icon: const Icon(Icons.my_location_rounded,
                                   color: AppColors.primaryLight, size: 20),
                               onPressed: _useCurrentLocation,
                               tooltip: 'Pakai lokasi saat ini',
                             ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi lokasi supaya kami bisa cek kompetitor di sekitarnya';
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
                  'Seberapa Jauh Mau Dicek?',
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
                            'Radius dari titik lokasi',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_radiusKm.toStringAsFixed(1)} km',
                              style: AppTheme.displayFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
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
                              AppColors.textMuted.withValues(alpha: 0.15),
                          thumbColor: AppColors.primaryLight,
                          overlayColor:
                              AppColors.primary.withValues(alpha: 0.12),
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

                const SizedBox(height: 28),

                // Disclaimer — honest, not scary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textMuted.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hasil berdasarkan data Google Maps & tren pencarian. UMKM rumahan yang hanya online mungkin belum tercakup — jadikan ini panduan, bukan jaminan.',
                          style: TextStyle(
                            color: AppColors.textMuted,
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
                  text: 'Cek Peluang di Sini',
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

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan Lokasi (GPS) tidak aktif.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin akses lokasi ditolak.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Silakan ubah di pengaturan HP.');
      } 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengambil koordinat satelit...'), duration: Duration(seconds: 1)),
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Reverse geocoding to get city name
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(_latitude, _longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final locationStr = [place.subLocality, place.locality, place.subAdministrativeArea]
              .where((e) => e != null && e.isNotEmpty)
              .join(', ');
          if (locationStr.isNotEmpty) {
            _locationController.text = locationStr;
          } else {
             _locationController.text = 'Lokasi Terdeteksi';
          }
        }
      } catch (e) {
        _locationController.text = '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}';
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }
}
