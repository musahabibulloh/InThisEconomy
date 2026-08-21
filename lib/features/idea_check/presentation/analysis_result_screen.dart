import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/market_meter.dart';
import '../data/idea_check_repository.dart';
import '../domain/idea_check_model.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String analysisId;
  const AnalysisResultScreen({super.key, required this.analysisId});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final _repo = IdeaCheckRepository();
  IdeaCheck? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final result = await _repo.getById(widget.analysisId);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
        title: const Text('Hasil Analisis'),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF1B2838), size: 36),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 800.ms,
              ),
          const SizedBox(height: 24),
          Text(
            'Menganalisis ide bisnismu...',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Memeriksa kompetitor, tren, dan peluang pasar',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.accent, size: 48),
            const SizedBox(height: 16),
            Text('Gagal memuat hasil',
                style: AppTheme.displayFont(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba periksa koneksi internetmu dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadResult();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final r = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Header: idea + location ──
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
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: Color(0xFF1B2838), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.productCategory ?? r.inputText ?? 'Ide Bisnis',
                        style: AppTheme.displayFont(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (r.locationName != null)
                        Text(
                          '📍 ${r.locationName}',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // ── Market Meters (signature element!) ──
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MarketMeter(
                  score: r.opportunityScore ?? '—',
                  label: 'Peluang',
                  icon: Icons.trending_up_rounded,
                  size: 100,
                ),
                MarketMeter(
                  score: r.competitionScore ?? '—',
                  label: 'Persaingan',
                  icon: Icons.people_outline_rounded,
                  size: 100,
                ),
                MarketMeter(
                  score: r.demandScore ?? '—',
                  label: 'Permintaan',
                  icon: Icons.shopping_bag_outlined,
                  size: 100,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 500.ms),

          const SizedBox(height: 16),

          // ── Recommendation (most actionable — shown first!) ──
          if (r.recommendation != null)
            _buildSection(
              'Yang Bisa Kamu Lakukan',
              Icons.tips_and_updates_outlined,
              r.recommendation!,
              color: AppColors.secondary,
              isHighlighted: true,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          _buildSection(
            'Seberapa Ramai Persaingan',
            Icons.groups_outlined,
            r.targetMarket['description'] ?? 'Data tidak tersedia',
          ).animate().fadeIn(delay: 380.ms, duration: 400.ms),

          _buildSection(
            'Peluang Beda dari yang Lain',
            Icons.star_outline_rounded,
            r.differentiationAnalysis ?? 'Data tidak tersedia',
          ).animate().fadeIn(delay: 440.ms, duration: 400.ms),

          _buildSection(
            'Risiko Tren Pasar',
            Icons.warning_amber_rounded,
            r.trendRisk ?? 'Data tidak tersedia',
            color: AppColors.scoreMedium,
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

          // ── Competitors ──
          if (r.competitors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kompetitor Terdekat',
                  style: AppTheme.displayFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${r.competitors.length} ditemukan',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...r.competitors
                .take(5)
                .map((c) => _competitorTile(c)),
            if (r.competitors.length > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    _showAllCompetitors(r.competitors);
                  },
                  child: Text(
                    'Lihat ${r.competitors.length - 5} kompetitor lainnya',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],

          // ── Disclaimer ──
          const SizedBox(height: 16),
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
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textMuted, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ini perkiraan berdasarkan data Google Maps & tren pencarian. UMKM rumahan yang hanya jualan online mungkin belum tercakup. Jadikan panduan, bukan patokan mutlak.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    String content, {
    Color? color,
    bool isHighlighted = false,
  }) {
    final sectionColor = color ?? AppColors.primaryLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        gradient: isHighlighted
            ? LinearGradient(
                colors: [
                  sectionColor.withValues(alpha: 0.1),
                  sectionColor.withValues(alpha: 0.03),
                ],
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: sectionColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: sectionColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _competitorTile(Map<String, dynamic> c) {
    final rating = (c['rating'] as num?)?.toDouble() ?? 0;
    final ratingColor = rating >= 4
        ? AppColors.scoreHigh
        : rating >= 3
            ? AppColors.scoreMedium
            : AppColors.scoreLow;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ratingColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  rating > 0 ? rating.toStringAsFixed(1) : '—',
                  style: AppTheme.displayFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ratingColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((c['address'] ?? '').isNotEmpty)
                    Text(
                      c['address'],
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCompetitors(List<Map<String, dynamic>> competitors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDarkSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Semua Kompetitor (${competitors.length})',
                style: AppTheme.displayFont(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: competitors.length,
                itemBuilder: (_, i) => _competitorTile(competitors[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
