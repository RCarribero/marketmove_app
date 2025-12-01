class Sale {
  final int id;
  final String? userId;
  final double total;
  final DateTime date;
  final String? customerName;
  final List<Map<String, dynamic>> items;

  const Sale({
    required this.id,
    this.userId,
    required this.total,
    required this.date,
    this.customerName,
    required this.items,
  });

  Sale copyWith({
    int? id,
    String? userId,
    double? total,
    DateTime? date,
    String? customerName,
    List<Map<String, dynamic>>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      date: date ?? this.date,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'date': date.toIso8601String(),
      'customerName': customerName,
      'items': items,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      customerName: json['customerName'] as String?,
      items: List<Map<String, dynamic>>.from(json['items'] as List),
    );
  }
}
