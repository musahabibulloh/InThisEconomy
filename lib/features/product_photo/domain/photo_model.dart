class ProductPhoto {
  final String id;
  final String userId;
  final String originalPath;
  final List<ProcessedImage> processedPaths;
  final String status; // 'pending', 'processing', 'done', 'error'
  final DateTime createdAt;

  ProductPhoto({
    required this.id,
    required this.userId,
    required this.originalPath,
    this.processedPaths = const [],
    this.status = 'pending',
    required this.createdAt,
  });

  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    return ProductPhoto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      originalPath: json['original_path'] as String,
      processedPaths: (json['processed_paths'] as List<dynamic>?)
              ?.map((e) =>
                  ProcessedImage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ProcessedImage {
  final String type;
  final String path;

  ProcessedImage({required this.type, required this.path});

  factory ProcessedImage.fromJson(Map<String, dynamic> json) {
    return ProcessedImage(
      type: json['type'] as String,
      path: json['path'] as String,
    );
  }
}
