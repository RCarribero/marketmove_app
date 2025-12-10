/// Modelo que representa un gasto registrado.
///
/// Corresponde a la tabla 'gastos' en Supabase.
class Expense {
  /// Identificador único del gasto.
  final int? id;

  /// ID del usuario propietario del gasto (Supabase Auth).
  final String? userId;

  /// Monto del gasto.
  final double amount;

  /// Descripción detallada del gasto.
  final String description;

  /// Categoría del gasto (ej. Alquiler, Servicios, etc.).
  final String category;

  /// Fecha en que se realizó el gasto.
  final DateTime date;

  /// Constructor inmutable para crear una instancia de [Expense].
  const Expense({
    this.id,
    this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  /// Crea una copia de esta instancia con los campos modificados.
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

  /// Convierte la instancia a un mapa JSON compatible con Supabase.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  /// Crea una instancia de [Expense] a partir de un mapa JSON.
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
