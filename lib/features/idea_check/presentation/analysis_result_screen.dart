import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/market_meter.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
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
          // Ite thinking animation instead of generic spinner
          IteAvatar(pose: ItePose.thinking, size: 80)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 800.ms,
              ),
          const SizedBox(height: 24),
          Text(
            'Ite lagi riset buat kamu... 🔍',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ngecek kompetitor, tren, dan peluang pasar',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return MascotEmptyState(
      pose: ItePose.support,
      title: 'Waduh, ada gangguan 😅',
      subtitle: _error != null
          ? '$_error\n\nCoba cek koneksi internetmu dan tekan tombol di bawah ya!'
          : 'Coba periksa koneksi internetmu dan coba lagi.',
      action: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _loadResult();
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Coba Lagi'),
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
                      color: Colors.white, size: 20),
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

          const SizedBox(height: 16),

          // ── Mascot Reaction Strip — Ite reacts to opportunity score! ──
          MascotReaction.forScore(r.opportunityScore ?? 'sedang')
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms),

          const SizedBox(height: 16),

          // ── Market Meters (signature element!) ──
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
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
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

          const SizedBox(height: 16),

          // ── Recommendation (Ite's advice — most actionable!) ──
          if (r.recommendation != null)
            _buildIteAdvice(
              'Saran dari Ite 💡',
              r.recommendation!,
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

          _buildSection(
            'Seberapa Ramai Persaingan',
            Icons.groups_outlined,
            r.targetMarket['description'] ?? 'Data tidak tersedia',
          ).animate().fadeIn(delay: 420.ms, duration: 400.ms),

          _buildSection(
            'Peluang Beda dari yang Lain',
            Icons.star_outline_rounded,
            r.differentiationAnalysis ?? 'Data tidak tersedia',
          ).animate().fadeIn(delay: 480.ms, duration: 400.ms),

          _buildSection(
            'Risiko Tren Pasar',
            Icons.warning_amber_rounded,
            r.trendRisk ?? 'Data tidak tersedia',
            color: AppColors.scoreMedium,
          ).animate().fadeIn(delay: 540.ms, duration: 400.ms),

          // ── Competitors Map & List ──
          if (r.competitors.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (r.latitude != null && r.longitude != null)
              _buildCompetitorsMap(r).animate().fadeIn(delay: 600.ms, duration: 500.ms),
            
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
                    'Lihat ${r.competitors.length - 5} kompetitor lainnya 👀',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],

          // ── Disclaimer — Ite whispers ──
          const SizedBox(height: 16),
          const MascotSpeech(
            pose: ItePose.thinking,
            message:
                'Ini perkiraan berdasarkan data Google Maps & tren pencarian ya. UMKM rumahan yang online aja mungkin belum tercakup. Jadikan panduan, bukan patokan mutlak! 😉',
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Special "Ite's Advice" card — highlighted with mascot
  Widget _buildIteAdvice(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.03),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IteAvatar(pose: ItePose.celebrate, size: 28, showEntrance: false),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.secondary,
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

  Widget _buildCompetitorsMap(IdeaCheck r) {
    final center = LatLng(r.latitude!, r.longitude!);
    final radiusKm = r.radiusKm ?? 2.0;
    
    // Approximate zoom level
    double zoom = 14.0;
    if (radiusKm <= 1.0) zoom = 15.0;
    if (radiusKm >= 4.0) zoom = 13.0;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceLightElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.umkm.validasi_ide',
            ),
            MarkerLayer(
              markers: [
                // User Location
                Marker(
                  point: center,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                ),
                // Competitors (Bear Face)
                ...r.competitors
                    .where((c) => c['latitude'] != null && c['longitude'] != null)
                    .map((c) => Marker(
                          point: LatLng((c['latitude'] as num).toDouble(), (c['longitude'] as num).toDouble()),
                          width: 32,
                          height: 32,
                          child: Tooltip(
                            message: c['name'] ?? 'Kompetitor',
                            child: const IteAvatar(
                              pose: ItePose.greet,
                              size: 32,
                              showEntrance: false,
                            ),
                          ),
                        )),
              ],
            ),
          ],
        ),
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
      backgroundColor: AppColors.surfaceLightElevated,
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
