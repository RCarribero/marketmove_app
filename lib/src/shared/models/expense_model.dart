class Expense {
  final int id;
  final String? userId;
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  const Expense({
    required this.id,
    this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  Expense copyWith({
    int? id,
    String? userId,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
