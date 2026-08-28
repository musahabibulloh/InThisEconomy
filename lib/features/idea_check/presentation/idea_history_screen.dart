import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../data/idea_check_repository.dart';
import '../domain/idea_check_model.dart';
import '../../market_gap/data/market_gap_repository.dart';
import '../../market_gap/domain/market_gap_model.dart';

class IdeaHistoryScreen extends StatefulWidget {
  const IdeaHistoryScreen({super.key});
  @override
  State<IdeaHistoryScreen> createState() => _IdeaHistoryScreenState();
}

class _IdeaHistoryScreenState extends State<IdeaHistoryScreen> {
  final _ideaRepo = IdeaCheckRepository();
  final _gapRepo = MarketGapRepository();
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ideaItems = await _ideaRepo.getHistory();
      final gapItems = await _gapRepo.getHistory();
      
      final List<dynamic> combined = [...ideaItems, ...gapItems];
      combined.sort((a, b) => (b.createdAt as DateTime).compareTo(a.createdAt as DateTime));

      if (mounted) {
        setState(() {
          _items = combined;
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
        title: const Text('Riwayat Analisis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? MascotEmptyState(
                  pose: ItePose.idea,
                  title: 'Belum ada riwayat nih 📋',
                  subtitle:
                      'Yuk, cek ide bisnismu yang pertama! Ite udah siap bantuin riset pasar buat kamu 🚀',
                  action: TextButton.icon(
                    onPressed: () => context.push('/idea-check'),
                    icon: Icon(Icons.add_rounded, color: AppColors.primary),
                    label: Text('Cek Ide Sekarang',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    final isIdea = item is IdeaCheck;
                    
                    final title = isIdea 
                        ? (item.productCategory ?? item.inputText ?? 'Ide Bisnis')
                        : 'Pemindaian Celah Pasar';
                        
                    final icon = isIdea ? Icons.lightbulb_outline : Icons.explore_outlined;
                    final route = isIdea 
                        ? '/idea-check/result/${item.id}'
                        : '/market-gap/result/${item.id}';
                        
                    final badgeText = isIdea 
                        ? item.opportunityScore 
                        : (item as MarketGapScan).gapCategories.isNotEmpty 
                            ? '${item.gapCategories.length} Peluang' 
                            : 'Padat';
                            
                    final badgeColor = isIdea && item.opportunityScore != null
                        ? _scoreColor(item.opportunityScore!)
                        : (!isIdea && (item as MarketGapScan).gapCategories.isNotEmpty)
                            ? AppColors.scoreHigh
                            : AppColors.textMuted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: () => context.push(route),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: isIdea ? AppColors.primaryGradient : AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(icon, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item.locationName != null) ...[
                                        Icon(Icons.location_on_outlined,
                                            size: 12,
                                            color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(item.locationName!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 11)),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                          DateFormat('dd MMM')
                                              .format(item.createdAt),
                                          style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (badgeText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badgeText,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                              delay: Duration(milliseconds: i * 80),
                              duration: 400.ms),
                    );
                  },
                ),
    );
  }

  Color _scoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'tinggi':
        return AppColors.scoreHigh;
      case 'sedang':
        return AppColors.scoreMedium;
      default:
        return AppColors.scoreLow;
    }
  }
}
