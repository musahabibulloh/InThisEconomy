import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';

import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../../../core/widgets/rupiah_input.dart';
import '../data/market_gap_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MarketGapScreen extends StatefulWidget {
  const MarketGapScreen({super.key});
  @override
  State<MarketGapScreen> createState() => _MarketGapScreenState();
}

class _MarketGapScreenState extends State<MarketGapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _repo = MarketGapRepository();
  bool _isLoading = false;
  double _radiusKm = 2.0;
  double _latitude = -6.2088;
  double _longitude = 106.8456;
  bool _isLocating = false;
  int? _selectedPresetIndex;

  @override
  void dispose() {
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _handleScan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final budget = RupiahInputFormatter.parse(_budgetController.text);
      final result = await _repo.scanMarketGaps(
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationController.text.trim(),
        radiusKm: _radiusKm,
        userBudget: budget,
      );
      if (mounted) context.push('/market-gap/result/${result.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waduh, gagal memindai 😅 $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    // Memberikan feedback visual bahwa halaman direfresh
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _locationController.clear();
      _budgetController.clear();
      _radiusKm = 2.0;
      _selectedPresetIndex = null;
    });
  }

  void _selectPreset(int index, BudgetPreset preset) {
    setState(() {
      _selectedPresetIndex = index;
      _budgetController.text = preset.displayText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop()),
        title: const Text('Cari Celah Pasar'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.secondary,
          backgroundColor: AppColors.bgLightSecondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 12),

                // Ite explains the feature
                const MascotReaction(
                  pose: ItePose.market,
                  message:
                      'Belum punya ide? Gapapa! Ite pindai dulu area ini, siapa tau ada kategori bisnis yang belum digarap di sana 🔍',
                  highlighted: true,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.secondaryLight, size: 18),
                    const SizedBox(width: 8),
                    Text('Di Mana Mau Usaha?',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Jl. Malioboro, Yogyakarta',
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: AppColors.textMuted),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isLocating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryLight))
                          : IconButton(
                              icon: const Icon(Icons.my_location_rounded,
                                  color: AppColors.secondaryLight, size: 20),
                              onPressed: _useCurrentLocation,
                              tooltip: 'Pakai lokasi saat ini',
                            ),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Isi lokasi dulu supaya Ite bisa memindai area-nya 📍'
                      : null,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 8),

                // Coordinate display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                  ),
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
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── BUDGET INPUT (NEW) ──
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.secondaryLight, size: 18),
                    const SizedBox(width: 8),
                    Text('Modal yang Kamu Punya',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('opsional',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Ite bisa filter rekomendasi sesuai budget-mu 💰',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),

                // Budget text field with Rupiah formatter
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    RupiahInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Contoh: Rp 5.000.000',
                    prefixIcon: const Icon(Icons.payments_outlined,
                        color: AppColors.textMuted),
                  ),
                  onChanged: (_) {
                    // Clear preset selection when user types manually
                    if (_selectedPresetIndex != null) {
                      setState(() => _selectedPresetIndex = null);
                    }
                  },
                ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                const SizedBox(height: 10),

                // Quick-select preset chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: BudgetPreset.defaults.asMap().entries.map((entry) {
                    final index = entry.key;
                    final preset = entry.value;
                    final isSelected = _selectedPresetIndex == index;

                    return GestureDetector(
                      onTap: () => _selectPreset(index, preset),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary.withValues(alpha: 0.15)
                              : AppColors.surfaceLightElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textMuted.withValues(alpha: 0.15),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          preset.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Radius slider
                Row(
                  children: [
                    Icon(Icons.radar_rounded,
                        color: AppColors.secondaryLight, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Radius: ${_radiusKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.secondary,
                    thumbColor: AppColors.secondaryLight,
                    inactiveTrackColor:
                        AppColors.textMuted.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _radiusKm,
                    min: 0.5,
                    max: 5.0,
                    divisions: 9,
                    onChanged: (v) => setState(() => _radiusKm = v),
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 400.ms),
                const SizedBox(height: 16),

                // Disclaimer as Ite speech
                const MascotSpeech(
                  pose: ItePose.thinking,
                  message:
                      'Minim pesaing belum tentu peluang bagus — bisa juga karena belum ada permintaan. Hasil ini indikasi, bukan jaminan ya! 😉',
                ),

                const SizedBox(height: 28),
                GradientButton(
                  text: 'Pindai Celah di Sini 🔍',
                  onPressed: _handleScan,
                  isLoading: _isLoading,
                  icon: Icons.explore_rounded,
                  gradient: AppColors.accentGradient,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        ),
      ),
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
        const SnackBar(content: Text('Ite lagi cari lokasimu lewat satelit... 📡'), duration: Duration(seconds: 1)),
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
