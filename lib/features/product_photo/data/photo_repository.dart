import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/photo_model.dart';

class PhotoRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    return await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
  }

  /// Upload photo and process it
  Future<ProductPhoto> uploadAndProcess(XFile image) async {
    final userId = _client.auth.currentUser!.id;
    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

    // Upload to Supabase Storage
    final bytes = await image.readAsBytes();
    await _client.storage.from('product-photos').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(contentType: image.mimeType ?? 'image/jpeg'),
        );

    // Create DB record
    final record = await _client.from('product_photos').insert({
      'user_id': userId,
      'original_path': fileName,
      'status': 'processing',
    }).select().single();

    // Call process-photo Edge Function
    final response = await _client.functions.invoke(
      'process-photo',
      body: {
        'photo_id': record['id'],
        'storage_path': fileName,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal memproses foto: ${response.data}');
    }

    // Fetch updated record
    final updated = await _client
        .from('product_photos')
        .select()
        .eq('id', record['id'])
        .single();

    return ProductPhoto.fromJson(updated);
  }

  /// Get all photos for current user
  Future<List<ProductPhoto>> getPhotos() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('product_photos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ProductPhoto.fromJson(e)).toList();
  }

  /// Get public URL for a storage path
  String getPublicUrl(String path) {
    return _client.storage.from('product-photos').getPublicUrl(path);
  }
}
