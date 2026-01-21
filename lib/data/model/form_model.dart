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
  final String title;
  final String name;
  final String formTitle;
  final String subtitle;
  final String theme; // 'light' или 'dark'
  final List<FormFields> fields;
  final bool isActive;
  final String? heroImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FormModel({
    this.id,
    this.userId,
    required this.slug,
    required this.title,
    this.heroImage,
    this.name = '',
    this.formTitle = '',
    this.subtitle = '',
    this.theme = 'light',
    this.fields = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (userId != null) 'user_id': userId,
    if (heroImage != null) 'hero_image': heroImage,
    'slug': slug,
    'title': title,
    'form_title': formTitle,
    'name': name,
    'subtitle': subtitle,
    'theme': theme,
    'fields': fields.map((f) => f.toJson()).toList(),
    'is_active': isActive,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  factory FormModel.fromJson(Map<String, dynamic> json) => FormModel(
    id: json['id'] as String?,
    userId: json['user_id'] as String?,
    heroImage: json['hero_image'] as String?,
    formTitle: json['form_title'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    theme: json['theme'] as String? ?? 'light',
    fields:
        (json['fields'] as List?)
            ?.map((f) => FormFields.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [],
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
    List<FormFields>? fields,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FormModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    theme: theme ?? this.theme,
    fields: fields ?? this.fields,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
