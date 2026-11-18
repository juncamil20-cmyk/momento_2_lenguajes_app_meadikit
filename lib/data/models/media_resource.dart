class MediaResource {
  const MediaResource({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.category,
    required this.originalFileName,
    required this.fileExtension,
    required this.localFilePath,
    required this.fileSize,
    this.imageWidth,
    this.imageHeight,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int projectId;
  final String name;
  final String description;
  final String category;
  final String originalFileName;
  final String fileExtension;
  final String localFilePath;
  final int fileSize;
  final int? imageWidth;
  final int? imageHeight;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'description': description,
    'category': category,
    'originalFileName': originalFileName,
    'fileExtension': fileExtension,
    'localFilePath': localFilePath,
    'fileSize': fileSize,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MediaResource.fromMap(Map<String, Object?> map) => MediaResource(
    id: map['id'] as int?,
    projectId: map['projectId'] as int,
    name: map['name'] as String,
    description: (map['description'] as String?) ?? '',
    category: map['category'] as String,
    originalFileName: map['originalFileName'] as String,
    fileExtension: map['fileExtension'] as String,
    localFilePath: map['localFilePath'] as String,
    fileSize: map['fileSize'] as int,
    imageWidth: map['imageWidth'] as int?,
    imageHeight: map['imageHeight'] as int?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
