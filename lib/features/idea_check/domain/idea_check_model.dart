class IdeaCheck {
  final String id;
  final String userId;
  final String inputType; // 'idea' or 'location'
  final String? inputText;
  final String? productCategory;
  final double latitude;
  final double longitude;
  final String? locationName;
  final double radiusKm;

  // Analysis results
  final String? opportunityScore;
  final String? competitionScore;
  final String? demandScore;
  final String? recommendation;

  // Detailed data
  final List<Map<String, dynamic>> competitors;
  final Map<String, dynamic> targetMarket;
  final Map<String, dynamic> trendData;
  final String? differentiationAnalysis;
  final String? trendRisk;

  final DateTime createdAt;

  IdeaCheck({
    required this.id,
    required this.userId,
    required this.inputType,
    this.inputText,
    this.productCategory,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.radiusKm = 2.0,
    this.opportunityScore,
    this.competitionScore,
    this.demandScore,
    this.recommendation,
    this.competitors = const [],
    this.targetMarket = const {},
    this.trendData = const {},
    this.differentiationAnalysis,
    this.trendRisk,
    required this.createdAt,
  });

  factory IdeaCheck.fromJson(Map<String, dynamic> json) {
    return IdeaCheck(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      inputType: json['input_type'] as String,
      inputText: json['input_text'] as String?,
      productCategory: json['product_category'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String?,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 2.0,
      opportunityScore: json['opportunity_score'] as String?,
      competitionScore: json['competition_score'] as String?,
      demandScore: json['demand_score'] as String?,
      recommendation: json['recommendation'] as String?,
      competitors: (json['competitors'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      targetMarket:
          Map<String, dynamic>.from(json['target_market'] as Map? ?? {}),
      trendData: Map<String, dynamic>.from(json['trend_data'] as Map? ?? {}),
      differentiationAnalysis: json['differentiation_analysis'] as String?,
      trendRisk: json['trend_risk'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'input_type': inputType,
      'input_text': inputText,
      'product_category': productCategory,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'radius_km': radiusKm,
      'opportunity_score': opportunityScore,
      'competition_score': competitionScore,
      'demand_score': demandScore,
      'recommendation': recommendation,
      'competitors': competitors,
      'target_market': targetMarket,
      'trend_data': trendData,
      'differentiation_analysis': differentiationAnalysis,
      'trend_risk': trendRisk,
    };
  }
}
