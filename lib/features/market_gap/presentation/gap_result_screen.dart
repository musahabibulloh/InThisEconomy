import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/market_gap_repository.dart';
import '../domain/market_gap_model.dart';

class GapResultScreen extends StatefulWidget {
  final String scanId;
  const GapResultScreen({super.key, required this.scanId});
  @override
  State<GapResultScreen> createState() => _GapResultScreenState();
}

class _GapResultScreenState extends State<GapResultScreen> {
  final _repo = MarketGapRepository();
  MarketGapScan? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _repo.getById(widget.scanId);
      if (mounted) {
        setState(() {
          _result = r;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop()),
        title: const Text('Celah Pasar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _result == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text('Data tidak ditemukan',
                          style: AppTheme.displayFont(
                              fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('Coba pindai ulang dengan lokasi yang berbeda.',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location header
                      GlassCard(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.03),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.explore_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hasil Pemindaian',
                                    style: AppTheme.displayFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '📍 ${_result!.locationName ?? "Lokasi"} • Radius ${_result!.radiusKm} km',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 20),
                      Text(
                        'Kategori yang Masih Terbuka',
                        style: AppTheme.displayFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diurutkan berdasarkan potensi peluang',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      if (_result!.gapCategories.isEmpty)
                        GlassCard(
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.sentiment_neutral_rounded,
                                    color: AppColors.textMuted, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ditemukan celah pasar di area ini',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Coba perluas radius atau pindah lokasi',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._result!.gapCategories
                            .asMap()
                            .entries
                            .map((e) => _gapTile(e.key, e.value)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _gapTile(int index, GapCategory gap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTheme.displayFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gap.category,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.scoreHigh.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(gap.score * 100).toInt()}%',
                    style: AppTheme.displayFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.scoreHigh,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              gap.reason,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoChip(
                    '${gap.competitorCount} kompetitor', Icons.store_outlined),
                _infoChip(gap.areaDensity, Icons.density_small_rounded),
                if (gap.estimatedCapital != null)
                  _infoChip(gap.estimatedCapital!, Icons.payments_outlined),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 100 + index * 80), duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _infoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
