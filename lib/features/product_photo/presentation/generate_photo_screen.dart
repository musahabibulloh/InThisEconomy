import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/photo_repository.dart';

class GeneratePhotoScreen extends StatefulWidget {
  const GeneratePhotoScreen({super.key});
  @override
  State<GeneratePhotoScreen> createState() => _GeneratePhotoScreenState();
}

class _GeneratePhotoScreenState extends State<GeneratePhotoScreen> {
  final _promptController = TextEditingController();
  final _repo = PhotoRepository();
  bool _isProcessing = false;
  bool _hasResult = false;
  String _resultUrl = '';

  
  void _setTemplate(String text) {
    _promptController.text = text;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Buat Visual AI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasResult) ...[
                Text('Hasil Visual', style: AppTheme.displayFont(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('AI telah membuatkan visual produk berdasarkan idemu.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _resultUrl.startsWith('data:image')
                      ? Image.memory(base64Decode(_resultUrl.split(',').last), width: double.infinity, height: 300, fit: BoxFit.cover)
                      : Image.network(
                          _resultUrl.isNotEmpty ? _resultUrl : 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _hasResult = false),
                        style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                           side: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        child: const Text('Buat Variasi Lain', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        text: 'Simpan',
                        icon: Icons.check_circle_rounded,
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sedang menyimpan...')));
                          
                          final base64String = _resultUrl.split(',').last;
                          final bytes = base64Decode(base64String);
                          
                          // Save to gallery
                          await Gal.putImageBytes(bytes, name: 'AI_Product_${DateTime.now().millisecondsSinceEpoch}');
                          
                          // Save to history
                          await _repo.saveToHistory(base64String);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan ke Galeri & Riwayat!')));
                            context.pop();
                          }
                        },
                      ),
                    ),
                  ],
                )
              ] else ...[
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gambarkan produk impianmu...', style: AppTheme.displayFont(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _promptController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Kue coklat lumer dengan topping stroberi utuh, disajikan di piring keramik putih, meja kayu, pencahayaan alami hangat dari jendela.',
                          filled: true,
                          fillColor: AppColors.bgLightSecondary.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Atau pakai bantuan (Opsional):', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Kopi Kekinian'),
                      onPressed: () => _setTemplate('Gelas kopi es kopi susu gula aren dengan embun dingin, di atas meja kafe kayu, blur background.'),
                      backgroundColor: AppColors.glassWhite(),
                    ),
                    ActionChip(
                      label: const Text('Fashion Baju'),
                      onPressed: () => _setTemplate('Kaos katun premium warna sage green terlipat rapi di atas meja minimalis, estetik, pencahayaan studio cerah.'),
                      backgroundColor: AppColors.glassWhite(),
                    ),
                    ActionChip(
                      label: const Text('Kosmetik'),
                      onPressed: () => _setTemplate('Botol serum kaca elegan dengan tetesan air, dikelilingi daun mint dan background pastel lembut.'),
                      backgroundColor: AppColors.glassWhite(),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                GradientButton(
                  text: 'Mulai Buat Foto',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isProcessing,
                  onPressed: () async {
                    if (_promptController.text.isEmpty) return;
                    setState(() => _isProcessing = true);
                    
                    try {
                      final url = await _repo.generatePhoto(_promptController.text, 'none');
                      if (mounted) {
                        setState(() {
                          _resultUrl = url;
                          _hasResult = true;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                      }
                    }
                  },
                ),
              ],
            ],
          ),
        )
      )
    );
  }
}
