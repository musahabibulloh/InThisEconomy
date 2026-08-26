import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gal/gal.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/mascot_reaction.dart';
import '../../../core/widgets/ite_avatar.dart';
import '../data/photo_repository.dart';
import '../domain/photo_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = PhotoRepository();
  late Future<List<ProductPhoto>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _repo.getPhotos();
    });
  }

  Future<void> _downloadImage(String url) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ite lagi unduh gambarnya... 📥')));
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      await Gal.putImageBytes(bytes, name: 'AI_Product_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil disimpan ke Galeri! 🎉')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Waduh gagal 😅 $e')));
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
        title: const Text('Riwayat Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<ProductPhoto>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
                    const SizedBox(height: 16),
                    Text('Gagal memuat riwayat', style: AppTheme.displayFont()),
                    Text(snapshot.error.toString(), style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            final photos = snapshot.data ?? [];
            if (photos.isEmpty) {
              return MascotEmptyState(
                pose: ItePose.camera,
                title: 'Belum ada foto nih 📷',
                subtitle: 'Foto yang kamu simpan dari Studio AI akan muncul di sini. Yuk mulai bikin!',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadHistory(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  final url = _repo.getPublicUrl(photo.originalPath);
                  final date = DateFormat('dd MMM yyyy HH:mm').format(photo.createdAt.toLocal());
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite(),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder()),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Center(child: Icon(Icons.broken_image, color: AppColors.textMuted)),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.black45,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                                      onPressed: () => _downloadImage(url),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(photo.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
