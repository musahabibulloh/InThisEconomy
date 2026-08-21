import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/market_gap_model.dart';

class MarketGapRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Call the scan-market-gaps Edge Function
  Future<MarketGapScan> scanMarketGaps({
    required double latitude,
    required double longitude,
    String? locationName,
    double radiusKm = 2.0,
  }) async {
    final response = await _client.functions.invoke(
      'scan-market-gaps',
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'radius_km': radiusKm,
      },
    );

    if (response.status != 200) {
      throw Exception('Gagal memindai celah pasar: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return MarketGapScan.fromJson(data);
  }

  /// Get all scans for current user
  Future<List<MarketGapScan>> getHistory() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('market_gap_scans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => MarketGapScan.fromJson(e)).toList();
  }

  /// Get a specific scan by ID
  Future<MarketGapScan> getById(String id) async {
    final data =
        await _client.from('market_gap_scans').select().eq('id', id).single();
    return MarketGapScan.fromJson(data);
  }
}
