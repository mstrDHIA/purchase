class RejectReason {
  final int id;
  final String reason;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RejectReason({
    required this.id,
    required this.reason,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory RejectReason.fromJson(Map<String, dynamic> json) => RejectReason(
        id: json['id'] as int? ?? 0,
        reason: json['reason'] as String? ?? '',
        description: json['description'] as String?,
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
        updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reason': reason,
        'description': description,
      };
}
