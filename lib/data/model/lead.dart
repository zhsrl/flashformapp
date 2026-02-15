class Lead {
  Lead({
    this.id,
    this.formId,
    this.answers,
    this.createdAt,
    this.utmData,
    this.geoData,
  });

  final String? id;
  final String? formId;
  final Map<String, dynamic>? answers;
  final DateTime? createdAt;
  final Map<String, dynamic>? utmData;
  final Map<String, dynamic>? geoData;

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
    id: json['id'] as String?,
    formId: json['form_id'] as String?,
    answers: json['answers'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
    utmData: json['utm_data'] as Map<String, dynamic>?,
    geoData: json['geo'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (formId != null) 'form_id': formId,
    if (answers != null) 'answers': answers,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (utmData != null) 'utm_data': utmData,
    if (geoData != null) 'geo': geoData,
  };
}
