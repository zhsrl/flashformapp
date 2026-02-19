class FormStats {
  const FormStats({
    required this.id,
    required this.name,
    required this.totalLeads,
    required this.todayLeads,
  });

  final String id;
  final String name;
  final int totalLeads;
  final int todayLeads;

  factory FormStats.fromJson(Map<String, dynamic> json) {
    return FormStats(
      id: json['id'] as String,
      name: json['name'] as String,
      totalLeads: (json['total_leads'] as num).toInt(),
      todayLeads: (json['today_leads'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'total_leads': totalLeads,
    'today_leads': todayLeads,
  };

  FormStats copyWith({
    String? id,
    String? name,
    int? totalLeads,
    int? todayLeads,
  }) => FormStats(
    id: id ?? this.id,
    name: name ?? this.name,
    totalLeads: totalLeads ?? this.totalLeads,
    todayLeads: todayLeads ?? this.todayLeads,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FormStats &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              totalLeads == other.totalLeads &&
              todayLeads == other.todayLeads;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      totalLeads.hashCode ^
      todayLeads.hashCode;
}
