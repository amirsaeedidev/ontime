import 'enums.dart';

/// گزارش فعالیت کاربران — جدول activity_logs.
class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actor,
    required this.createdAt,
    this.entityName = '',
    this.entityId = '',
  });

  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String actor;
  final DateTime createdAt;
  final String entityName;
  final String entityId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.key,
        'title': title,
        'description': description,
        'actor': actor,
        'created_at': createdAt.toUtc().toIso8601String(),
        'entity_name': entityName,
        'entity_id': entityId,
      };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['id'] as String,
        type: ActivityType.fromKey(json['type'] as String? ?? 'appointmentCreated'),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        actor: json['actor'] as String? ?? 'سیستم',
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        entityName: json['entity_name'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
      );
}
