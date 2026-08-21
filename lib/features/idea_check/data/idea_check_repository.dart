import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/idea_check_model.dart';

class IdeaCheckRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Call the analyze-idea Edge Function
  Future<IdeaCheck> analyzeIdea({
    required String inputText,
    required double latitude,
    required double longitude,
    String? locationName,
    double radiusKm = 2.0,
  }) async {
    final response = await _client.functions.invoke(
      'analyze-idea',
      body: {
        'input_text': inputText,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'radius_km': radiusKm,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal menganalisis ide: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return IdeaCheck.fromJson(data);
  }

  /// Get all idea checks for current user
  Future<List<IdeaCheck>> getHistory() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('idea_checks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => IdeaCheck.fromJson(e)).toList();
  }

  /// Get a specific idea check by ID
  Future<IdeaCheck> getById(String id) async {
    final data =
        await _client.from('idea_checks').select().eq('id', id).single();
    return IdeaCheck.fromJson(data);
  }

  /// Delete an idea check
  Future<void> delete(String id) async {
    await _client.from('idea_checks').delete().eq('id', id);
  }
}
