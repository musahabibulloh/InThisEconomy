import 'dart:convert';
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

  /// Flow A: Enhance background of an existing photo
  Future<String> enhancePhoto(XFile image, String style) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    final response = await _client.functions.invoke(
      'ai-product-photo',
      body: {
        'flow': 'A',
        'image_base64': base64Image,
        'style': style,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal memproses foto: ${response.data}');
    }
    
    return response.data['image_url'] as String;
  }

  /// Flow B: Generate photo from text prompt
  Future<String> generatePhoto(String prompt, String style) async {
    final response = await _client.functions.invoke(
      'ai-product-photo',
      body: {
        'flow': 'B',
        'prompt': prompt,
        'style': style,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal membuat foto: ${response.data}');
    }
    
    return response.data['image_url'] as String;
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
