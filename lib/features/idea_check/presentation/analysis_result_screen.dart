import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/score_badge.dart';
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
      if (mounted) setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Hasil Analisis'),
      ),
      body: _isLoading ? _buildLoading() : _error != null ? _buildError() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36)),
        const SizedBox(height: 24),
        Text('Menganalisis ide bisnismu...', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ]),
    );
  }

  Widget _buildError() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 48),
      const SizedBox(height: 16),
      Text('Gagal memuat hasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(_error ?? '', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadResult(); }, child: const Text('Coba Lagi')),
    ])));
  }

  Widget _buildContent() {
    final r = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        // Header
        GlassCard(
          gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.12), AppColors.primary.withValues(alpha: 0.04)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.productCategory ?? r.inputText ?? 'Ide Bisnis', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              if (r.locationName != null) Text('📍 ${r.locationName}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ])),
          ]),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        // Scores
        Row(children: [
          Expanded(child: ScoreBadge(label: 'Peluang', value: r.opportunityScore ?? '—', icon: Icons.trending_up_rounded)),
          const SizedBox(width: 10),
          Expanded(child: ScoreBadge(label: 'Persaingan', value: r.competitionScore ?? '—', icon: Icons.people_outline_rounded)),
          const SizedBox(width: 10),
          Expanded(child: ScoreBadge(label: 'Permintaan', value: r.demandScore ?? '—', icon: Icons.shopping_bag_outlined)),
        ]).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 16),
        // Recommendation
        if (r.recommendation != null) _buildSection('Rekomendasi', Icons.tips_and_updates_outlined, r.recommendation!, color: AppColors.secondary)
          .animate().fadeIn(delay: 250.ms, duration: 400.ms),
        _buildSection('Target Pasar', Icons.groups_outlined, r.targetMarket['description'] ?? 'Data tidak tersedia')
          .animate().fadeIn(delay: 350.ms, duration: 400.ms),
        _buildSection('Peluang Diferensiasi', Icons.star_outline_rounded, r.differentiationAnalysis ?? 'Data tidak tersedia')
          .animate().fadeIn(delay: 400.ms, duration: 400.ms),
        _buildSection('Risiko Tren', Icons.warning_amber_rounded, r.trendRisk ?? 'Data tidak tersedia', color: AppColors.scoreMedium)
          .animate().fadeIn(delay: 450.ms, duration: 400.ms),
        // Competitors
        if (r.competitors.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Kompetitor Terdekat (${r.competitors.length})', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          ...r.competitors.take(10).map((c) => _competitorTile(c)),
        ],
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildSection(String title, IconData icon, String content, {Color? color}) {
    return Container(margin: const EdgeInsets.only(bottom: 12), child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color ?? AppColors.primaryLight, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color ?? AppColors.primaryLight)),
      ]),
      const SizedBox(height: 10),
      Text(content, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
    ])));
  }

  Widget _competitorTile(Map<String, dynamic> c) {
    final rating = (c['rating'] as num?)?.toDouble() ?? 0;
    return Container(margin: const EdgeInsets.only(bottom: 8), child: GlassCard(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: (rating >= 4 ? AppColors.scoreHigh : rating >= 3 ? AppColors.scoreMedium : AppColors.scoreLow).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(rating > 0 ? rating.toStringAsFixed(1) : '—', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: rating >= 4 ? AppColors.scoreHigh : rating >= 3 ? AppColors.scoreMedium : AppColors.scoreLow)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        if ((c['address'] ?? '').isNotEmpty) Text(c['address'], style: TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ])));
  }
}
