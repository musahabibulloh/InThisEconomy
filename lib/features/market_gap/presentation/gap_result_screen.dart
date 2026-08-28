import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../../../core/widgets/competitor_map.dart';
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
  final _rupiahFormat = NumberFormat.decimalPattern('id');

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

  String _formatRupiah(int value) {
    return 'Rp ${_rupiahFormat.format(value)}';
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IteAvatar(pose: ItePose.thinking, size: 64)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 800.ms),
                  const SizedBox(height: 16),
                  Text('Ite lagi pindai area-nya... 🔍', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : _result == null
              ? MascotEmptyState(
                  pose: ItePose.support,
                  title: 'Data tidak ditemukan 😅',
                  subtitle: 'Coba pindai ulang dengan lokasi yang berbeda ya!',
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
                                  if (_result!.userBudget != null && _result!.userBudget! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet_outlined,
                                              size: 12, color: AppColors.secondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Modal: ${_formatRupiah(_result!.userBudget!)}',
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // Ite reaction based on results
                      MascotReaction(
                        pose: _result!.gapCategories.isNotEmpty ? ItePose.celebrate : ItePose.support,
                        message: _result!.gapCategories.isNotEmpty
                            ? 'Wah, Ite nemu ${_result!.gapCategories.length} kategori potensi di sini${_result!.userBudget != null && _result!.userBudget! > 0 ? " yang sudah disesuaikan dengan modalmu!" : "!"} Cek satu-satu ya 🎉'
                            : 'Hmm, area ini udah sangat padat kompetitor${_result!.userBudget != null && _result!.userBudget! > 0 ? " dan belum ada yang pas dengan budgetmu" : ""}. Coba perluas radius atau geser lokasi sedikit ya! 💪',
                        highlighted: _result!.gapCategories.isNotEmpty,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Kategori yang Masih Terbuka',
                        style: AppTheme.displayFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _result!.userBudget != null && _result!.userBudget! > 0
                            ? 'Diurutkan berdasarkan kecocokan modal & peluang'
                            : 'Diurutkan berdasarkan potensi peluang',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      if (_result!.gapCategories.isEmpty)
                        MascotEmptyState(
                          pose: ItePose.thinking,
                          title: 'Belum ketemu celah di area ini',
                          subtitle: 'Coba perluas radius atau pindah lokasi, siapa tau ada peluang di tempat lain! 🗺️',
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

            // ── Capital Match Badge (NEW — Jalur B only) ──
            if (gap.capitalMatchLabel != 'no_budget') ...[
              const SizedBox(height: 10),
              _capitalMatchBadge(gap),
            ],

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
                if (gap.estimatedCapitalMin > 0 && gap.estimatedCapitalMax > 0)
                  _infoChip(
                    '${_formatRupiah(gap.estimatedCapitalMin)} – ${_formatRupiah(gap.estimatedCapitalMax)}',
                    Icons.payments_outlined,
                  )
                else if (gap.estimatedCapital != null)
                  _infoChip(gap.estimatedCapital!, Icons.payments_outlined),
                if (gap.capitalSource == 'manual')
                  _infoChip('Data kurasi', Icons.verified_outlined)
                else if (gap.capitalSource == 'ai_estimate')
                  _infoChip('Estimasi AI', Icons.auto_awesome_outlined),
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

  /// Badge indicating how well user's budget matches this category.
  Widget _capitalMatchBadge(GapCategory gap) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (gap.capitalMatchLabel) {
      case 'sesuai':
        bgColor = AppColors.scoreHigh.withValues(alpha: 0.12);
        textColor = AppColors.scoreHigh;
        icon = Icons.check_circle_outline_rounded;
        label = 'Sesuai modal kamu ✅';
        break;
      case 'sedikit_kurang':
        bgColor = AppColors.scoreMedium.withValues(alpha: 0.12);
        textColor = AppColors.scoreMedium;
        icon = Icons.info_outline_rounded;
        label = 'Modal sedikit kurang, tapi bisa dipertimbangkan 🤔';
        break;
      case 'jauh_lebih_besar':
        bgColor = AppColors.scoreLow.withValues(alpha: 0.08);
        textColor = AppColors.scoreLow;
        icon = Icons.warning_amber_rounded;
        label = 'Butuh modal jauh lebih besar 💸';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
          Flexible(
            child: Text(text,
                style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
