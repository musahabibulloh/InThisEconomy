import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/idea_check_repository.dart';
import '../domain/idea_check_model.dart';

class IdeaHistoryScreen extends StatefulWidget {
  const IdeaHistoryScreen({super.key});
  @override
  State<IdeaHistoryScreen> createState() => _IdeaHistoryScreenState();
}

class _IdeaHistoryScreenState extends State<IdeaHistoryScreen> {
  final _repo = IdeaCheckRepository();
  List<IdeaCheck> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final items = await _repo.getHistory();
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Riwayat Analisis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.history_rounded, color: AppColors.textMuted, size: 56),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Mulai cek ide bisnismu pertama!', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return GlassCard(
                      onTap: () => context.push('/idea-check/result/${item.id}'),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 22)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.productCategory ?? item.inputText ?? 'Ide Bisnis',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(children: [
                            if (item.locationName != null) ...[
                              Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(item.locationName!, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(width: 12),
                            ],
                            Text(DateFormat('dd MMM yyyy').format(item.createdAt), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ]),
                        ])),
                        if (item.opportunityScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _scoreColor(item.opportunityScore!).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(item.opportunityScore!, style: TextStyle(
                              color: _scoreColor(item.opportunityScore!), fontWeight: FontWeight.w600, fontSize: 11))),
                      ]),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 80), duration: 400.ms);
                  }),
    );
  }

  Color _scoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'tinggi': return AppColors.scoreHigh;
      case 'sedang': return AppColors.scoreMedium;
      default: return AppColors.scoreLow;
    }
  }
}
