class MediaProject {
  const MediaProject({
    required this.id,
    required this.name,
    required this.description,
    required this.projectType,
    this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String description;
  final String projectType;
  final String? coverImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'projectType': projectType,
    'coverImagePath': coverImagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MediaProject.fromMap(Map<String, Object?> map) => MediaProject(
    id: map['id'] as int?,
    name: map['name'] as String,
    description: (map['description'] as String?) ?? '',
    projectType: map['projectType'] as String,
    coverImagePath: map['coverImagePath'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
