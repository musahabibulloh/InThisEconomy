import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/market_gap_repository.dart';

class MarketGapScreen extends StatefulWidget {
  const MarketGapScreen({super.key});
  @override
  State<MarketGapScreen> createState() => _MarketGapScreenState();
}

class _MarketGapScreenState extends State<MarketGapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _repo = MarketGapRepository();
  bool _isLoading = false;
  double _radiusKm = 2.0;
  final double _latitude = -6.2088;
  final double _longitude = 106.8456;

  @override
  void dispose() { _locationController.dispose(); super.dispose(); }

  Future<void> _handleScan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await _repo.scanMarketGaps(
        latitude: _latitude, longitude: _longitude,
        locationName: _locationController.text.trim(), radiusKm: _radiusKm);
      if (mounted) context.push('/market-gap/result/${result.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Cari Celah Pasar'),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          GlassCard(
            gradient: LinearGradient(colors: [AppColors.secondary.withValues(alpha: 0.15), AppColors.secondary.withValues(alpha: 0.05)]),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.explore_outlined, color: AppColors.secondaryLight, size: 20)),
              const SizedBox(width: 14),
              Expanded(child: Text('Belum punya ide? Masukkan lokasi dan kami akan mencari kategori bisnis yang belum ada atau masih sedikit di area tersebut.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5))),
            ]),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Row(children: [
            Icon(Icons.location_on_outlined, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text('Lokasi Target', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(hintText: 'Contoh: Jl. Malioboro, Yogyakarta', prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted)),
            validator: (v) => v == null || v.isEmpty ? 'Lokasi wajib diisi' : null,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Icons.radar_rounded, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text('Radius: ${_radiusKm.toStringAsFixed(1)} km', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: AppColors.secondary, thumbColor: AppColors.secondaryLight, inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.2)),
            child: Slider(value: _radiusKm, min: 0.5, max: 5.0, divisions: 9, onChanged: (v) => setState(() => _radiusKm = v)),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
            color: AppColors.scoreMedium.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.scoreMedium.withValues(alpha: 0.2))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, color: AppColors.scoreMedium, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Minim pesaing tidak selalu berarti peluang bagus — bisa juga karena tidak ada permintaan. Hasil ditampilkan sebagai indikasi, bukan jaminan.',
                style: TextStyle(color: AppColors.scoreMedium.withValues(alpha: 0.9), fontSize: 11, height: 1.5))),
            ]),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 28),
          GradientButton(text: 'Pindai Celah Pasar', onPressed: _handleScan, isLoading: _isLoading, icon: Icons.explore_rounded,
            gradient: AppColors.accentGradient).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 40),
        ])))),
    );
  }
}
