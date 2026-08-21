class MarketGapScan {
  final String id;
  final String userId;
  final String? ideaCheckId;
  final double latitude;
  final double longitude;
  final String? locationName;
  final double radiusKm;

  // Results
  final List<GapCategory> gapCategories;
  final Map<String, dynamic> areaProfile;

  final DateTime createdAt;

  MarketGapScan({
    required this.id,
    required this.userId,
    this.ideaCheckId,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.radiusKm = 2.0,
    this.gapCategories = const [],
    this.areaProfile = const {},
    required this.createdAt,
  });

  factory MarketGapScan.fromJson(Map<String, dynamic> json) {
    return MarketGapScan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ideaCheckId: json['idea_check_id'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String?,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 2.0,
      gapCategories: (json['gap_categories'] as List<dynamic>?)
              ?.map((e) => GapCategory.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      areaProfile:
          Map<String, dynamic>.from(json['area_profile'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class GapCategory {
  final String category;
  final int competitorCount;
  final String areaDensity;
  final double score;
  final String reason;
  final String? estimatedCapital;

  GapCategory({
    required this.category,
    required this.competitorCount,
    required this.areaDensity,
    required this.score,
    required this.reason,
    this.estimatedCapital,
  });

  factory GapCategory.fromJson(Map<String, dynamic> json) {
    return GapCategory(
      category: json['category'] as String,
      competitorCount: json['competitor_count'] as int,
      areaDensity: json['area_density'] as String,
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String,
      estimatedCapital: json['estimated_capital'] as String?,
    );
  }
}
