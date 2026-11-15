/// مشتری (بیمار / مراجع) — آماده برای جدول customers در Supabase.
class Customer {
  const Customer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.notes = '',
    this.tags = const [],
    this.createdAt,
    this.visitCount = 0,
    this.totalSpent = 0,
    this.cancelCount = 0,
    this.noShowCount = 0,
    this.lastVisitAt,
    this.isBlocked = false,
  });

  final String id;
  final String fullName;
  final String phone;
  final String notes;
  final List<String> tags;
  final DateTime? createdAt;
  final int visitCount;
  final num totalSpent;
  final int cancelCount;
  final int noShowCount;
  final DateTime? lastVisitAt;
  final bool isBlocked;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) return parts.first.characters.first;
    return parts.first.characters.first;
  }

  /// شاخص پایبندی مشتری (۰ تا ۱۰۰) بر اساس حضور و لغو.
  int get reliability {
    final total = visitCount + cancelCount + noShowCount;
    if (total == 0) return 70;
    final score = ((visitCount * 100) - (cancelCount * 18) - (noShowCount * 34)) / total;
    return score.clamp(0, 100).round();
  }

  String get reliabilityLabel {
    final r = reliability;
    if (r >= 85) return 'بسیار قابل اعتماد';
    if (r >= 70) return 'قابل اعتماد';
    if (r >= 50) return 'متوسط';
    return 'نیازمند پیگیری';
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    int? visitCount,
    num? totalSpent,
    int? cancelCount,
    int? noShowCount,
    DateTime? lastVisitAt,
    bool? isBlocked,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      visitCount: visitCount ?? this.visitCount,
      totalSpent: totalSpent ?? this.totalSpent,
      cancelCount: cancelCount ?? this.cancelCount,
      noShowCount: noShowCount ?? this.noShowCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'notes': notes,
        'tags': tags,
        'created_at': createdAt?.toIso8601String(),
        'visit_count': visitCount,
        'total_spent': totalSpent,
        'cancel_count': cancelCount,
        'no_show_count': noShowCount,
        'last_visit_at': lastVisitAt?.toIso8601String(),
        'is_blocked': isBlocked,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
        visitCount: (json['visit_count'] as num?)?.toInt() ?? 0,
        totalSpent: json['total_spent'] as num? ?? 0,
        cancelCount: (json['cancel_count'] as num?)?.toInt() ?? 0,
        noShowCount: (json['no_show_count'] as num?)?.toInt() ?? 0,
        lastVisitAt: json['last_visit_at'] == null ? null : DateTime.tryParse(json['last_visit_at'] as String),
        isBlocked: json['is_blocked'] as bool? ?? false,
      );
}

extension _Chars on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
