import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
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
  String _processingStage = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      _photos = await _repo.getPhotos();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickAndProcess({bool fromCamera = false}) async {
    final image = await _repo.pickImage(fromCamera: fromCamera);
    if (image == null) return;
    setState(() {
      _isProcessing = true;
      _processingStage = 'Mengunggah foto...';
    });
    try {
      setState(() => _processingStage = 'Menghapus background...');
      await _repo.uploadAndProcess(image);
      setState(() => _processingStage = 'Menyimpan hasil...');
      await _loadPhotos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses foto: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _processingStage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop()),
        title: const Text('Cek Produk'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPhotos,
          color: AppColors.primary,
          backgroundColor: AppColors.bgLightSecondary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Memastikan selalu bisa ditarik walau item sedikit
            slivers: [
            // ── Upload area ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GlassCard(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.08),
                          AppColors.accent.withValues(alpha: 0.02),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  color: AppColors.accentLight, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Foto Produk Siap Marketplace',
                                style: AppTheme.displayFont(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload foto produkmu → background dihapus otomatis → langsung bisa dipakai di Shopee, Tokopedia, dsb.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            text: 'Dari Galeri',
                            icon: Icons.photo_library_outlined,
                            onPressed: _isProcessing
                                ? null
                                : () => _pickAndProcess(),
                            gradient: AppColors.dangerGradient,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            text: 'Ambil Foto',
                            icon: Icons.camera_alt_rounded,
                            onPressed: _isProcessing
                                ? null
                                : () => _pickAndProcess(fromCamera: true),
                            gradient: AppColors.primaryGradient,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                    // ── Processing indicator ──
                    if (_isProcessing) ...[
                      const SizedBox(height: 16),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _processingStage,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Biasanya memakan waktu 5-15 detik',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms),
                    ],
                  ],
                ),
              ),
            ),

            // ── Photos grid ──
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_photos.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined,
                          color: AppColors.textMuted, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada foto',
                        style: AppTheme.displayFont(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload foto produkmu untuk mulai',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final photo = _photos[i];
                      return GlassCard(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.bgLightSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    photo.status == 'done'
                                        ? Icons.check_circle_outline
                                        : Icons.image_outlined,
                                    color: photo.status == 'done'
                                        ? AppColors.scoreHigh
                                        : AppColors.textMuted,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(photo.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _statusLabel(photo.status),
                                    style: TextStyle(
                                      color: _statusColor(photo.status),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${photo.processedPaths.length} hasil',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: i * 60),
                          duration: 400.ms);
                    },
                    childCount: _photos.length,
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return AppColors.scoreHigh;
      case 'processing':
        return AppColors.scoreMedium;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'processing':
        return 'Proses...';
      case 'error':
        return 'Gagal';
      default:
        return 'Menunggu';
    }
  }
}
