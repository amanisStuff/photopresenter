class GalleryManifest {
  final String id;
  final String name;
  final String user;
  final DateTime createdAt;
  final int imageCount;
  final int audioCount;
  final List<String> imagePaths;
  final List<String> audioPaths;

  GalleryManifest({
    required this.id,
    required this.name,
    required this.user,
    required this.createdAt,
    required this.imageCount,
    required this.audioCount,
    required this.imagePaths,
    required this.audioPaths,
  });

  factory GalleryManifest.fromJson(Map<String, dynamic> json) {
    return GalleryManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      user: json['user'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageCount: json['imageCount'] as int,
      audioCount: json['audioCount'] as int,
      imagePaths: (json['imagePaths'] as List<dynamic>).cast<String>(),
      audioPaths: (json['audioPaths'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user': user,
      'createdAt': createdAt.toIso8601String(),
      'imageCount': imageCount,
      'audioCount': audioCount,
      'imagePaths': imagePaths,
      'audioPaths': audioPaths,
    };
  }
}
