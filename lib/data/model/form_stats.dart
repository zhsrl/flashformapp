class FormStats {
  const FormStats({
    required this.id,
    required this.title,
    required this.totalLeads,
    required this.todayLeads,
  });

  final String id;
  final String title;
  final int totalLeads;
  final int todayLeads;

  factory FormStats.fromJson(Map<String, dynamic> json) {
    return FormStats(
      id: json['id'] as String,
      title: json['title'] as String,
      totalLeads: (json['total_leads'] as num).toInt(),
      todayLeads: (json['today_leads'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'total_leads': totalLeads,
    'today_leads': todayLeads,
  };

  FormStats copyWith({
    String? id,
    String? title,
    int? totalLeads,
    int? todayLeads,
  }) => FormStats(
    id: id ?? this.id,
    title: title ?? this.title,
    totalLeads: totalLeads ?? this.totalLeads,
    todayLeads: todayLeads ?? this.todayLeads,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FormStats &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              totalLeads == other.totalLeads &&
              todayLeads == other.todayLeads;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      totalLeads.hashCode ^
      todayLeads.hashCode;
}
