class FormFields {
  final String label;
  final String type; // 'text' или 'phone'

  FormFields({
    required this.label,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'type': type,
  };

  factory FormFields.fromJson(Map<String, dynamic> json) => FormFields(
    label: json['label'] as String,
    type: json['type'] as String,
  );
}

class FormModel {
  final String? id;
  final String? userId;
  final String slug;
  final String name;

  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? data;

  FormModel({
    this.id,
    this.userId,
    required this.slug,
    this.data,
    this.name = '',

    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (userId != null) 'user_id': userId,
    'slug': slug,
    'data': data,
    'name': name,

    'is_active': isActive,

    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
    id: json['id'] as String?,
    userId: json['user_id'] as String?,
    data: json['data'],
    name: json['name'] as String,
    slug: json['slug'] as String,

    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  FormModel copyWith({
    String? id,
    String? userId,
    String? slug,
    String? title,
    String? subtitle,
    String? theme,
    Map<String, dynamic>? data,
    List<FormFields>? fields,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FormModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    slug: slug ?? this.slug,
    data: data ?? this.data,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
