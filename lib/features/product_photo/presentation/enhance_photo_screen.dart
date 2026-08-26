import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../data/photo_repository.dart';

class EnhancePhotoScreen extends StatefulWidget {
  const EnhancePhotoScreen({super.key});
  @override
  State<EnhancePhotoScreen> createState() => _EnhancePhotoScreenState();
}

class _EnhancePhotoScreenState extends State<EnhancePhotoScreen> {
  XFile? _image;
  final _repo = PhotoRepository();
  String _selectedStyle = 'Meja Kayu';
  bool _isProcessing = false;
  bool _hasResult = false;
  String _resultUrl = '';

  final _styles = ['Meja Kayu', 'Studio Putih', 'Alam Terbuka', 'Kafe Estetik'];

  Future<void> _pickImage(bool fromCamera) async {
    final img = await _repo.pickImage(fromCamera: fromCamera);
    if (img != null) {
      setState(() => _image = img);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Percantik Foto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isProcessing) ...[
                // Ite working animation
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      IteAvatar(pose: ItePose.camera, size: 80)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 800.ms),
                      const SizedBox(height: 24),
                      Text(
                        'Ite lagi percantik fotomu... ✨',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sabar ya, lagi dipoles jadi sekelas studio 📸',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ] else if (_image == null) ...[
                // Empty state with Ite
                GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const IteAvatar(pose: ItePose.camera, size: 64),
                        const SizedBox(height: 16),
                        const Text('Ayo, foto produkmu! Ite bantuin percantik 📸',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: GradientButton(text: 'Galeri', icon: Icons.photo_library, onPressed: () => _pickImage(false))),
                            const SizedBox(width: 16),
                            Expanded(child: GradientButton(text: 'Kamera', icon: Icons.camera_alt, onPressed: () => _pickImage(true), gradient: AppColors.dangerGradient)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ] else if (_hasResult) ...[
                // Ite celebrates the result
                const MascotReaction(
                  pose: ItePose.celebrate,
                  message: 'Wah, hasilnya keren banget! 🤩 Foto produkmu udah sekelas katalog profesional!',
                  highlighted: true,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sebelum', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                               height: 140,
                               width: double.infinity,
                               color: AppColors.glassWhite(0.5),
                               child: const Center(child: Icon(Icons.image, size: 40, color: AppColors.textMuted)),
                            )
                          ),
                        ]
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sesudah ✨', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _resultUrl.startsWith('data:image')
                                ? Image.memory(base64Decode(_resultUrl.split(',').last), height: 200, width: double.infinity, fit: BoxFit.cover)
                                : Image.network(
                                    _resultUrl.isNotEmpty ? _resultUrl : 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ]
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
                        child: const Text('Ganti Gaya', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        text: 'Simpan 💾',
                        icon: Icons.check_circle_rounded,
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ite lagi nyimpen foto kamu... 📸')));
                          
                          final base64String = _resultUrl.split(',').last;
                          final bytes = base64Decode(base64String);
                          
                          // Save to gallery
                          await Gal.putImageBytes(bytes, name: 'AI_Product_${DateTime.now().millisecondsSinceEpoch}');
                          
                          // Save to history
                          await _repo.saveToHistory(base64String);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan ke Galeri & Riwayat! 🎉')));
                            context.pop();
                          }
                        },
                      ),
                    ),
                  ],
                )
              ] else ...[
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_image!.path), fit: BoxFit.cover),
                        )
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => setState(() => _image = null),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Ganti Foto'),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 32),
                Text('Pilih Gaya Latar', style: AppTheme.displayFont(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _styles.length,
                    itemBuilder: (context, index) {
                      final style = _styles[index];
                      final isSelected = style == _selectedStyle;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStyle = style),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassWhite(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder(), width: isSelected ? 2 : 1),
                          ),
                          child: Center(
                            child: Text(style, textAlign: TextAlign.center, style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Percantik Sekarang ✨',
                  icon: Icons.auto_fix_high_rounded,
                  isLoading: _isProcessing,
                  onPressed: () async {
                    setState(() => _isProcessing = true);
                    try {
                      final url = await _repo.enhancePhoto(_image!, _selectedStyle);
                      if (mounted) {
                        setState(() {
                          _resultUrl = url;
                          _hasResult = true;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Waduh gagal 😅 ${e.toString()}')));
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                      }
                    }
                  }
                )
              ]
            ],
          ),
        )
      )
    );
  }
}
