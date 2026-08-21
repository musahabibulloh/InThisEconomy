import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/photo_repository.dart';
import '../domain/photo_model.dart';

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({super.key});
  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  final _repo = PhotoRepository();
  List<ProductPhoto> _photos = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() { super.initState(); _loadPhotos(); }

  Future<void> _loadPhotos() async {
    try {
      _photos = await _repo.getPhotos();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickAndProcess({bool fromCamera = false}) async {
    final image = await _repo.pickImage(fromCamera: fromCamera);
    if (image == null) return;
    setState(() => _isProcessing = true);
    try {
      await _repo.uploadAndProcess(image);
      await _loadPhotos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accent));
      }
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        title: const Text('Cek Produk'),
      ),
      body: SafeArea(child: Column(children: [
        // Upload area
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            GlassCard(
              gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.03)]),
              child: Column(children: [
                Row(children: [
                  Icon(Icons.camera_alt_outlined, color: AppColors.accentLight, size: 20),
                  const SizedBox(width: 8),
                  Text('Upload Foto Produk', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentLight)),
                ]),
                const SizedBox(height: 8),
                Text('Foto produkmu akan dihapus background-nya dan dihasilkan variasi siap pakai untuk marketplace.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
              ]),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: GradientButton(text: 'Galeri', icon: Icons.photo_library_outlined, onPressed: _isProcessing ? null : () => _pickAndProcess(),
                gradient: AppColors.dangerGradient)),
              const SizedBox(width: 12),
              Expanded(child: GradientButton(text: 'Kamera', icon: Icons.camera_alt_rounded, onPressed: _isProcessing ? null : () => _pickAndProcess(fromCamera: true),
                gradient: AppColors.primaryGradient)),
            ]).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                const SizedBox(width: 10),
                Text('Memproses foto...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ],
          ]),
        ),
        // Photos grid
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.photo_camera_outlined, color: AppColors.textMuted, size: 56),
                const SizedBox(height: 16),
                Text('Belum ada foto', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Upload foto produkmu untuk mulai', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ]))
            : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
                itemCount: _photos.length,
                itemBuilder: (context, i) {
                  final photo = _photos[i];
                  return GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Container(
                        decoration: BoxDecoration(color: AppColors.bgDark, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 40)),
                      )),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: photo.status == 'done' ? AppColors.scoreHigh.withValues(alpha: 0.15) : AppColors.scoreMedium.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text(photo.status == 'done' ? 'Selesai' : photo.status == 'processing' ? 'Proses...' : 'Pending',
                            style: TextStyle(color: photo.status == 'done' ? AppColors.scoreHigh : AppColors.scoreMedium, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Text('${photo.processedPaths.length} hasil', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ]),
                    ]),
                  ).animate().fadeIn(delay: Duration(milliseconds: i * 60), duration: 400.ms);
                }),
        ),
      ])),
    );
  }
}
